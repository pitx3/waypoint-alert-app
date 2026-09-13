import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/enums/waypoint_type.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_warning.dart';
import 'package:waypoint_alert_app/services/csv_parser/row_parser.dart';

import '../../../helpers/csv_parser_unit_test_data.dart' as testdata;

void main() {
  late RowParser parser;
  late List<ParseError> errors;
  late List<ParseWarning> warnings;
  late Map<String, int> headers;

  setUp(() {
    parser = RowParser();
    errors = [];
    warnings = [];
    headers = testdata.requiredHeaders;
  });

  group('parse() - required fields', () {
    test('parses valid row with all required fields', () {
      final row = ['Trailhead', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['name'], 'Trailhead');
      expect(result['latitude'], 35.0);
      expect(result['longitude'], -120.0);
      expect(result['type'], WaypointType.trailhead);
      expect(errors, isEmpty);
    });
  });

  group('parse() - missing columns', () {
    test('returns error if "name" column is missing from row', () {
      final headers = {'latitude': 0, 'longitude': 1, 'type': 2, 'name': 3};
      final row = ['35.0', '-120.0', ''];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('name'));
    });

    test('returns error if "latitude" column is missing from row', () {
      final headers = {'name': 0, 'longitude': 1, 'type': 2, 'latitude': 3};
      final row = ['Trailhead', '35.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('latitude'));
    });

    test('returns error if "longitude" column is missing from row', () {
      final headers = {'latitude': 0, 'name': 1, 'type': 2, 'longitude': 3};
      final row = ['35.0', 'Trailhead', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('longitude'));
    });

    test('returns error if "type" column is missing from row', () {
      final headers = {'latitude': 0, 'name': 1, 'longitude': 2, 'type': 3};
      final row = ['35.0', 'Trailhead', '120.0'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('type'));
    });

    test('multiple errors if multiple missing columns', () {
      final headers = {'latitude': 0, 'name': 1, 'longitude': 2, 'type': 3};
      final row = ['35.0'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 3);
      expect(errors[0].message, contains('name'));
      expect(errors[1].message, contains('longitude'));
      expect(errors[2].message, contains('type'));
    });
  });

  group('parse() - name field validation', () {
    test('returns null and error when name is empty', () {
      final row = ['', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('name'));
    });

    test('returns null and error when name is whitespace only', () {
      final row = ['   ', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('name'));
    });

    test('trims leading and trailing whitespace from name', () {
      final row = ['  Trailhead  ', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['name'], 'Trailhead');
      expect(errors, isEmpty);
    });
  });

  group('parse() - latitude field validation', () {
    test('returns error when latitude field non-numeric', () {
      final row = ['Trailhead', 'abc', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('latitude'));
      expect(errors.first.message, contains('abc'));
    });

    test('returns error when latitude field greater than 90', () {
      final row = ['Trailhead', '95.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('latitude'));
      expect(errors.first.message, contains('"95.0"'));
    });

    test('returns error when latitude field less than -90', () {
      final row = ['Trailhead', '-95.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('latitude'));
      expect(errors.first.message, contains('"-95.0"'));
    });

    test('accepts latitude of exactly 90', () {
      final row = ['Trailhead', '90.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(errors, isEmpty);
      expect(result!['latitude'], 90.0);
    });

    test('accepts latitude of exactly -90', () {
      final row = ['Trailhead', '-90.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(errors, isEmpty);
      expect(result!['latitude'], -90.0);
    });

    test('returns error when latitude is whitespace only', () {
      final row = ['Trailhead', '  ', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('latitude'));
      expect(errors.first.message, contains(""));
    });

    test('returns error when latitude is nonsense value', () {
      final row = ['Trailhead', '35.2ab', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('latitude'));
      expect(errors.first.message, contains("35.2ab"));
    });
  });

  group('parse() - longitude field validation', () {
    test('returns error when longitude field non-numeric', () {
      final row = ['Trailhead', '35', 'abc', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('longitude'));
      expect(errors.first.message, contains('abc'));
    });

    test('returns error when longitude field greater than 180', () {
      final row = ['Trailhead', '35.0', '200.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('longitude'));
      expect(errors.first.message, contains('"200.0"'));
    });

    test('returns error when longitude field less than -10', () {
      final row = ['Trailhead', '-35.0', '-190.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('longitude'));
      expect(errors.first.message, contains('"-190.0"'));
    });

    test('accepts longitude of exactly 180', () {
      final row = ['Trailhead', '35.0', '180.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(errors, isEmpty);
      expect(result!['longitude'], 180.0);
    });

    test('accepts longitude of exactly -180', () {
      final row = ['Trailhead', '35.0', '-180.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(errors, isEmpty);
      expect(result!['longitude'], -180.0);
    });

    test('returns error when longitude is whitespace only', () {
      final row = ['Trailhead', '35', '   ', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('longitude'));
      expect(errors.first.message, contains(""));
    });

    test('returns error when longitude is nonsense value', () {
      final row = ['Trailhead', '35.0', '25.3ab', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('longitude'));
      expect(errors.first.message, contains("25.3ab"));
    });
  });

  group('parse() - type field validation', () {
    test('parses valid type "water"', () {
      final row = ['Trailhead', '35.0', '-120.0', 'water'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['type'], WaypointType.water);
      expect(errors, isEmpty);
      expect(warnings, isEmpty);
    });

    /*
  unknown,
  none,
  water,
  trailhead,
  camp,
  junction;

*/
    test('parses valid type "water"', () {
      final row = ['Trailhead', '35.0', '-120.0', 'water'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['type'], WaypointType.water);
      expect(errors, isEmpty);
      expect(warnings, isEmpty);
    });

    test('parses valid type "trailhead"', () {
      final row = ['Trailhead', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['type'], WaypointType.trailhead);
      expect(errors, isEmpty);
      expect(warnings, isEmpty);
    });

    test('parses valid type "camp"', () {
      final row = ['Trailhead', '35.0', '-120.0', 'camp'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['type'], WaypointType.camp);
      expect(errors, isEmpty);
      expect(warnings, isEmpty);
    });

    test('parses valid type "junction"', () {
      final row = ['Trailhead', '35.0', '-120.0', 'junction'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['type'], WaypointType.junction);
      expect(errors, isEmpty);
      expect(warnings, isEmpty);
    });

    test('parses valid type "none"', () {
      final row = ['Trailhead', '35.0', '-120.0', 'none'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['type'], WaypointType.none);
      expect(errors, isEmpty);
      expect(warnings, isEmpty);
    });

    test('returns warning and sets type to "none" when type is empty', () {
      final row = ['Trailhead', '35.0', '-120.0', ''];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(errors, isEmpty);
      expect(result!['type'], WaypointType.none);
      expect(warnings.length, 1);
      expect(warnings.first.message, contains('type'));
      expect(warnings.first.message, contains('"None"'));
    });

    test('returns warning and sets type to "unknown" when type is invalid', () {
      final row = ['Trailhead', '35.0', '-120.0', 'spaceport'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(errors, isEmpty);
      expect(result!['type'], WaypointType.unknown);
      expect(warnings.length, 1);
      expect(warnings.first.message, contains('type'));
      expect(warnings.first.message, contains('"Unknown"'));
      expect(warnings.first.message, contains('"spaceport"'));
    });
  });

  group('parse() - sortOrder field validation', () {
    test('parses valid sortOrder', () {
      final headers = {
        'sortorder': 0,
        'name': 1,
        'latitude': 2,
        'longitude': 3,
        'type': 4,
      };
      final row = ['5', 'Trailhead', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['sortOrder'], 5);
      expect(errors, isEmpty);
    });

    test('returns error when sortOrder value is missing but header exists', () {
      final headers = {
        'name': 0,
        'latitude': 1,
        'longitude': 2,
        'type': 3,
        'sortorder': 4,
      };
      final row = ['Trailhead', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('sortOrder'));
    });

    test('returns error when sortOrder is non-numeric', () {
      final headers = {
        'sortorder': 0,
        'name': 1,
        'latitude': 2,
        'longitude': 3,
        'type': 4,
      };
      final row = ['abc', 'Trailhead', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('sortOrder'));
      expect(errors.first.message, contains('"abc"'));
    });

    test('returns error when sortOrder is not an integer', () {
      final headers = {
        'sortorder': 0,
        'name': 1,
        'latitude': 2,
        'longitude': 3,
        'type': 4,
      };
      final row = ['294.5', 'Trailhead', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNull);
      expect(errors.length, 1);
      expect(errors.first.message, contains('sortOrder'));
      expect(errors.first.message, contains('"294.5"'));
    });

    test('does not add sortOrder when column is not in headers', () {
      final row = [
        'Trailhead',
        '35.0',
        '-120.0',
        'trailhead',
        '5',
      ]; // extra value at end!

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!.containsKey('sortOrder'), isFalse);
      expect(errors, isEmpty);
    });

    test('parses sortOrder of zero successfully', () {
      final headers = {
        'sortorder': 0,
        'name': 1,
        'latitude': 2,
        'longitude': 3,
        'type': 4,
      };
      final row = ['0', 'Trailhead', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['sortOrder'], 0);
      expect(errors, isEmpty);
    });

    test('parses negative sortOrder successfully', () {
      final headers = {
        'sortorder': 0,
        'name': 1,
        'latitude': 2,
        'longitude': 3,
        'type': 4,
      };
      final row = ['-5', 'Trailhead', '35.0', '-120.0', 'trailhead'];

      final result = parser.parse(row, headers, 1, errors, warnings);

      expect(result, isNotNull);
      expect(result!['sortOrder'], -5);
      expect(errors, isEmpty);
    });
  });
}
