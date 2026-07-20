
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/cards/empty_state_card.dart';

import '../../../helpers/expect.dart';
import '../../../helpers/widget_helpers.dart';


void main() {

  group('Empty State Card', () {
  
    testWidgets('displays title correctly', (WidgetTester t) async {
      const testTitle = 'No waypoints loaded';
      Widget w = EmptyStateCard(
              title: testTitle,
              subtitle: 'Test subtitle',
            );

      await t.pumpWidget(
        w.withMaterial()
      );
    
      t.exists<Text>(testTitle);
    });

    testWidgets('displays subtitle correctly', (WidgetTester t) async {
      const testSubtitle = 'Tap the menu to import a set';
      Widget w = EmptyStateCard(title: 'Test title', subtitle: testSubtitle,);
      await t.pumpWidget(w.withMaterial());
      t.exists<Text>(testSubtitle);
    });

    testWidgets('displays icon when provided', (WidgetTester t) async {
      const icon = Icons.folder_open;
      Widget w = EmptyStateCard(title: 'Test title', subtitle: 'Test subtitle', icon: icon,);
      await t.pumpWidget(w.withMaterial());
      t.exists<Icon>(icon);
    });

    testWidgets('hides icon when null', (WidgetTester t) async {
      Widget w = EmptyStateCard(title: 'Test Title', subtitle: 'Test Subtitle', icon: null,);
      await t.pumpWidget(w.withMaterial());
      t.noneExist<Icon>();
    });

    testWidgets('icon has correct size and color', (WidgetTester t) async {
      const icon = Icons.folder_open;
      Widget w = EmptyStateCard(title: 'Test title', subtitle: 'Test subtitle', icon: icon,);
      await t.pumpWidget(w.withMaterial());
      t.exists<Icon>(icon).hasSize(48).hasColor(Colors.grey[600]!);
    });

    testWidgets('title has correct font size, weight, and alignment', (WidgetTester t) async {
      const testTitle = 'No waypoints loaded';
      Widget w = EmptyStateCard(title: testTitle, subtitle: 'Test subtitle',);
      await t.pumpWidget(w.withMaterial());
      t.exists<Text>(testTitle).hasSize(18).hasWeight(FontWeight.bold).hasAlign(TextAlign.center);
    });

    testWidgets('subtitle has correct font size, color, and alignment', (WidgetTester t) async {
      const testSubtitle = 'This is a subtitle';
      Widget w = EmptyStateCard(title: 'Title', subtitle: testSubtitle,);
      await t.pumpWidget(w.withMaterial());
      t.exists<Text>(testSubtitle).hasSize(14).hasColor(Colors.grey[600]!).hasAlign(TextAlign.center);
    });

    testWidgets('content is center aligned', (WidgetTester t) async {
      Widget w = EmptyStateCard(title: 'Title', subtitle: 'Subtitle', icon: Icons.folder_open,);
      await t.pumpWidget(w.withMaterial());
      t.exists<Column>(null).isCenterAligned();
    });

    testWidgets('card renders as card', (WidgetTester t) async {
      Widget w = EmptyStateCard(title: 'Title', subtitle: 'Subtitle', icon: Icons.folder_open,);
      await t.pumpWidget(w.withMaterial());
      t.exists<Card>(null);
    });

  });  // end of group

}