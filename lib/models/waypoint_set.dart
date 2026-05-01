import 'package:isar_community/isar.dart';

part 'waypoint_set.g.dart';

@collection
class WaypointSet {
  Id id = Isar.autoIncrement;
  String name;
  DateTime created;
  bool isActive;
  String? description;

  WaypointSet({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.created,
    required this.isActive,
    this.description,
  });

  factory WaypointSet.fromJson(Map<String, dynamic> json) => WaypointSet(
    id: json['id'] ?? Isar.autoIncrement,
    name: json['name'],
    created: json['created'] != null
      ? DateTime.parse(json['created'])
      : DateTime.now(),
    isActive: json['isActive'] ?? false,
    description: json['description'],
  );
}

