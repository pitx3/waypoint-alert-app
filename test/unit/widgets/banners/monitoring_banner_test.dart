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
    testWidgets('shows red banner when monitoring is off', (tester) async {
      final statusText = 'MONITORING OFF';
      final actionText = 'START';
      final tapText = '$statusText - Tap to $actionText';
      await tester.pumpWidget(_buildScaffold(false));

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, Colors.red, reason: 'banner is not red');
      expectText(tapText);
      //expect(find.text(tapText), findsOneWidget, reason: 'could not find "$tapText" text');
    });

    testWidgets('shows green banner when monitoring is on', (tester) async {
      final statusText = 'ALERTS ACTIVE';
      final actionText = 'STOP';
      final tapText = '$statusText - Tap to $actionText';
      await tester.pumpWidget(_buildScaffold(true));

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, Colors.green, reason: 'banner is not green');
      expectText(tapText);
      // expect(find.text(tapText), findsOneWidget, reason: 'could not find "$tapText" text');
    });

    testWidgets('shows confirmation dialog on tap', (tester) async {
      await tester.pumpWidget(_buildScaffold(false));

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();
      expectWidget<AlertDialog>();
      //expect(find.byType(AlertDialog), findsOneWidget, reason: 'Could not find confirmation dialog');      
    });

    testWidgets('calls onToggle when confirmed', (tester) async {
      bool toggled = false;

      await tester.pumpWidget(_buildScaffold(
        false,
        onToggle: () => toggled = true,
      ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expectTrue(toggled, reason: 'onToggle not triggered');
      // expect(toggled, isTrue, reason: 'onToggle not triggered');

    });

    testWidgets('does not call onToggle when cancelled', (tester) async {
      bool toggled = false;

      await tester.pumpWidget(_buildScaffold(
        false,
        onToggle: () => toggled = true,
      ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expectFalse(toggled, reason: 'onToggle triggered when it was not supposed to be');

      // expect(toggled, isFalse, reason: 'onToggle triggered when it was not supposed to be');
    });
  });

}