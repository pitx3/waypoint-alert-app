import 'dart:collection';

import 'package:waypoint_alert_app/services/csv_parser/header_validator.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_warning.dart';
import 'package:waypoint_alert_app/services/csv_parser/row_parser.dart';

/// MockHeaderValidator 
/// set the error to return (or leave null)
/// set the headers to return (or leave empty)
class MockHeaderValidator implements HeaderValidator {
  ParseError? _errorToReturn;
  Map<String, int> _headersToReturn = {};

  void shouldReturnError(ParseError error) => _errorToReturn = error;
  void shouldReturnHeaders(Map<String, int> headers) => _headersToReturn = headers;

  @override
  ParseError? validate(List<dynamic> headerRow) => _errorToReturn;

  @override
  Map<String, int> normalize(List<dynamic> headerRow) => _headersToReturn;
}

/// MockRowParser
/// (something goes here)
class MockRowParser implements RowParser {
  final Queue<Map<String, dynamic>?> _returnValues = Queue();
  bool _sortOrderMismatch = false;
  int _callCount = 0;
  bool _shouldThrow = false;
  String _exceptionMessage = 'Mock row parser exception';

  void shouldReturnWaypoint(Map<String, dynamic>? waypoint) => _returnValues.add(waypoint);
  void shouldHaveSortOrderMismatch(bool value) => _sortOrderMismatch = value;
  void shouldThrowException({String? message}) {
    _shouldThrow = true;
    _exceptionMessage = message ?? _exceptionMessage;
  }

  int get callCount => _callCount;

  @override
  bool sortOrderMismatch = false;

  @override
  Map<String, dynamic>? parse(
    List<dynamic> row,
    Map<String, int> headers,
    int rowNumber,
    List<ParseError> errors,
    List<ParseWarning> warnings,
  ) {
    if (_shouldThrow) {
      throw Exception(_exceptionMessage);
    }
    
    sortOrderMismatch = _sortOrderMismatch;
    _callCount++;
    
    if (_returnValues.isNotEmpty) {
      return _returnValues.removeFirst();
    }
    return null;
  }
}
