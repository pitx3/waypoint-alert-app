class Waypoint {
  int id;
  int setId;
  String name;
  double latitude;
  double longitude;
  String type;
  String? notes;
  String? direction;
  bool enabled;
  List<Alert> alerts;

  Waypoint({
    required this.id,
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

class Alert {
  int distanceMeters;
  String priority;

  Alert({
    required this.distanceMeters,
    this.priority = 'normal',
  });
}