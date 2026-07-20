// ====================================
// Note: THIS DOES NOT TEST THE UI
//
// Tests the utils/ui.dart classes only
// These are custom widgets for niche use-cases
//
// ====================================

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/utils/ui.dart' as ui;

import '../../helpers/expect_helpers.dart';

void main() {

  group('IconForType tests', () {
    testWidgets('renders water icon for water type', (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ui.IconForType(type: 'water',),
          )
        )
      );

      expectIcon(Icons.water_drop, reason: 'Did not find Icons.water_drop icon');
      final icon = t.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(Colors.lightBlue), reason: 'Water icon is the wrong color');
    });

    testWidgets('renders hiking icon for trailhead type', (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ui.IconForType(type: 'trailhead',),
          )
        )
      );

      expectIcon(Icons.hiking, reason: 'Did not find Icons.hiking icon');
      final icon = t.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(Colors.green), reason: 'Hiking icon is the wrong color');
    });

    testWidgets('renders tent icon for camp type', (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ui.IconForType(type: 'camp',),
          )
        )
      );

      expectIcon(MdiIcons.tent, reason: 'Did not find MdiIcons.tent icon');
      final icon = t.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(Colors.orange), reason: 'Tent icon is the wrong color');
    });

    testWidgets('renders signpost icon for junction type', (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ui.IconForType(type: 'junction',),
          )
        )
      );

      expectIcon(Icons.signpost, reason: 'Did not find Icons.signpost icon');
      final icon = t.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(Colors.purple), reason: 'Signpost icon is the wrong color');
    });

    testWidgets('renders place icon for unknown type', (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ui.IconForType(type: 'not-a-type',),
          )
        )
      );

      expectIcon(Icons.place, reason: 'Did not find Icons.place icon');
      final icon = t.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(Colors.grey), reason: 'Place icon is the wrong color');
    });
  });
}