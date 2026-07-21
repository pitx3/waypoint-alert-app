import 'package:csv/csv.dart';
import 'package:waypoint_alert_app/services/csv_parser/duplicate_detector.dart';
import 'package:waypoint_alert_app/services/csv_parser/header_validator.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_result.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_warning.dart';
import 'package:waypoint_alert_app/services/csv_parser/row_parser.dart';

class CsvWaypointParser {
  final HeaderValidator headerValidator;
  final RowParser rowParser;
  final DuplicateDetector duplicateDetector;

  CsvWaypointParser({
    required this.headerValidator,
    required this.rowParser,
    required this.duplicateDetector,
  });

  ParseResult parse(String csvContent) {
    final List<ParseError> errors = [];
    final List<ParseWarning> warnings = [];
    final List<Map<String, dynamic>> waypoints = [];

    try {
      
      final rows = const CsvDecoder().convert(csvContent);

      if (rows.isEmpty) {
        errors.add(ParseError(0, 'CSV file is empty'));
        return ParseResult(waypoints, errors, warnings);
      }

      final headerError = headerValidator.validate(rows[0]);
      if (headerError != null) {
        errors.add(headerError);
        return ParseResult(waypoints, errors, warnings);
      }

      final Map<String, int>? headers = headerValidator.normalize(rows[0]);

      // Parse Data Rows
      _RowsParseResult rpr = _parseRows(rows, headers);
      errors.addAll(rpr.errors);
      warnings.addAll(rpr.warnings);
      if (rpr.sortOrderMismatch) {
        return ParseResult(waypoints, errors, warnings);
      }
      waypoints.addAll(rpr.waypoints);

      if (errors.isEmpty) {
        duplicateDetector.detect(waypoints, warnings);
      }

    } catch (e) {
      errors.add(ParseError(0, 'Failed to parse CSV: ${e.toString()}'));
    }
  
    return ParseResult(waypoints, errors, warnings);
  }


  /// Private helper method to parse the set of rows
  _RowsParseResult _parseRows(
    List<List<dynamic>> rows,
    Map<String, int>? headers
  ) {
    _RowsParseResult rpr = _RowsParseResult();
    // iterate over the rows and parse them
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final rowNumber = i + 1; // this is correct!

      final waypoint = rowParser.parse(
       row,
       headers,
       rowNumber,
       rpr.errors,
       rpr.warnings,
      );
      

      if (waypoint != null) {
        rpr.waypoints.add(waypoint);
      }

      if (rowParser.sortOrderMismatch) {
        rpr.errors.add(ParseError(
          0, 'Mixed sortOrder: some rows have values, others are empty'
        ));
        return rpr;
      }
    }

    return rpr;
  }

}

class _RowsParseResult {
  bool sortOrderMismatch = false;
  final List<ParseError> errors = [];
  final List<ParseWarning> warnings = [];
  final List<Map<String, dynamic>> waypoints = [];

  _RowsParseResult();
}