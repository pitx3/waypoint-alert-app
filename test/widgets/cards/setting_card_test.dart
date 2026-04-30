import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waypoint_alert_app/widgets/cards/setting_card.dart';

import '../../helpers/expect_helpers.dart';

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

    expectKeyName('test_setting_card', reason: 'Test Card key not found');
    expectText('Test Title');
    expectText('Test Value');
    expectText('Test Subtitle');
    expectIcon(Icons.edit);
  });
}
