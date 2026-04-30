import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class UpcomingWaypointsList extends StatelessWidget {
  final List<UpcomingWaypoint> waypoints;
  final double maxDistanceKm;

  const UpcomingWaypointsList({
    super.key,
    required this.waypoints,
    required this.maxDistanceKm,
  });

  @override
  Widget build(BuildContext context) {
    if (waypoints.isEmpty) {
      return _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'UPCOMING (within ${maxDistanceKm.toStringAsFixed(1)} km)',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...waypoints.map((wp) => _WaypointListTile(waypoint: wp)),
      ],
    );
  }
}

class _WaypointListTile extends StatelessWidget {
  final UpcomingWaypoint waypoint;

  const _WaypointListTile({required this.waypoint});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _IconForType(type: waypoint.type),
        title: Text(
          waypoint.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${waypoint.distanceKm.toStringAsFixed(1)} km',
        ),
        trailing: waypoint.alertCount > 0
          ? Chip(
              label: Text(
                '${waypoint.alertCount}',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: Colors.teal[700],
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          : null,
      ),
    );
  }
}

class _IconForType extends StatelessWidget {
  final String type;

  const _IconForType({required this.type});

  @override 
  Widget build(BuildContext context) {
    final iconData = _getIconForType(type);
    final color = _getColorForType(type);

    return Icon(iconData, color: color);
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return Icons.water_drop;
      case 'trailhead':
        return Icons.hiking;
      case 'camp':
        return MdiIcons.tent;
      case 'junction':
        return Icons.signpost;  // alternatives: assistant_direction, assistant_navigation, call_split, foloow_the_signs, fork_left, fork_right,
      default:
        return Icons.place;  // al
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return Colors.lightBlue;
      case 'trailhead':
        return Colors.green;
      case 'camp':
        return Colors.orange;
      case 'junction': 
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.place_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No waypoints loaded',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Import a waypoint set to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class UpcomingWaypoint {
  final String name;
  final double distanceKm;
  final String type;
  final int alertCount;

  const UpcomingWaypoint({
    required this.name,
    required this.distanceKm,
    required this.type,
    required this.alertCount,
  });
}
