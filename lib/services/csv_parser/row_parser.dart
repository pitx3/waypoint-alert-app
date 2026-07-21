import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_warning.dart';

class RowParser {
  bool sortOrderMismatch = false;

  RowParser();

  Map<String, dynamic>? parse(
        List<dynamic> row,
        Map<String, int>? headers,
        int rowNumber,
        List<ParseError> errors,
        List<ParseWarning> warnings,
      ) {
      Map<String, dynamic>? result;
      return result;
  }
}