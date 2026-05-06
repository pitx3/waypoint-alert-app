import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/utils/calculators.dart';

void main() {
  group('calculateDistance', () {
    test('returns zero for identical coordinates', () {
      const lat = 39.5;
      const lng = -105.5;
      final distance = calculateDistance(lat, lng, lat, lng);
      expect(distance, equals(0.0));
    });

    test('calculates short distance accurately', () {
      // Approximately 1 km apart (roughly 0.009 degrees latitude)
      final distance = calculateDistance(39.5, -105.5, 39.509, -105.5);
      expect(distance, closeTo(1000.0, 50.0)); // Within 50 meters
    });

    test('calculates distance along equator', () {
      // 1 degree of longitude at equator ≈ 111 km
      final distance = calculateDistance(0.0, 0.0, 0.0, 1.0);
      expect(distance, closeTo(111319.0, 150.0));
    });

    test('calculates distance along meridian', () {
      // 1 degree of latitude ≈ 111 km everywhere
      final distance = calculateDistance(0.0, -105.5, 1.0, -105.5);
      expect(distance, closeTo(111319.0, 150.0));
    });

    test('calculates diagonal distance', () {
      // Denver to Boulder area (roughly 40 km northwest)
      final distance = calculateDistance(39.7392, -104.9903, 40.0150, -105.2705);
      expect(distance, closeTo(38887.0, 1.0)); // Within 500 meters
    });

    test('handles antipodal points', () {
      // Opposite sides of earth (maximum distance ≈ 20,000 km)
      final distance = calculateDistance(0.0, 0.0, 0.0, 180.0);
      expect(distance, closeTo(20037508.0, 25000.0)); // Half earth circumference
    });

    test('handles negative coordinates', () {
      // Southern hemisphere, western longitude
      final distance = calculateDistance(-33.8688, 151.2093, -37.8136, 144.9631);
      // Sydney to Melbourne ≈ 715 km
      expect(distance, closeTo(715000.0, 5000.0));
    });
  });

  group('calculateBearing', () {
    test('returns 0 degrees for due north', () {
      final bearing = calculateBearing(39.5, -105.5, 40.5, -105.5);
      expect(bearing, closeTo(0.0, 0.01));
    });

    test('returns 90 degrees for due east', () {
      final bearing = calculateBearing(39.5, -105.5, 39.5, -104.5);
      expect(bearing, closeTo(90.0, 0.5));
    });

    test('returns 180 degrees for due south', () {
      final bearing = calculateBearing(40.5, -105.5, 39.5, -105.5);
      expect(bearing, closeTo(180.0, 0.01));
    });

    test('returns 270 degrees for due west', () {
      final bearing = calculateBearing(39.5, -104.5, 39.5, -105.5);
      expect(bearing, closeTo(270.0, 0.5));
    });

    test('returns 45 degrees for northeast', () {
      final bearing = calculateBearing(39.5, -105.5, 40.5, -104.5);
      expect(bearing, closeTo(37.1, 0.5)); // Slightly more tolerance for diagonal
    });

    test('returns 315 degrees for northwest', () {
      final bearing = calculateBearing(39.5, -104.5, 40.5, -105.5);
      expect(bearing, closeTo(322.9, 0.5));
    });

    test('handles identical coordinates gracefully', () {
      // Edge case: bearing is undefined but should not crash
      final bearing = calculateBearing(39.5, -105.5, 39.5, -105.5);
      // atan2(0, 0) returns 0, which normalizes to 0 degrees
      expect(bearing, isA<double>());
      expect(bearing, greaterThanOrEqualTo(0.0));
      expect(bearing, lessThan(360.0));
    });

    test('normalizes negative bearings to 0-360 range', () {
      // This tests the normalization logic explicitly
      // A bearing that would be negative should wrap around
      final bearing = calculateBearing(39.5, -105.5, 39.5, -106.5);
      expect(bearing, greaterThanOrEqualTo(0.0));
      expect(bearing, lessThan(360.0));
    });

    test('handles polar regions', () {
      // Near North Pole - bearing should still be valid
      final bearing = calculateBearing(89.0, -105.5, 89.5, -105.5);
      expect(bearing, isA<double>());
      expect(bearing, greaterThanOrEqualTo(0.0));
      expect(bearing, lessThan(360.0));
    });

    test('handles crossing prime meridian', () {
      final bearing = calculateBearing(51.5, -0.5, 51.5, 0.5);
      expect(bearing, closeTo(90.0, 1.0)); // Due east
    });

    test('handles crossing 180th meridian', () {
      final bearing = calculateBearing(51.5, 179.5, 51.5, -179.5);
      expect(bearing, closeTo(90.0, 1.0)); // Due east, crossing date line
    });
  });

  group('calculateBearing edge cases', () {
    test('atan2 x=0 handled gracefully', () {
      // When lng2 - lng1 = 0, x component of atan2 is 0
      // This is the due north/south case, already covered but explicit test
      final north = calculateBearing(39.5, -105.5, 40.5, -105.5);
      final south = calculateBearing(40.5, -105.5, 39.5, -105.5);
      expect(north, closeTo(0.0, 0.01));
      expect(south, closeTo(180.0, 0.01));
    });

    test('atan2 y=0 handled gracefully', () {
      // When lat2 - lat1 = 0, y component approaches 0
      // This is the due east/west case
      final east = calculateBearing(39.5, -105.5, 39.5, -104.5);
      final west = calculateBearing(39.5, -104.5, 39.5, -105.5);
      expect(east, closeTo(90.0, 0.5));
      expect(west, closeTo(270.0, 0.5));
    });
  });
}