import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/models/water_info.dart';
import 'package:waypoint_alert_app/widgets/cards/active_set_card.dart';
import 'package:waypoint_alert_app/widgets/cards/closest_water_card.dart';
import 'package:waypoint_alert_app/widgets/cards/empty_state_card.dart';
import 'package:waypoint_alert_app/widgets/cards/next_waypoint_card.dart';
import 'package:waypoint_alert_app/widgets/cards/upcoming_waypoints_list.dart';

class WaypointDisplayCard extends StatelessWidget {

  final String setName;
  final int waypointCount;
  final VoidCallback? onSetTap;
  final UpcomingWaypoint? nextWaypoint;
  final WaterInfo? waterInfo;
  final List<UpcomingWaypoint> upcomingWaypoints;
  final double maxDistanceKm;

  const WaypointDisplayCard({
    super.key,
    required this.setName,
    required this.waypointCount,
    this.onSetTap,
    this.nextWaypoint,
    this.waterInfo,
    required this.upcomingWaypoints,
    this.maxDistanceKm = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActiveSetCard(
          setName: setName, 
          waypointCount: waypointCount,
          onTap: onSetTap,
        ),
        const SizedBox(height: 16),
        if (nextWaypoint !=  null)
          NextWaypointCard(
            name: nextWaypoint!.name,
            type: nextWaypoint!.type,
            distanceKm: nextWaypoint!.distanceKm,
            bearing: nextWaypoint!.bearing,
            notes: nextWaypoint!.notes,
          )
        else
          EmptyStateCard(
            title: 'No Nearby Waypoints',
            subtitle: 'No waypoints within ${maxDistanceKm.toStringAsFixed(1)} km',
            icon: Icons.near_me_disabled,
          ),
        const SizedBox(height: 16),
        if (waterInfo != null)
          ClosestWaterCard(
            waterInfo: waterInfo!,
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No water waypoints'),
            ),
          ),
        const SizedBox(height: 16),
        UpcomingWaypointsList(
          waypoints: upcomingWaypoints, 
          maxDistanceKm: maxDistanceKm
        ),
      ],
    );
  }
}