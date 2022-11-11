import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visual_editor/visual-editor.dart';

import '../widgets/demo-scaffold.dart';

// Demo of the standard embeds.
class EmbedsPage extends StatefulWidget {
  const EmbedsPage({Key? key}) : super(key: key);

  @override
  State<EmbedsPage> createState() => _EmbedsPageState();
}

class _EmbedsPageState extends State<EmbedsPage> {
  late EditorController _controller;
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    _setupEditorController();
    _loadDocument();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _scaffold(
        children: [
          _editor(),
          _toolbar(),
        ],
      );

  Widget _toolbar() => EditorToolbar.basic(
        controller: _controller,
      );

  Widget _scaffold({required List<Widget> children}) => DemoScaffold(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      );

  Widget _editor() => Expanded(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: VisualEditor(
              controller: _controller,
              scrollController: _scrollController,
              focusNode: _focusNode,
              config: EditorConfigM(
                placeholder: 'Enter text',
              ),
            ),
          ),
        ),
      );

  // === UTILS ===

  void _setupEditorController() {
    _controller = EditorController(
      document: DocumentM.fromJson(
        jsonDecode(LOREM_LIPSUM_DOC_JSON),
      ),
    );
  }

  Future<void> _loadDocument() async {
    final doc = await rootBundle.loadString(
      'assets/docs/embeds.json',
    );
    final delta = DocumentM.fromJson(jsonDecode(doc)).toDelta();

    _controller.update(
      delta,

      // Prevents the insertion of the caret if the editor is not focused
      ignoreFocus: true,
    );
  }
}
