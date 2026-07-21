import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_warning.dart';

class ParseResult {
  final List<Map<String, dynamic>> waypoints;
  final List<ParseError> errors;
  final List<ParseWarning> warnings;

  ParseResult(this.waypoints, this.errors, this.warnings);

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

}