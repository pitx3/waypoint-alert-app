
import 'package:flutter/material.dart';

MaterialApp app(Widget widget) {
  return MaterialApp(
      home:Scaffold(
        body: widget,
      ),
    );
}

MaterialApp app2(List<Widget> widgets) {
  MaterialApp app =
    MaterialApp(
      home: Scaffold(
        body: Stack(children: widgets)
      )
    );

  return app;
}

extension WidgetTesters on Widget {
  Widget withMaterial() {
    return MaterialApp(
      home: Scaffold(body: this)
    );
  }
}

extension WidgetListTesters on List<Widget> {
  Widget withMaterial() {
    return MaterialApp(
      home: Scaffold(
        body: Stack(children: this)
      )
    );
  }
}
