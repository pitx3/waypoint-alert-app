class WaypointSet {
  final int id;
  final String name;
  final DateTime created;
  final bool isActive;
  final String? description;

  WaypointSet({
    required this.id,
    required this.name,
    required this.created,
    required this.isActive,
    this.description,
  });
}