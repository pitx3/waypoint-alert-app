
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/cards/closest_water_card.dart';

import '../../helpers/expect_helpers.dart';

Widget _buildScaffold({String? waterName, double? distanceKm, double? bearing}) {
  return MaterialApp(
    home: Scaffold(
      body: ClosestWaterCard(
        waterName: waterName,
        distanceKm: distanceKm,
        bearing: bearing,
      ),
    ),
  );
}

void main() {
  group('ClosestWaterCard', () {
    testWidgets('displays water name and distance when available', (tester) async {
      String waterName = 'Clear Creek Crossing';
      double distanceKm = 2.7;
      //double bearing = 112;
      await tester.pumpWidget(_buildScaffold(waterName: waterName, distanceKm: distanceKm));

      expectText('CLOSEST WATER');
      expectText(waterName);
      expectText('${distanceKm.toStringAsFixed(1)} km away');
      expectIcon(Icons.water_drop);
    });

    testWidgets('shows empty state when no water available', (tester) async {
      await tester.pumpWidget(_buildScaffold());

      expectText('No water waypoints in current set');
      expectIcon(Icons.water_drop_outlined);
    });
  });

}