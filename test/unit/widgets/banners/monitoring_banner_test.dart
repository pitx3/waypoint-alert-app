import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/banners/monitoring_banner.dart';

import '../../../helpers/expect_helpers.dart';

Widget _buildScaffold(bool isMonitoring, {VoidCallback? onToggle}) {
  return MaterialApp(
    home: Scaffold(
      body: MonitoringBanner(isMonitoring: isMonitoring, onToggle: onToggle ?? () {},)
    ),
  );
}

void main() {

  group('MonitoringBanner', (){
    testWidgets('shows red banner when monitoring is off', (t) async {
      final statusText = 'MONITORING OFF';
      final actionText = 'START';
      final tapText = '$statusText - Tap to $actionText';
      await t.pumpWidget(_buildScaffold(false));

      final container = t.widget<Container>(find.byType(Container));
      expect(container.color, Colors.red, reason: 'banner is not red');
      expectText(tapText);
      //expect(find.text(tapText), findsOneWidget, reason: 'could not find "$tapText" text');
    });

    testWidgets('shows green banner when monitoring is on', (t) async {
      final statusText = 'ALERTS ACTIVE';
      final actionText = 'STOP';
      final tapText = '$statusText - Tap to $actionText';
      await t.pumpWidget(_buildScaffold(true));

      final container = t.widget<Container>(find.byType(Container));
      expect(container.color, Colors.green, reason: 'banner is not green');
      expectText(tapText);
      // expect(find.text(tapText), findsOneWidget, reason: 'could not find "$tapText" text');
    });

    testWidgets('shows confirmation dialog on tap', (t) async {
      await t.pumpWidget(_buildScaffold(false));

      await t.tap(find.byType(GestureDetector));
      await t.pumpAndSettle();
      expectWidget<AlertDialog>();
      //expect(find.byType(AlertDialog), findsOneWidget, reason: 'Could not find confirmation dialog');      
    });

    testWidgets('calls onToggle when confirmed', (t) async {
      bool toggled = false;

      await t.pumpWidget(_buildScaffold(
        false,
        onToggle: () => toggled = true,
      ));

      await t.tap(find.byType(GestureDetector));
      await t.pumpAndSettle();
      await t.tap(find.text('Start'));
      await t.pumpAndSettle();

      expectTrue(toggled, reason: 'onToggle not triggered');
      // expect(toggled, isTrue, reason: 'onToggle not triggered');

    });

    testWidgets('does not call onToggle when cancelled', (t) async {
      bool toggled = false;

      await t.pumpWidget(_buildScaffold(
        false,
        onToggle: () => toggled = true,
      ));

      await t.tap(find.byType(GestureDetector));
      await t.pumpAndSettle();
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();

      expectFalse(toggled, reason: 'onToggle triggered when it was not supposed to be');

      // expect(toggled, isFalse, reason: 'onToggle triggered when it was not supposed to be');
    });
  });

}