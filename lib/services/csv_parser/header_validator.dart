import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';

class HeaderValidator {

  static const List<String> _requiredColumns = [
    'name', 'latitude', 'longitude', 'type',
  ];

  /// Validates that all required columns exist in the CSV header row.
  /// 
  /// Checks for the presense of required columns
  /// Column matching is case-insensitive
  /// 
  /// Returns [null] if all required columns are present
  /// Returns a [ParseError] if any required column is missing
  ParseError? validate(List<dynamic> headerRow) {
    final headers = _normalize(headerRow);

    for (final column in _requiredColumns) {
      if (!headers.containsKey(column)) {
        return ParseError(0, 'Missing required column: $column');
      }
    }

    return null;
  }

  /// Normalizes the header row into a lowercase column-name-to-index map.
  ///
  /// Converts all header names to lowercase and trims whitespace
  /// This map is used by [RowParser] to locate column indices for each field.
  /// 
  /// Example: '['name', 'latitude', 'longitude', 'type']' becomes
  /// '{'name: 0, 'latitude': 1, 'longitude': 2, 'type': 3}'
  Map<String, int> normalize(List<dynamic> headerRow) {
    return _normalize(headerRow);
  }

  Map<String, int> _normalize(List<dynamic> headerRow) {
    final headers = <String, int>{};

    for (var i = 0; i < headerRow.length; i++) {
      final header = headerRow[i].toString().trim().toLowerCase();
      headers[header] = i;
    }
    return headers;
  }
}