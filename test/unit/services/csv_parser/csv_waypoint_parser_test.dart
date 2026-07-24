// import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/services/csv_parser/csv_waypoint_parser.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';

import '../../../helpers/csv_parser_mocks.dart';
import '../../../helpers/csv_parser_unit_test_data.dart' as testdata;

void main() {
  late MockHeaderValidator mockHeaderValidator;
  late MockRowParser mockRowParser;
  late CsvWaypointParser parser;


  setUp(() {
    mockHeaderValidator = MockHeaderValidator();
    mockRowParser = MockRowParser();

    parser = CsvWaypointParser(
      headerValidator: mockHeaderValidator,
      rowParser: mockRowParser,
    );
  });

  group('input validation', () {

    test('empty CSV returns error', () {
      const csvContent = '';

      final result = parser.parse(csvContent);

      expect(result.hasErrors, isTrue);
      expect(result.errors.length, 1);
      expect(result.errors.first.message, contains('empty'));
      expect(result.waypoints.length, 0);
    });

  });

  group('header validation', () {

    test('header error stops parsing', () {
      mockHeaderValidator.shouldReturnError(
        ParseError(0, 'Missing required column: latitude'),
      );
      const csvContent = 'name,type\nTrailhaed,water';

      final result = parser.parse(csvContent);

      expect(result.hasErrors, isTrue);
      expect(result.errors.length, 1);
      expect(result.errors.first.message, contains('latitude'));
      expect(result.waypoints.length, 0);
    });

    test('headersuccess proceeds to parse rows', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.validHeaders);
      mockRowParser.shouldReturnWaypoint(testdata.waterWaypoint());
      mockRowParser.shouldReturnWaypoint(testdata.trailheadWaypoint());

      final result = parser.parse(testdata.validCsvContent);

      expect(result.hasErrors, isFalse);
      expect(result.waypoints.length, 2);
      expect(result.waypoints[0]['name'], 'Water Source');
      expect(result.waypoints[1]['name'], 'Trailhead');
    });

  });

  group('row parsing', () {
  
    test('null waypoint from row parser is skippet', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.validHeaders);
      mockRowParser.shouldReturnWaypoint(testdata.waterWaypoint());
      mockRowParser.shouldReturnWaypoint(null);
      mockRowParser.shouldReturnWaypoint(testdata.trailheadWaypoint());

      final result = parser.parse(testdata.validCsvContent);

      expect(result.hasErrors, isFalse);
      expect(result.hasWarnings, isFalse);
      expect(mockRowParser.callCount, 3);
      expect(result.waypoints.length, 2);
    });

    test('exception during parsing returns error', () {
      String exceptionMessage = 'Mock row parser exception';
      mockHeaderValidator.shouldReturnHeaders(testdata.validHeaders);
      mockRowParser.shouldThrowException(message: exceptionMessage);

      final result = parser.parse(testdata.validCsvContent);

      expect(result.hasErrors, isTrue);
      expect(result.errors.first.message, contains('Failed to parse CSV')); // Standard message
      expect(result.errors.first.message, contains(exceptionMessage));   // exception details
    });
  
  });

  group('sortOrder validation', () {
  
    test('accepts all rows with sortOrder values', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.headersWithSortOrder);
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: 1));
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: 2));

      final result = parser.parse(testdata.generateCsv(rows: 2));

      expect(result.hasErrors, isFalse);
      expect(result.waypoints.length, 2);
    });

    test('fails when sortOrder values are mixed (int, null)', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.headersWithSortOrder);
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: 1));
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: null));

      final result = parser.parse(testdata.generateCsv(rows: 2));

      expect(result.hasErrors, isTrue);
      expect(result.errors.first.message, contains('Mixed sort order'));      
    });

    test('fails when sortOrder values are mixed (null, int)', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.headersWithSortOrder);
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: null));
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: 1));

      final result = parser.parse(testdata.generateCsv(rows: 2));

      expect(result.hasErrors, isTrue);
      expect(result.errors.first.message, contains('Mixed sort order'));      
    });

    test('fails when sortOrder values are mixed (int, int, null)', () {
    // test('B', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.headersWithSortOrder);
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: 1));
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: 2));
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: null));

      final result = parser.parse(testdata.generateCsv(rows: 3));

      expect(result.hasErrors, isTrue);
      expect(result.errors.first.message, contains('Mixed sort order'));      
    });

    test('fails when sortOrder values are mixed (null, int, null)', () {
    // test('A', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.headersWithSortOrder);
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: null));
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: 1));
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: null));

      final result = parser.parse(testdata.generateCsv(rows: 3));

      expect(result.waypoints.length, 2);
      expect(result.hasErrors, isTrue);
      expect(result.errors.first.message, contains('Mixed sort order'));      
    });

    test('failes when two or more rows have the same sortOrder value', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.headersWithSortOrder);
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: 5));
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(sortOrder: 5));
      final csv = testdata.generateCsv(rows: 2, addColumns: ['sortorder']);

      final result = parser.parse(csv);

      expect(result.hasErrors, isTrue);
      expect(result.errors.first.message, contains('Duplicate sortOrder'));
      expect(result.errors.first.message, contains('5'));

    });

  });

  group('duplicate waypoints', () {
  
    test('warns when two rows have the same lat,lon,type', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.validHeaders);
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint());
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint());

      final csv = testdata.generateCsv(rows: 2);

      final result = parser.parse(csv);

      expect(result.hasWarnings, isTrue);
      expect(result.warnings.first.message, contains('Duplicate waypoint'));
    });

    test('warns when two rows have the same lat,lon,type (more rows of data)', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.validHeaders);
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint());
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint(type: 'camp'));
      mockRowParser.shouldReturnWaypoint(testdata.customWaypoint());

      final csv = testdata.generateCsv(rows: 3);

      final result = parser.parse(csv);

      expect(result.hasWarnings, isTrue);
      expect(result.warnings.first.message, contains('Duplicate waypoint'));
    });

  });
}