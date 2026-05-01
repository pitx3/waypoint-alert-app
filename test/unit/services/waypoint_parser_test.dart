import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/services/waypoint_parser.dart';

void main() {
  group('WaypointParser', () {
    testWidgets('parses JSON string directly', (tester) async {
      const testJson = '''
{
  "waypoints": [
    {
      "name": "Test Waypoint",
      "latitude": 39.5,
      "longitude": -106.5,
      "type": "water",
      "notes": "Test notes",
      "direction": null,
      "enabled": true,
      "alerts": [
        {"distanceMeters": 500, "priority": "normal"}
      ]
    }
  ]
}
      ''';

      final waypoints = WaypointParser.parseFromString(testJson, 42);

      expect(waypoints.length, 1, reason: 'Should parse exactly one waypoint');
      expect(waypoints.first.name, 'Test Waypoint');
      expect(waypoints.first.setId, 42);
      expect(waypoints.first.alerts.length, 1);
      expect(waypoints.first.alerts.first.distanceMeters, 500);
    });
  });
}