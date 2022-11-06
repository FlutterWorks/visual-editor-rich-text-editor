import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visual_editor/visual-editor.dart';

import '../const/demo-custom-styles.const.dart';
import '../widgets/demo-scaffold.dart';
import '../widgets/loading.dart';

// Page created in order to showcase multiple editors with custom styles.
class CustomStylesPage extends StatefulWidget {
  @override
  _CustomStylesPageState createState() => _CustomStylesPageState();
}

class _CustomStylesPageState extends State<CustomStylesPage> {
  EditorController? _controller1;
  EditorController? _controller2;
  EditorController? _controller3;

  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _focusNode3 = FocusNode();

  @override
  void initState() {
    _loadDocument();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _scaffold(
        children: _controller1 != null
            ? [
                _editorWithToolbar(
                  focusNode: _focusNode1,
                  controller: _controller1,
                  styles: DEMO_CUSTOM_STYLES[0],
                ),
                _editorWithToolbar(
                  focusNode: _focusNode2,
                  controller: _controller2,
                  styles: DEMO_CUSTOM_STYLES[1],
                ),
                _editorWithToolbar(
                  focusNode: _focusNode3,
                  controller: _controller3,
                  styles: DEMO_CUSTOM_STYLES[2],
                ),
              ]
            : [
                Loading(),
              ],
      );

  Widget _scaffold({required List<Widget> children}) => DemoScaffold(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(children: children),
        ),
      );

  Widget _editorWithToolbar({
    required EditorController? controller,
    required FocusNode focusNode,
    required EditorStylesM styles,
  }) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _toolbar(controller: controller),
          _editor(
            controller: controller,
            styles: styles,
            focusNode: focusNode,
          ),
        ],
      );

  Widget _toolbar({required EditorController? controller}) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: EditorToolbar.basic(
          controller: controller!,
          multiRowsDisplay: false,
        ),
      );

  Widget _editor({
    required EditorController? controller,
    required FocusNode focusNode,
    required EditorStylesM styles,
  }) =>
      Container(
        color: Colors.white,
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        child: VisualEditor(
          controller: controller!,
          scrollController: ScrollController(),
          focusNode: focusNode,
          config: EditorConfigM(
            customStyles: styles,
            placeholder: 'Enter text',
          ),
        ),
      );

  Future<void> _loadDocument() async {
    final deltaJson = await rootBundle.loadString(
      'assets/docs/custom-styles.json',
    );
    final document1 = DocumentM.fromJson(jsonDecode(deltaJson)[0]);
    final document2 = DocumentM.fromJson(jsonDecode(deltaJson)[1]);
    final document3 = DocumentM.fromJson(jsonDecode(deltaJson)[2]);

    setState(() {
      _controller1 = EditorController(
        document: document1,
      );
      _controller2 = EditorController(
        document: document2,
      );
      _controller3 = EditorController(
        document: document3,
      );
    });
  }
}
