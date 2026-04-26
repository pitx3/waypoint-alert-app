import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waypoint_alert_app/widgets/cards/setting_card.dart';

void main() {
  testWidgets('SettingCard displays title, value, and subtitle', (tester) async{

    await tester.pumpWidget(
      MaterialApp (
        home: SettingCard(
          key: Key('test_setting_card'),
          title: 'Test Title',
          value: 'Test Value',
          subtitle: 'Test Subtitle',
          onEdit: () {},
        ),
      ),
    );

    expect(find.byKey(Key('test_setting_card')), findsOneWidget, reason: 'Test Card key not found');
    expect(find.text('Test Title'), findsOneWidget, reason: 'Test Title not found');
    expect(find.text('Test Value'), findsOneWidget, reason: 'Test Value not found');
    expect(find.text('Test Subtitle'), findsOneWidget, reason: 'Test Subtitle not found');
    expect(find.byIcon(Icons.edit), findsOneWidget, reason: 'Icon "Icons.edit" not found');

  });

}
