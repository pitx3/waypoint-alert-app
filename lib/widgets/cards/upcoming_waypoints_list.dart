import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/utils/ui.dart' as ui;
import 'package:waypoint_alert_app/widgets/cards/empty_state_card.dart';

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
      return EmptyStateCard(
        title: 'No Nearby Waypoints', 
        subtitle: 'No waypoints within ${maxDistanceKm.toStringAsFixed(1)} km',
        icon: Icons.near_me_disabled,
      );
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
