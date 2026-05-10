import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/utils/ui.dart' as ui;

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
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        leading: ui.IconForType(type: waypoint.type),
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
  final double bearing;
  final String type;
  final String? notes;
  final int alertCount;

  const UpcomingWaypoint({
    required this.name,
    required this.distanceKm,
    required this.bearing,
    required this.type,
    required this.notes,
    required this.alertCount,
  });
}
