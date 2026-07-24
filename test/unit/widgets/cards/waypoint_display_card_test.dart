
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/enums/waypoint_type.dart';
import 'package:waypoint_alert_app/models/water_info.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/widgets/cards/active_set_card.dart';
import 'package:waypoint_alert_app/widgets/cards/closest_water_card.dart';
import 'package:waypoint_alert_app/widgets/cards/empty_state_card.dart';
import 'package:waypoint_alert_app/widgets/cards/next_waypoint_card.dart';
import 'package:waypoint_alert_app/widgets/cards/upcoming_waypoints_list.dart';
import 'package:waypoint_alert_app/widgets/cards/waypoint_display_card.dart';

import '../../../helpers/expect.dart';
import '../../../helpers/widget_helpers.dart';

// ----------------------------------
// Mocks and Fakes
// ----------------------------------
WaypointDisplayCard testCard({
  String setName = 'Test Trail Set',
  int waypointCount = 10,
  UpcomingWaypoint? nextWaypoint,
  List<UpcomingWaypoint>? upcomingWaypoints,
  double maxDistanceKm = 10.0,
  WaterInfo? waterInfo,
}) {
  upcomingWaypoints = upcomingWaypoints ?? [];
  WaypointDisplayCard card = WaypointDisplayCard(
    setName: setName,
    waypointCount: waypointCount,
    nextWaypoint: nextWaypoint,
    upcomingWaypoints: upcomingWaypoints,
    maxDistanceKm: maxDistanceKm,
    waterInfo: waterInfo,
  );
  return card;
}

UpcomingWaypoint mockUpcomingWaypoint({
  String name = 'Mock Waypoint',
  double distanceKm = 5.0,
  double bearing = 235.0,
  WaypointType type = WaypointType.camp,
  String? notes,
  int alertCount = 0,
}) {
  UpcomingWaypoint mock = UpcomingWaypoint(
    name: name, 
    distanceKm: distanceKm, 
    bearing: bearing, 
    type: type, 
    notes: notes, 
    alertCount: alertCount);
  return mock;
}

Waypoint mockWaypoint({
  int setId = 0,
  int sortOrder = 0,
  String name = '',
  double latitude = 40.0,
  double longitude = -105.0,
  WaypointType type = WaypointType.unknown,
  List<Alert>? alerts,
}) {
  Waypoint waypoint = Waypoint(
    setId: setId, 
    sortOrder: sortOrder, 
    name: name, 
    latitude: latitude, 
    longitude: longitude, 
    type: type, 
    alerts: alerts ?? []
  );
  return waypoint;
}

WaterInfo mockWaterInfo({
  Waypoint? closestWater,
  double closestDistanceMeters = 1000.0,
  double closestBearing = 187.0,
}) {
  WaterInfo info = WaterInfo(
    closestWater: closestWater, 
    closestDistanceMeters: closestDistanceMeters, 
    closestBearing: closestBearing);
  return info;
}


// ------------------------------------
// Tests
// ------------------------------------
void main() {

  group('WaypointDisplayCard', () {

    testWidgets('shows ActiveSetCard when set is loaded', (WidgetTester t) async {
      String sampleSetName = 'Test Trail Set';
      Widget w = testCard(setName: sampleSetName);
      await t.pumpWidget(w.withMaterial());
      t.exists<Text>(sampleSetName);
      t.anyExist<ActiveSetCard>();
    });
    
    testWidgets('shows NextWaypointCard', (WidgetTester t) async {
      UpcomingWaypoint nextWaypoint = mockUpcomingWaypoint();
      Widget w = testCard(nextWaypoint: nextWaypoint);
      await t.pumpWidget(w.withMaterial());
      t.anyExist<NextWaypointCard>();
      t.noneExist<EmptyStateCard>();
    });

    testWidgets('shows EmptyStateCard when no waypoints within range', (WidgetTester t) async {
      String sampleSetName = 'Test Set';
      Widget w = testCard(setName: sampleSetName);
      await t.pumpWidget(w.withMaterial());
      t.exists<Text>('No Nearby Waypoints');
      t.anyExist<EmptyStateCard>();
      t.noneExist<NextWaypointCard>();
    });

    testWidgets('shows UpcomingWaypointList when waypoints exist', (WidgetTester t) async {
      List<UpcomingWaypoint> waypointList = [
        mockUpcomingWaypoint(),
        mockUpcomingWaypoint()
      ];
      Widget w = testCard(upcomingWaypoints: waypointList);
      await t.pumpWidget(w.withMaterial());
      t.oneExists<UpcomingWaypointsList>();
    });

    testWidgets('shows ClosestWaterCard when water info available', (WidgetTester t) async {
      WaterInfo waterInfo = mockWaterInfo(closestWater: mockWaypoint());
      Widget w = testCard(waterInfo: waterInfo);
      await t.pumpWidget(w.withMaterial());
      t.oneExists<ClosestWaterCard>();
    });

    testWidgets('hides ClosestWaterCart when no water info available', (WidgetTester t) async {
      Widget w = testCard();
      await t.pumpWidget(w.withMaterial());
      t.noneExist<ClosestWaterCard>();
      t.exists<Text>('No water waypoints');
    });

  });

}