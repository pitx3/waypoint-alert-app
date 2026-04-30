import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void expectText(String text, {String? reason}) {
  expect(
    find.text(text),
    findsOneWidget,
    reason: reason ?? 'Could not find text "$text"',
  );
}

void expectTextNotFound(String text, {String? reason}) {
  expect(
    find.text(text),
    findsNothing,
    reason: reason ?? 'Unexpectedly found text "$text"',
  );
}

void expectIcon(IconData icon, {String? reason}) {
  expect(
    find.byIcon(icon),
    findsOneWidget,
    reason: reason ?? 'Could not find icon "$icon"',
  );
}

void expectWidget<T>({String? reason}) {
  expect(
    find.byType(T),
    findsOneWidget,
    reason: reason ?? 'Could not find widget of type "$T"'
  );
}

void expectTrue(bool value, {String? reason}) {
  expect(
    value,
    isTrue,
    reason: reason ?? 'Expected "true" got "$value"',
  );
}

void expectFalse(bool value, {String? reason}) {
  expect(
    value,
    isFalse,
    reason: reason ?? 'Expected "false" got "$value"',
  );
}

void expectKeyName(String keyName, {String? reason}) {
  expect(
    find.byKey(Key(keyName)),
    findsOneWidget,
    reason: reason ?? 'Key "$keyName" not found',
  );
}