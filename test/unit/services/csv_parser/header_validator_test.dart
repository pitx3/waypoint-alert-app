import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/services/csv_parser/header_validator.dart';

void main() {
  late HeaderValidator validator;

  setUp(() {
    validator = HeaderValidator();
  });

  group('validate()', () {

    test('returns null when all required columns are present', () {
      final headers = ['name', 'latitude', 'longitude', 'type'];

      final result = validator.validate(headers);

      expect(result, isNull);
    });

    test('returns error when "type" column is missing', () {
      final headers = ['name', 'latitude', 'longitude'];

      final result = validator.validate(headers);

      expect(result, isNotNull);
      expect(result!.message, contains('type'));
    });

    test('is case-insensitive', () {
      final headers = ['NAME', 'Latitude', 'lOnGitude', 'TypE'];

      final result = validator.validate(headers);

      expect(result, isNull);
    });

    test('ignores extra columns', () {
      final headers = ['name', 'latitude', 'longitude', 'type', 'foo', 'bar', 'baz'];

      final result = validator.validate(headers);
      
      expect(result, isNull);
    });

    test('returns error when header row is empty', () {
      final headers = <String>[];

      final result = validator.validate(headers);

      expect(result, isNotNull);
      expect(result!.message, contains('name'));
    });
  
  });

  group('normalize', () {

    test('returns correct column indices', () {
      final headers = ['name', 'latitude', 'longitude', 'type'];

      final result = validator.normalize(headers);

      expect(result['name'], 0);
      expect(result['latitude'], 1);
      expect(result['longitude'], 2);
      expect(result['type'], 3);
    });

    test('converts headers to lowercase', () {
      final headers = ['NAME', 'Latitude', 'lONGiTude', 'typE'];

      final result = validator.normalize(headers);

      expect(result.containsKey('name'), isTrue);
      expect(result.containsKey('latitude'), isTrue);
      expect(result.containsKey('longitude'), isTrue);
      expect(result.containsKey('type'), isTrue);
      expect(result['name'], 0);
      expect(result['latitude'], 1);
    });

    test('trims whitespace from headers', () {
      final headers = ['name ', ' latitude', '  longitude', ' type '];

      final result = validator.normalize(headers);

      expect(result.containsKey('name'), isTrue);
      expect(result.containsKey('latitude'), isTrue);
      expect(result.containsKey('longitude'), isTrue);
      expect(result.containsKey('type'), isTrue);
    });
  
  });

}