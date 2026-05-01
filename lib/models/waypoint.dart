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

  Waypoint copyWith({
    int? id,
    int? setId,
    String? name,
    double? latitude,
    double? longitude,
    String? type,
    String? notes,
    String? direction,
    bool? enabled,
    List<Alert>? alerts,
  }) {
    return Waypoint(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      direction: direction ?? this.direction,
      enabled: enabled ?? this.enabled,
      alerts: alerts ?? this.alerts,
    );
  }

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
    id: json['id'] ?? Isar.autoIncrement,
    setId: json['setId'] ?? 0,
    name: json['name'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    type: json['type'],
    notes: json['notes'],
    direction: json['direction'],
    enabled: json['enabled'] ?? true,
    alerts: (json['alerts'] as List?)
      ?.map((a) => Alert.fromJson(a))
      .toList() ?? [],
  );

}

@embedded
class Alert {
  int distanceMeters;
  String priority;

  Alert({
    this.distanceMeters = 500,
    this.priority = 'normal',
  });

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
    distanceMeters: json['distanceMeters'],
    priority: json['priority'],
  );
}