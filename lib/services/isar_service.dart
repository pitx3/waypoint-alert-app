import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/models/waypoint_set.dart';

class IsarService {
  late final Isar _isar;

  Future<void> init({String? directory, bool inspector = false}) async {
    String? dbPath;
    if (directory != null) {
      dbPath = directory;
    } else {
      dynamic dir = await getApplicationDocumentsDirectory();
      dbPath = dir.path;
    }
    
    _isar = await Isar.open(
      [WaypointSetSchema, WaypointSchema],
      directory: dbPath ?? '',
      inspector: inspector,
      // TODO: add encryption keys later
    );
  }

  Isar get instance => _isar;

  Future<void> close() async {
    await _isar.close();
  }
}