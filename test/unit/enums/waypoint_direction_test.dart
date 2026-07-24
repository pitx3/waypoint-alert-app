import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/enums/waypoint_direction.dart';

void main() {

  group('fromString()', () {
  
    test('handles lowercase with hyphens', () {
      expect(WaypointDirection.fromString('slight-left'), equals(WaypointDirection.slightLeft));
      expect(WaypointDirection.fromString('hard-right'), equals(WaypointDirection.hardRight));
    });

    test('handles mixed case', () {
      expect(WaypointDirection.fromString('LEFT'), equals(WaypointDirection.left));
      expect(WaypointDirection.fromString('Straight'), equals(WaypointDirection.straight));
    });

    test('handles no hyphens', () {
      expect(WaypointDirection.fromString('slightright'), equals(WaypointDirection.slightRight));
      expect(WaypointDirection.fromString('uTurn'), equals(WaypointDirection.uTurn));
    });

    test('returns null for invalid values', () {
      expect(WaypointDirection.fromString('blbnaw3'), isNull);
      expect(WaypointDirection.fromString(''), isNull);
    });

  });

  group('displayName', () {
    
    test('formats with spaces and capitals', () {
      expect(WaypointDirection.slightLeft.displayName, equals('Slight Left'));
      expect(WaypointDirection.uTurn.displayName, equals('U-Turn'));
    });

  });

}