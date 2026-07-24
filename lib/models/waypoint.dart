import 'package:isar_community/isar.dart';
import 'package:waypoint_alert_app/enums/alert_priority.dart';
import 'package:waypoint_alert_app/enums/waypoint_direction.dart';
import 'package:waypoint_alert_app/enums/waypoint_type.dart';

part 'waypoint.g.dart';

@collection
class Waypoint {
  Id id = Isar.autoIncrement;
  int setId;

  @Index()
  int sortOrder;

  @Index()
  String name;

  @Index()
  double latitude;

  @Index()
  double longitude;

  @Index()
  @Enumerated(EnumType.name)
  WaypointType type;

  String? notes;

  @Enumerated(EnumType.name)
  WaypointDirection? direction;

  List<Alert> alerts;

  Waypoint({
    this.id = Isar.autoIncrement,
    required this.setId,
    required this.sortOrder,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.notes,
    WaypointDirection? direction,
    required this.alerts,
  });

  Waypoint copyWith({
    int? id,
    int? setId,
    int? sortOrder,
    String? name,
    double? latitude,
    double? longitude,
    WaypointType? type,
    String? notes,
    WaypointDirection? direction,
    List<Alert>? alerts,
  }) {
    return Waypoint(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      sortOrder: sortOrder ?? this.sortOrder,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      direction: direction ?? this.direction,
      alerts: alerts ?? this.alerts,
    );
  }

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
    id: json['id'] ?? Isar.autoIncrement,
    setId: json['setId'] ?? 0,
    sortOrder: json['sortOrder'],
    name: json['name'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    type: WaypointType.fromString(json['type']) ?? WaypointType.unknown,
    notes: json['notes'],
    direction: WaypointDirection.fromString(json['direction']),
    alerts: (json['alerts'] as List?)
      ?.map((a) => Alert.fromJson(a))
      .toList() ?? [],
  );

}

@embedded
class Alert {
  int distanceMeters;

  @enumerated
  AlertPriority priority;

  Alert({
    this.distanceMeters = 500,
    this.priority = AlertPriority.normal,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
    distanceMeters: json['distanceMeters'],
    priority: AlertPriority.fromString(json['priority']) ?? AlertPriority.normal,
  );
}