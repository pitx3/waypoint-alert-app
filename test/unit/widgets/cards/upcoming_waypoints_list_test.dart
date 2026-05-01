import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/cards/upcoming_waypoints_list.dart';

import '../../../helpers/expect_helpers.dart';

Widget _buildScaffold({required List<UpcomingWaypoint> waypoints, required double maxDistanceKm}) {
  return MaterialApp(
    home: Scaffold(
      body: UpcomingWaypointsList(waypoints: waypoints, maxDistanceKm: maxDistanceKm),
    ),
  );
}

void main() {
  group('UpcomingWaypointsList', () {
    testWidgets('displays list of upcoming waypoints', (tester) async {
      final double maxDistanceKm = 10.0;
      final waypoints = [
        const UpcomingWaypoint(name: 'Water Source', distanceKm: 2.1, type: 'water', alertCount: 3,),
        const UpcomingWaypoint(name: 'Trailhead', distanceKm: 5.4, type: 'trailhead', alertCount: 1,),
      ];

      await tester.pumpWidget(_buildScaffold(waypoints: waypoints, maxDistanceKm: maxDistanceKm));

      expectText('UPCOMING (within ${maxDistanceKm.toStringAsFixed(1)} km)');
      expectText('Water Source');
      expectText('Trailhead');
    });

    testWidgets('shows empty state when no waypoints', (tester) async {
      await tester.pumpWidget(_buildScaffold(waypoints: [], maxDistanceKm: 0));

      expectText('No waypoints loaded');
      expectText('Import a waypoint set to get started');
    });

    testWidgets('display alert count chips', (tester) async {
      final waypoints = [
        const UpcomingWaypoint(name: 'Camp Site', distanceKm: 8.7, type: 'camp', alertCount: 3,),
      ];
    
      await tester.pumpWidget(_buildScaffold(waypoints: waypoints, maxDistanceKm: 10));

      expectText('3');
    });
  });
}