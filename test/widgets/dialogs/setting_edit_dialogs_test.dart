import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/dialogs/setting_edit_dialogs.dart';

Future<void> pumpDialogHarness(
  WidgetTester tester, {
    int currentValue = 150,
    int minValue = 50,
    int maxValue = 300,
    String title = 'Test Setting',
    String suffix = '',
    Future<void> Function(int?)? onResult,
  }
) async {
  final testKey = GlobalKey();
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        key: testKey,
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await showIntSettingDialog(
                context: context,
                title: title,
                currentValue: currentValue,
                minValue: minValue,
                maxValue: maxValue,
                suffix: suffix,
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
  group('showIntSettingsDialog', () {
    testWidgets('displays title and current value', (tester) async {
      await pumpDialogHarness(tester);
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Setting'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.text('Range: 50-300'), findsOneWidget);
    });

    testWidgets('shows error for invalid number', (tester) async {
      await pumpDialogHarness(tester);

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('shows error for out of range value (too high)', (tester) async {
      await pumpDialogHarness(tester);

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '500');
      await tester.pump();

      expect(find.text('Value must be between 50 and 300'), findsOneWidget);
    });
    
    testWidgets('shows error for out of range value (too low)', (tester) async {
      await pumpDialogHarness(tester);

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.pump();

      expect(find.text('Value must be between 50 and 300'), findsOneWidget);
    });

    testWidgets('Save button enabled when valid', (tester) async {
      await pumpDialogHarness(tester);

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '200');
      await tester.pump();

      final saveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);    
    });

    testWidgets('Cancel button closes dialog without value', (tester) async {
      int? capturedResult;

      await pumpDialogHarness(
        tester,
        onResult: (result) async => capturedResult = result,
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(capturedResult, isNull);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Save button returns valid value', (tester) async {
      int? capturedResult;

      await pumpDialogHarness(
        tester,
        onResult: (result) async => capturedResult = result,
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '200');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(capturedResult, equals(200), reason: 'value returned is not correct');
      expect(find.byType(AlertDialog), findsNothing);

    });
  });
}