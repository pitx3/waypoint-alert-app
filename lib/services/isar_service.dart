import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/models/waypoint_set.dart';

class IsarService {
  late final Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [WaypointSetSchema, WaypointSchema],
      directory: dir.path,
      // TODO: add encryption keys later
    );
  }

  Isar get instance => _isar;
}