

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/cards/active_set_card.dart';

import '../../helpers/expect_helpers.dart';

Widget _buildScaffold(String setName, int waypointCount, {VoidCallback? onTap}) {
  return MaterialApp(
    home: Scaffold(
      body: ActiveSetCard(
        setName: setName, 
        waypointCount: waypointCount,
        onTap: onTap,
      ),
    ),
  );
}

void main() {
  group('ActiveSetCard', () {
    testWidgets('displays set name and waypoint count', (tester) async {
      String setName = 'Colorado Trail 2026';
      int waypointCount = 47;
      await tester.pumpWidget(_buildScaffold (
        setName, waypointCount
      ));

      expectText('Active Set');
      expectText(setName);
      expectText('$waypointCount waypoints loaded');


      // expect(find.text('Active Set'), findsOneWidget, reason: 'Could not find text "Active Set"');
      // expect(find.text(setName), findsOneWidget, reason: 'Could not find text "$setName"');
      // expect(find.text('$waypointCount waypoints loaded'), findsOneWidget, reason: 'Did not find text "$waypointCount waypoints loaded"');
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(_buildScaffold('x', 4, onTap: () => tapped = true,));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expectTrue(tapped, reason: 'onTap not properly called');
    });
  });

}

