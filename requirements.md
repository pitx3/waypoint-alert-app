

# Trail Waypoint Alert App

## 1. Purpose
Why this app exists and what problem it solves.

- Alert hiker to critical waypoints (water, navigation traps, etc.) on Colorado Trail
- Offline-only, privacy-focused, no cloud
- Designed for FKT attempt conditions (exhausted, low-light, time pressure)

## 1. Design Considerations

    
## 2. Data Model
### Waypoints
| Column | Type | Example |
|--------|------|---------|
| Section |	Integer |	1-28 |
| Name |	Text |	“Georgia Pass Junction” |
| Latitude |	Decimal |	39.5342 |
| Longitude |	Decimal |	-106.0891 |
| Type |	Text |	Water, junction, camp, bailout, TH |
| Priority |	Text |	Info, normal, high, urgent |
| Alert_Distance |	Integer |	200, 500, 1000 |
| Notes |	Text |	“Carry 2L – next source 15km” |
| Enabled |	Boolean	| true/false |
| Sound_File	| Text (optional) |	Filename or blank for default |
| Vibration_Pattern |	Text (optional) |	Pattern string or blank for default |

App storage: Encrypted local database (Hive or Isar), key stored in Android Keystore.

App-level defaults and user preferences.

### Settings / Configuration

#### User-Configurable:
Setting	Type	Default	Notes
GPS Ping Interval	Integer (seconds)	60-300	Base interval, dynamic adjustment overrides
Walking Speed Buffer	Integer (m/min)	150	For dynamic interval calculation
Compass Widget	Boolean	False	Show/hide compass on alert screen
Silent Mode	Boolean	False	Vibration only, no sound
System Defaults (may be user-adjustable):
Setting	Type	Notes
Default Alert Distance	Integer (meters)	For waypoints without explicit alerts
Default Priority	String	info/normal/high/urgent
Sound per Priority	String (filename)	4 sounds (one per priority level)
Vibration per Priority	String (pattern)	4 patterns (one per priority level)
Max Alert Distance	Integer (meters)	Calculated on startup. Not user-set

#### Storage:
- Encrypted local storage (same as waypoints)
- Simple key-value store (SharedPreferences or Hive box)

TODO: Think about how to store an array of sounds for alert types and priorities. e.g. water-high vs water-info. Similar for vibration patterns. 


## 3. Core Features
- Import CSV from spreadsheet
- GPS location checking at configurable interval (30s - 5min)
- Alert when within waypoint's alert distance
- Priority-based alert behavior (dismissal, repetition)
- Type-based sound differentiation
- Vibration patterns (including custom dot/dash sequences)
- Edit waypoints on trail (add, modify, mark visited/dismissed)
- Section filter (view only relevant section)
- Search/filter by type or name
- Offline-only, no network permissions

## 4. Alert System
### Priority levels:
- Info – subtle, non-urgent
- Normal – standard alert
- High – more persistent
- Urgent – loud, repeats until dismissed

### Alert behavior:
Trigger once per waypoint by default (not every check interval while in range)  
Dismissal option (silences for rest of trip or X minutes)  
Optional repeat for urgent waypoints

### Sound:
Embedded in APK (MP3 or OGG)
Default sound per waypoint type-priority level combination
Optional override per waypoint
Optional silent mode (vibration only)

### Vibration:
Default pattern per waypoint type-priority level combination  
Configurable patterns per priority  
Custom patterns supported  
Silent mode option (vibration only)  

## 5. UI Features
### Alert Display
Shows distance to waypoint (e.g. 475m)  
Shows direction (heading) to waypoint (e.g. 178 degrees)  
Shows notes for waypoint  
Compass widget  
Toggle for compass widget – default off  
Snooze/Dismiss options  
Button to manually refresh distance and heading (i.e. do a GPS ping)

### Data Entry
Import CSV  
Import GPX  
View all waypoints  
View/edit/delete single waypoint  
Manually add new waypoint  
GPS Settings  
Set GPS “ping” frequency. Default 5 minutes.  
Set walking pace. Default 75m/min. Used for increased pings when getting close to waypoints.

## 6. Technical Specs
### 6.0 Technical Stack
- Flutter (Android-only)
- geolocator (GPS, background tracking)
- Hive or Isar (encrypted local storage)
- flutter_local_notifications (alerts)
- flutter_secure_storage (encryption key)
- Target: Android 13+ (Samsung A32, Pixel 8/GrapheneOS)

### 6.1 Technical Functions
#### GPS Checking Logic
**Bounding Box Filter**
- Before calculating precise distances, filter waypoints using a bounding box
- Box size: ±`maxAlertDistance` from current location
- Latitude: `1km ≈ 0.009°` (constant)
- Longitude: `1km ≈ 0.009° / cos(latitude)` (varies by latitude; at Colorado ~39°N: `1km ≈ 0.0116°`)
- Only perform Haversine calculation on waypoints within the box
- Typical result: 0-5 waypoints per check, rarely more
  
**Maximum Alert Distance**
- Calculated on app startup by scanning all alert distances
- Recalculated on any waypoint add, edit, or delete operation
- Used to determine bounding box size
- Full rescan is negligible cost (~1500 alert distances at most)

**Distance Calculation**
- Haversine formula for great-circle distance on sphere
- Earth radius: 6,371,000 meters
- Only calculated on waypoints that pass bounding box filter
- Dart packages available (`geolocator` has distance methods)

**Dynamic GPS Ping Intervals**
- Base interval: user-configurable (30s - 5min default). Stored in GPS Settings
- Interval shortens when approaching active alert thresholds
- Formula: check_interval = min(default_interval, distance_to_nearest_threshold / walking_speed_buffer)
- Walking speed buffer: conservative estimate (~75m/min) to prevent overshooting. Stored in GPS Settings.
- Prevents missing alerts when moving faster than check interval allows

**Bearing Calculation**
- Calculate bearing from current GPS to waypoint (0-360°)
- Displayed in alert UI alongside distance
- Used by compass widget to show direction to waypoint
- Standard spherical trigonometry formula

#### Data Structure
**Database: Isar (NoSQL)**
- Waypoints stored as objects with embedded alert lists
- 1:many relationship: one waypoint has many alerts
- Alerts embedded directly in waypoint object (not separate table)
- Indexes on `latitude` and `longitude` for bounding box queries

**Waypoint Object:**

    {
      id: int,
      section: int,
      name: string,
      latitude: double,
      longitude: double,
      type: string,
      notes: string,
      enabled: bool,
      alerts: List<Alert>
    }

**Alert Object (embedded):**

    {
      distance: int,      // meters
      priority: string,   // info, normal, high, urgent
      fired: bool         // runtime state, not persisted
    }

**Spreadsheet Import Format:**
- CSV export from LibreOffice Calc
- Alerts column format: `500:high|300:high|100:urgent`
- Parsed into embedded list on import

#### Alert Trigger Logic
1. Calculate distance to waypoint (Haversine, after bounding box filter)
2. Filter alerts where `distance <= alert_threshold`
3. Sort by distance descending (furthest first)
4. Check state: has this alert already fired?
5. Trigger the furthest un-fired alert now in range
6. Mark alert as fired (runtime state only)
7. State resets when waypoint is dismissed or user leaves area

#### Performance Considerations
- GPS ping is the primary battery drain, not calculations
- Bounding box reduces Haversine calls from ~600 to ~5 per check
- Full max-distance rescan on data changes is microseconds
- Modern ARM processor handles this workload with negligible CPU usage
- Design prioritizes correctness and efficiency as principle, not necessity

#### Other Considerations
- UI-first approach when building. Allows for the tech design to follow the app instead of forcing the app into the tech design.
- Dark theme, teal/blue
- SharedPreferences for settings
- Constructor injection (may add Riverpod later)
- Test coverage from start. Aim for 80% code coverage


## 7. Edge Cases Identified
- Repeated alerts when stationary within range of waypoint
- Multiple waypoints of same type in close succession (water-rich sections)
- Last water source before dry stretch needs higher priority
- Night hiking (need audible/vibration alerts, not visual)
- Editing waypoints on trail (add new, update notes, mark conditions)
- GPX extraction for initial coordinate population

## 8. Out of Scope (For Now)
- Continuous route tracking
- Distance visualization
- iOS support
- Cloud sync
- Multi-user support
- GPX import/export (maybe later)

## 9. Open Questions
- Exact sound files (need to source/create 4-5 distinct alerts)
- Default vibration patterns
- GPX parsing script for coordinate extraction
- Dismissal duration (permanent vs. timed)


