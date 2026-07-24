import 'package:csv/csv.dart';
import 'package:waypoint_alert_app/services/csv_parser/header_validator.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_result.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_warning.dart';
import 'package:waypoint_alert_app/services/csv_parser/row_parser.dart';

class CsvWaypointParser {
  final HeaderValidator headerValidator;
  final RowParser rowParser;

  // bool _sortOrderMismatch = false;

  CsvWaypointParser({
    required this.headerValidator,
    required this.rowParser,
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

      final Map<String, int> headers = headerValidator.normalize(rows[0]);

      // Parse Data Rows
      _RowsParseResult rpr = _parseRows(rows, headers, errors, warnings);
      errors.addAll(rpr.errors);
      warnings.addAll(rpr.warnings);
      // if (rpr.sortOrderMismatch) {
      //   return ParseResult(waypoints, errors, warnings);
      // }
      waypoints.addAll(rpr.waypoints);

    } catch (e) {
      errors.add(ParseError(0, 'Failed to parse CSV: ${e.toString()}'));
    }
  
    return ParseResult(waypoints, errors, warnings);
  }


  /// Private helper method to parse the set of rows
  _RowsParseResult _parseRows(
    List<List<dynamic>> rows,
    Map<String, int> headers,
    List<ParseError> errors,
    List<ParseWarning> warnings,
  ) {
    bool? hasSortOrder;
    final Map<int, int> seenSortOrders = {};
    final Map<String, int> seenWaypoints = {};

    _RowsParseResult rpr = _RowsParseResult();
    // iterate over the rows and parse them
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final rowNumber = i + 1; // this is correct!
      int? sortOrder;

      final waypoint = rowParser.parse(
       row,
       headers,
       rowNumber,
       rpr.errors,
       rpr.warnings,
      );
      
      if (waypoint != null) {
        rpr.waypoints.add(waypoint);
        sortOrder = waypoint['sortorder'] as int?;
        hasSortOrder ??= (sortOrder != null);

        // Duplicate waypoint check
        final key = '${waypoint['latitude']}:${waypoint['longitude']}:${waypoint['type']}';
        if (seenWaypoints.containsKey(key)) {
          warnings.add(ParseWarning(
            rowNumber,
            'Duplicate waypoint (same lat,long,type)',
            [seenWaypoints[key]!, rowNumber]
          ));
        } else {
          seenWaypoints[key] = rowNumber; 
        }
      }

      // sort order mismatch check
      if (hasSortOrder! == (sortOrder == null)) {
        rpr.errors.add(ParseError(
          0, 'Mixed sort order: some rows have values, others are empty'
        ));
        return rpr;
      }

      // duplicate sort order check
      if (sortOrder != null) {
        if (seenSortOrders.containsKey(sortOrder)) {
          errors.add(ParseError(
            rowNumber,
            'Duplicate sortOrder value: $sortOrder (first seen in row ${seenSortOrders[sortOrder]})',
          ));
        } else {
          seenSortOrders[sortOrder] = rowNumber;
        }
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