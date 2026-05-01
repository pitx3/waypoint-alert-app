

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/dialogs/monitorring_toggle_dialog.dart';

Future<void> pumpDialogHarness(
  WidgetTester tester,
  {
    required bool isMonitoring,
    Future<void> Function(bool?)? onResult,
  }
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await showMonitoringToggleDialog(
                context: context,
                isMonitoring: isMonitoring,
              );
              if (onResult != null) await onResult(result);
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('showMonitoringToggleDialog', () {
  
    testWidgets('shows start monitoring dialog when monitoring is false', (tester) async {
      await pumpDialogHarness(tester, isMonitoring: false);
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Start Monitoring?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('shows stop monitoring dialog when monitoring is true', (tester) async {
      await pumpDialogHarness(tester, isMonitoring: true);
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Stop Monitoring?'), findsOneWidget, reason: 'Stop Monitoring? text not found');
      expect(find.text('Cancel'), findsOneWidget, reason: 'Cancel button not found');
      expect(find.text('Stop'), findsOneWidget, reason: 'Stop button not found');
    });

    testWidgets('Cancel button closes dialog without confirming', (tester) async {
      bool? capturedResult;

      await pumpDialogHarness(
        tester,
        isMonitoring: false,
        onResult: (result) async => capturedResult = result,
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(capturedResult, isNull, reason: 'capturedResult should be null');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Start button confirms and returns true', (tester) async {
      bool? capturedResult;

      await pumpDialogHarness(
        tester,
        isMonitoring: false,
        onResult: (result) async => capturedResult = result,
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(capturedResult, isTrue, reason: 'capturedResult should be "true"');
      expect(find.byType(AlertDialog), findsNothing);
    });
  
    testWidgets('Stop button confirms and returns false', (tester) async {
      bool? capturedResult;

      await pumpDialogHarness(
        tester,
        isMonitoring: true,
        onResult: (result) async => capturedResult = result,
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stop'));
      await tester.pumpAndSettle();

      expect(capturedResult, isFalse, reason: 'capturedResult should be "false"');
      expect(find.byType(AlertDialog), findsNothing);
    });

  });
}