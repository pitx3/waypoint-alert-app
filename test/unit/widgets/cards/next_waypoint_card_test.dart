import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/cards/next_waypoint_card.dart';

import '../../../helpers/expect_helpers.dart';

Widget _buildScaffold(String name, double distanceKm, double bearing, String type, String notes) {
  return MaterialApp(
    home: Scaffold(
      body: NextWaypointCard(name: name, distanceKm: distanceKm, bearing: bearing, type: type, notes: notes),
    ),
  );
}


void main() {
  group('NextWaypointCard', (){
    testWidgets('displays waypoint name, distance, bearing, and bearing badge', (tester) async {
      String name = 'Sargents Ridge';
      double distanceKm = 0.8;
      double bearing = 74;
      String notes = 'Top of the world!';
      await tester.pumpWidget(_buildScaffold(name, distanceKm, bearing, '', notes));

      expectText('NEXT WAYPOINT');
      expectText(name);
      expectText('${distanceKm.toStringAsFixed(1)} km');
      expectText('${bearing.toStringAsFixed(0)}°');
      expectText(notes);
    });
  });
}