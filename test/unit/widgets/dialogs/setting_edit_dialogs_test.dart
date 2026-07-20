import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/dialogs/setting_edit_dialogs.dart';

Future<void> pumpDialogHarness(
  WidgetTester t, {
    int currentValue = 150,
    int minValue = 50,
    int maxValue = 300,
    String title = 'Test Setting',
    String suffix = '',
    Future<void> Function(int?)? onResult,
  }
) async {
  final testKey = GlobalKey();
  
  await t.pumpWidget(
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
    testWidgets('displays title and current value', (t) async {
      await pumpDialogHarness(t);
      
      await t.tap(find.text('Open Dialog'));
      await t.pumpAndSettle();

      expect(find.text('Test Setting'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.text('Range: 50-300'), findsOneWidget);
    });

    testWidgets('shows error for invalid number', (t) async {
      await pumpDialogHarness(t);

      await t.tap(find.text('Open Dialog'));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextField), 'abc');
      await t.pump();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('shows error for out of range value (too high)', (t) async {
      await pumpDialogHarness(t);

      await t.tap(find.text('Open Dialog'));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextField), '500');
      await t.pump();

      expect(find.text('Value must be between 50 and 300'), findsOneWidget);
    });
    
    testWidgets('shows error for out of range value (too low)', (t) async {
      await pumpDialogHarness(t);

      await t.tap(find.text('Open Dialog'));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextField), '5');
      await t.pump();

      expect(find.text('Value must be between 50 and 300'), findsOneWidget);
    });

    testWidgets('Save button enabled when valid', (t) async {
      await pumpDialogHarness(t);

      await t.tap(find.text('Open Dialog'));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextField), '200');
      await t.pump();

      final saveButton = t.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);    
    });

    testWidgets('Cancel button closes dialog without value', (t) async {
      int? capturedResult;

      await pumpDialogHarness(
        t,
        onResult: (result) async => capturedResult = result,
      );

      await t.tap(find.text('Open Dialog'));
      await t.pumpAndSettle();
      
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();

      expect(capturedResult, isNull);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Save button returns valid value', (t) async {
      int? capturedResult;

      await pumpDialogHarness(
        t,
        onResult: (result) async => capturedResult = result,
      );

      await t.tap(find.text('Open Dialog'));
      await t.pumpAndSettle();

      await t.enterText(find.byType(TextField), '200');
      await t.pump();

      await t.tap(find.text('Save'));
      await t.pumpAndSettle();

      expect(capturedResult, equals(200), reason: 'value returned is not correct');
      expect(find.byType(AlertDialog), findsNothing);

    });
  });
}