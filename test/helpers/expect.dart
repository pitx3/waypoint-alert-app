import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------
// GENERIC EXPECT CLASS
// ---------------------------------------

class Expect<T extends Widget> {
  final WidgetTester tester;
  final Finder finder;
  late final T widget;

  Expect(this.tester, this.finder, {String? reason}) {
    expect(
      finder,
      findsOneWidget,
      reason: reason ?? 'Could not find widget of type "$T"',
    );
    widget = tester.widget<T>(finder);
  }

  // ----------------------------------------------
  // Base methods (available for ALL widget types)
  // ----------------------------------------------

  Expect<T> isPresent({String? reason}) {
    expect(
      finder,
      findsOneWidget,
      reason: reason ?? 'Expected widget "$T" to exist',
    );
    return this;
  }

  Expect<T> notExists({String? reason}) {
    expect(
      finder,
      findsNothing,
      reason: reason ?? 'Expected widget "$T" to NOT exist',
    );
    return this;
  }

  Expect<T> hasKey(Key key, {String? reason}) {
    expect(
      widget.key,
      key,
      reason: reason ?? 'Expected key "$key", got "${widget.key}"',
    );
    return this;
  }
}

extension ExpectHelpers on WidgetTester {

  /// Checks that a specific widget exists
  Expect<T> exists<T extends Widget>(
    Object? obj,
    { Finder? finder, String? reason, }
  ) {
    Finder actualFinder;    

    if (T == Text) {
      String text = obj as String;
      reason = reason ?? 'Could not find text "$text"';
      actualFinder = find.text(text);
    } else if (T == Icon) {
      IconData icon = obj as IconData;
      reason = reason ?? 'Could not find icon "$icon"';
      actualFinder = find.byIcon(icon);
    } else {
      print ('No match on T: ${T.toString()}');
      actualFinder = finder ?? find.byType(T);
    }

    return Expect<T>(this, actualFinder, reason: reason);
  }

  /// Checks that any widget of a specific type exists
  void anyExist<T extends Widget>({Finder? finder, String? reason}) {
    Finder actualFinder = finder ?? find.byType(T);
    expect(
      actualFinder,
      findsAny,
      reason: reason
    );
  }

  /// Checks that a single widget of a specific type exists
  Expect<T> oneExists<T extends Widget>({Finder? finder, String? reason}) {
    Finder actualFinder = finder ?? find.byType(T);
    expect(
      actualFinder,
      findsOne,
      reason: reason
    );
    return Expect<T>(this, actualFinder, reason: reason);
  }

  /// Checks that a specific widget does not exist
  void notExists<T extends Widget>(
    Object? obj,
    { Finder? finder, String? reason }
  ) {
    Finder actualFinder;
    Matcher matcher = findsNothing;

    if (T == Text) {
      String text = obj as String;
      reason = reason ?? 'Found string "$text" when it should not exist';
      actualFinder = find.text(text);
    } else if (T == Icon) {
        IconData icon = obj as IconData;
        reason = reason ?? 'Found icon "$icon" when it should not exist';
        actualFinder = find.byIcon(icon);
    } else {
      actualFinder = finder ?? find.byType(T);
    }

    expect (
      actualFinder,
      matcher,
      reason: reason
    );
  }

  /// Checks that none of a specific widget type exist
  void noneExist<T extends Widget>({Finder? finder, String? reason}) {
    Finder actualFinder = finder ?? find.byType(T);
    expect(
      actualFinder,
      findsNothing,
      reason: reason
    );
  }
}


// ------------------------------------------
// Extension methods for TEXT widgets
// ------------------------------------------

extension TextExpect on Expect<Text> {
  Expect<Text> hasSize(double size, {String? reason}) {
    expect(
      widget.style?.fontSize,
      size,
      reason: reason ?? 'Expected font size $size, got ${widget.style?.fontSize}',
    );
    return this;
  }

  Expect<Text> hasColor(Color color, {String? reason}) {
    expect(
      widget.style?.color,
      color,
      reason: reason ?? 'Expected font color $color, got ${widget.style?.color}',
    );
    return this;
  }

  Expect<Text> hasWeight(FontWeight weight, {String? reason}) {
    expect(
      widget.style?.fontWeight,
      weight,
      reason: reason ?? 'Expected font weight $weight, got ${widget.style?.fontWeight}',
    );
    return this;
  }

  Expect<Text> hasAlign(TextAlign align, {String? reason}) {
    expect(
      widget.textAlign,
      align,
      reason: reason ?? 'Expected align $align, got ${widget.textAlign}',
    );
    return this;
  }
}

// ------------------------------------------
// Extension methods for ICON widgets
// ------------------------------------------

extension IconExpect on Expect<Icon> {
  Expect<Icon> hasSize(double size, {String? reason}) {
    expect(
      widget.size,
      size,
      reason: reason ?? 'Expected icon size $size, got ${widget.size}',
    );
    return this;
  }

  Expect<Icon> hasColor(Color color, {String? reason}) {
    expect(
      widget.color,
      color,
      reason: reason ?? 'Expected icon color $color, got ${widget.color}',
    );
    return this;
  }
}

// ------------------------------------------
// Extension methods for COLUMN widgets
// ------------------------------------------

extension ColumnExpect on Expect<Column> {
  Expect<Column> isCenterAligned({String? reason}) {
    expect(
      widget.crossAxisAlignment,
      CrossAxisAlignment.center,
      reason: reason ?? 'Expected CrossAxisAlignment.center, got ${widget.crossAxisAlignment}',
    );
    return this;
  }
}