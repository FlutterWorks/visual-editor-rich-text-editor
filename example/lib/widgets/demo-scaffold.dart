import 'package:flutter/material.dart';

import 'nav-menu.dart';

// Scaffold used by all pages in the demo app.
// It provides the navigation menu used to navigate between examples.
class DemoScaffold extends StatelessWidget {
  final Widget child;
  final List<Widget>? headerChildren;

  const DemoScaffold({
    required this.child,
    this.headerChildren,
  }) : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade800,
          elevation: 0,
          centerTitle: false,
          title: _title(),
          actions: headerChildren,
        ),
        drawer: _headerContainer(
          child: NavMenu(),
        ),
        body: SafeArea(
          child: child,
        ),
      );

  Widget _title() => Text('Visual Editor');

  Widget _headerContainer({required Widget child}) =>
      Container(
        color: Colors.grey.shade800,
        constraints: BoxConstraints(
          maxWidth: 400,
        ),
        child: child,
      );
}
