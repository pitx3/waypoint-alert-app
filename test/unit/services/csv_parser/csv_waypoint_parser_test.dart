// import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/services/csv_parser/csv_waypoint_parser.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_warning.dart';

import '../../../helpers/csv_parser_mocks.dart';
import '../../../helpers/csv_parser_unit_test_data.dart' as testdata;

void main() {
  late MockHeaderValidator mockHeaderValidator;
  late MockRowParser mockRowParser;
  late MockDuplicateDetector mockDuplicateDetector;
  late CsvWaypointParser parser;


  setUp(() {
    mockHeaderValidator = MockHeaderValidator();
    mockRowParser = MockRowParser();
    mockDuplicateDetector = MockDuplicateDetector();

    parser = CsvWaypointParser(
      headerValidator: mockHeaderValidator,
      rowParser: mockRowParser,
      duplicateDetector: mockDuplicateDetector,
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

  group('fail fast', () {

    test('sortOrder mistmatch fails fast', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.validHeaders);
      mockRowParser.shouldReturnWaypoint(testdata.waterWaypoint());
      mockRowParser.shouldHaveSortOrderMismatch(true);

      final result = parser.parse(testdata.validCsvContent);

      expect(result.hasErrors, isTrue);
      expect(result.errors.first.message, contains('Mixed sortOrder'));
      expect(mockDuplicateDetector.wasCalled, isFalse);
    });

  });

  group('duplicate detection', () {
  
    test('duplicate detector called when no errors', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.validHeaders);
      mockRowParser.shouldReturnWaypoint(testdata.waterWaypoint());
      mockRowParser.shouldReturnWaypoint(testdata.trailheadWaypoint());

      parser.parse(testdata.validCsvContent);

      expect(mockDuplicateDetector.wasCalled, isTrue);
    });

    test('duplicate detector warnings added to result', () {
      mockHeaderValidator.shouldReturnHeaders(testdata.validHeaders);
      mockRowParser.shouldReturnWaypoint(testdata.waterWaypoint());
      mockRowParser.shouldReturnWaypoint(testdata.trailheadWaypoint());
      mockDuplicateDetector.shouldAddWarnings([
        ParseWarning(1, 'Duplicate waypoints', [1,2]),
      ]);

      final result = parser.parse(testdata.validCsvContent);

      expect(result.hasWarnings, isTrue);
      expect(result.warnings.length, 1);
      expect(result.warnings.first.message, contains('Duplicate'));
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
      expect(mockDuplicateDetector.wasCalled, isFalse);
    });
  
  });

}