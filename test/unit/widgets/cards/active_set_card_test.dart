import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/cards/active_set_card.dart';

import '../../../helpers/expect_helpers.dart';

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

      expectIcon(Icons.folder, reason: 'Did not find Icons.folder icon');
      expectText(setName);
      expectText('$waypointCount');
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

