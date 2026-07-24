String defaultType = 'water';
double defaultLat = 40.0;
double defaultLon = -105.0;
String defaultName = 'Waypoint';

Map<String, int> get validHeaders => {
    'name': 0,
    'latitude': 1,
    'longitude': 2,
    'type': 3,
  };

Map<String, int> get headersWithSortOrder {
  final headers = {...validHeaders, 'sortorder': 4};
  return headers;
}

Map<String, dynamic> defaultWaypoint() {
    return customWaypoint();
  }

  ///
Map<String, dynamic> customWaypoint({
    String? name, 
    double? latitude, 
    double? longitude, 
    String? type, 
    double latOffset = 0.0, 
    double lonOffset = 0.0,
    int? sortOrder,
    }) {

    latitude = (latitude ?? defaultLat) + latOffset;
    longitude = (longitude ?? defaultLon) + lonOffset;

    return {
      'name': name ?? defaultName,
      'latitude': latitude,
      'longitude': longitude,
      'type': type ?? defaultType,
      'sortorder': sortOrder,
    };
  }


Map<String, dynamic> trailheadWaypoint() => customWaypoint(name: 'Trailhead', type:'trailhead');
Map<String, dynamic> waterWaypoint() => customWaypoint(name: 'Water Source', type: 'water');
Map<String, dynamic> junctionWaypoint() => customWaypoint(name: 'Junction', type: 'junction');
Map<String, dynamic> campWaypoint() => customWaypoint(name: 'Camp Site', type: 'camp');

List<Map<String, dynamic>> twoWaypoints() => [
    waterWaypoint(),
    trailheadWaypoint(),
  ];

List<Map<String, dynamic>> fourWaypoints() => [
    waterWaypoint(),
    trailheadWaypoint(),
    junctionWaypoint(),
    campWaypoint(),
  ];


String generateCsv({
  required int rows,
  List<String>? addColumns,
}) {
  final defaultCols = ['name', 'latitude', 'longitude', 'type'];
  List<String> cols = defaultCols;
  if (addColumns != null) {
    cols.addAll(addColumns);
  }

  final header = cols.join(',');
  final dataRows = List.generate(
    rows,
    (i) => cols.map((c) => 'value_$i').join(','),
  );
  return [header, ...dataRows].join('\n');
}


String get validCsvContent => '''name,latitude,longitude,type
  Water Source,35.0,-120.0,water
  Trailhead,35.1,-120.1,trailhead
  Junction,35.3,-120.3,junction''';

