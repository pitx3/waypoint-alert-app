import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/cards/next_waypoint_card.dart';

import '../../helpers/expect_helpers.dart';

Widget _buildScaffold(String name, double distanceKm, {double? bearing}) {
  return MaterialApp(
    home: Scaffold(
      body: NextWaypointCard(name: name, distanceKm: distanceKm, bearing: bearing),
    ),
  );
}


void main() {
  group('NextWaypointCard', (){
    testWidgets('displays waypoint name, distance, bearing, and bearing badge', (tester) async {
      String name = 'Sargents Ridge';
      double distanceKm = 0.8;
      double bearing = 74;
      await tester.pumpWidget(_buildScaffold(name, distanceKm, bearing: bearing));

      expectText('NEXT WAYPOINT');
      expectText(name);
      expectText('${distanceKm.toStringAsFixed(1)} km away');
      expectText('${bearing.toStringAsFixed(0)}°');
      expectIcon(Icons.explore, reason: 'Could not find bearing badge');
    });

    testWidgets('displays "--" if bearing not passed', (tester) async {
      String name = 'Sargents Ridge';
      double distanceKm = 0.8;
      double bearing = 74;
      await tester.pumpWidget(_buildScaffold(name, distanceKm));

      expectText('NEXT WAYPOINT');
      expectText(name);
      expectText('${distanceKm.toStringAsFixed(1)} km away');
      expectText('--');
      expectTextNotFound('${bearing.toStringAsFixed(0)}°');
      expectIcon(Icons.explore, reason: 'Could not find bearing badge');
    });


  });
}