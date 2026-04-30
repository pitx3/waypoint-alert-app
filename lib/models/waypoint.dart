import 'package:isar_community/isar.dart';

part 'waypoint.g.dart';

@collection
class Waypoint {
  Id id = Isar.autoIncrement;
  int setId;

  @Index()
  String name;

  @Index()
  double latitude;

  @Index()
  double longitude;

  @Index()
  String type;
  String? notes;
  String? direction;
  bool enabled;
  List<Alert> alerts;

  Waypoint({
    this.id = Isar.autoIncrement,
    required this.setId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.notes,
    this.direction,
    this.enabled = true,
    required this.alerts,
  });

}

@embedded
class Alert {
  int distanceMeters;
  String priority;

  Alert({
    this.distanceMeters = 500,
    this.priority = 'normal',
  });
}