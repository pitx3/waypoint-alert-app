import 'package:waypoint_alert_app/enums/waypoint_type.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_error.dart';
import 'package:waypoint_alert_app/services/csv_parser/models/parse_warning.dart';

class RowParser {
  Map<String, dynamic>? parse(
    List<dynamic> row,
    Map<String, int> headers,
    int rowNumber,
    List<ParseError> errors,
    List<ParseWarning> warnings,
  ) {
    final waypoint = <String, dynamic>{};
    bool hasErrors = false;

    // Name
    final nameIndex = headers['name']!;
    if (nameIndex >= row.length || row[nameIndex].toString().trim().isEmpty) {
      errors.add(ParseError(rowNumber, 'Missing required field: name'));
      hasErrors = true;
    } else {
      waypoint['name'] = row[nameIndex].toString().trim();
    }

    // Latitude
    final latIndex = headers['latitude']!;
    if (latIndex >= row.length) {
      errors.add(ParseError(rowNumber, 'Missing required field: latitude'));
      hasErrors = true;
    } else {
      final latString = row[latIndex].toString().trim();
      final latValue = double.tryParse(latString);
      if (latValue == null || latValue < -90 || latValue > 90) {
        errors.add(
          ParseError(
            rowNumber,
            'Invalid longitude "$latString" (must be a number between -90 and 90)',
          ),
        );
        hasErrors = true;
      } else {
        waypoint['latitude'] = latValue;
      }
    }

    // Longitude
    final lonIndex = headers['longitude']!;
    if (lonIndex >= row.length) {
      errors.add(ParseError(rowNumber, 'Missing required field: longitude'));
      hasErrors = true;
    } else {
      final lonString = row[lonIndex].toString().trim();
      final lonValue = double.tryParse(lonString);
      if (lonValue == null || lonValue < -180 || lonValue > 180) {
        errors.add(
          ParseError(
            rowNumber,
            'Invalid longitude "$lonString" (must be a number between -180 and 180)',
          ),
        );
        hasErrors = true;
      } else {
        waypoint['longitude'] = double.parse(row[lonIndex].toString().trim());
      }
    }

    // Type
    final typeIndex = headers['type']!;
    if (typeIndex >= row.length) {
      errors.add(ParseError(rowNumber, 'Missing required field: type'));
      hasErrors = true;
    } else {
      final typeValue = row[typeIndex].toString().trim();
      WaypointType? finalType = WaypointType.fromString(typeValue);
      if (finalType == null) {
        if (typeValue.isEmpty) {
          finalType = WaypointType.none;
          warnings.add(
            ParseWarning(rowNumber, 'Missing type. "None" substituted'),
          );
        } else {
          finalType = WaypointType.unknown;
          warnings.add(
            ParseWarning(
              rowNumber,
              'Invalid type "$typeValue". "Unknown" substituted.',
            ),
          );
        }
      }
      waypoint['type'] = finalType;
    }

    return hasErrors ? null : waypoint;
  }
}
