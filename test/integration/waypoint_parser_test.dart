import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/services/waypoint_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WaypointParser',() {
    testWidgets('parses JSON file from assets', (tester) async {
      final waypoints = await WaypointParser.parseFromFile(
        assetPath: 'assets/data-samples/waypoints-sample.json',
        setId: 1,
      );

      expect(waypoints.isNotEmpty, true, reason: 'Should parse at least one waypoint');

      // Test first waypoint
      final first = waypoints.first;
      expect(first.setId, 1, reason: 'setId should be assigned');
      expect(first.name.isNotEmpty, true, reason: 'name should not be empty');
      expect(first.latitude, isNot(equals(0.0)), reason: 'latitude should be valid');
      expect(first.longitude, isNot(equals(0.0)), reason: 'longitide should be valid');
      expect(first.type.isNotEmpty, true, reason: 'type should not be empty');

      // Test alerts if present
      if (first.alerts.isNotEmpty) {
        final firstAlert = first.alerts.first;
        expect(firstAlert.distanceMeters, greaterThan(0), reason: 'alert distance should be positive');
        expect(firstAlert.priority.isNotEmpty, true, reason: 'priority should not be empty');
      }
    });
  });
}