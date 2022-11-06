import 'package:flutter/material.dart';

import '../../documents/models/attributes/attributes-aliases.model.dart';
import '../../documents/models/attributes/attributes.model.dart';
import '../../documents/models/nodes/block.model.dart';
import '../../documents/models/nodes/line.model.dart';
import '../../documents/services/delta.utils.dart';
import '../../highlights/models/highlight.model.dart';
import '../../markers/models/marker.model.dart';
import '../../shared/state/editor.state.dart';
import '../models/editor-styles.model.dart';
import '../models/link-action.picker.type.dart';
import '../models/vertical-spacing.model.dart';
import '../style-widgets.dart';
import 'editable-text-block-widget-renderer.dart';
import 'editable-text-line-widget-renderer.dart';
import 'text-line.dart';

// ignore: must_be_immutable
class EditableTextBlock extends StatelessWidget {
  final BlockM block;
  final TextDirection textDirection;
  final VerticalSpacing verticalSpacing;
  final TextSelection textSelection;
  final List<HighlightM> highlights;
  final List<HighlightM> hoveredHighlights;
  final List<MarkerM> hoveredMarkers;
  final EditorStylesM? styles;
  final bool hasFocus;
  final bool isCodeBlock;
  final LinkActionPicker linkActionPicker;
  final Map<int, int> indentLevelCounts;
  final Function(int, bool) onCheckboxTap;

  // Used internally to retrieve the state from the EditorController instance to which this button is linked to.
  // Can't be accessed publicly (by design) to avoid exposing the internals of the library.
  late EditorState _state;

  void setState(EditorState state) {
    _state = state;
  }

  EditableTextBlock({
    required this.block,
    required this.textDirection,
    required this.verticalSpacing,
    required this.textSelection,
    required this.highlights,
    required this.hoveredHighlights,
    required this.hoveredMarkers,
    required this.styles,
    required this.hasFocus,
    required this.isCodeBlock,
    required this.linkActionPicker,
    required this.indentLevelCounts,
    required this.onCheckboxTap,
    required EditorState state,
    Key? key,
  }) {
    setState(state);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    final styles = _state.styles.styles;

    return EditableTextBlockWidgetRenderer(
      block: block,
      textDirection: textDirection,
      padding: verticalSpacing,
      decoration: _getDecorationForBlock(
            block,
            styles,
          ) ??
          const BoxDecoration(),
      isCodeBlock: isCodeBlock,
      state: _state,
      children: _blockLines(
        context,
        indentLevelCounts,
      ),
    );
  }

  BoxDecoration? _getDecorationForBlock(
    BlockM node,
    EditorStylesM? defaultStyles,
  ) {
    final hasAttrs = block.style.attributes != null;
    final attrs = block.style.attributes;

    if (hasAttrs) {
      if (attrs!.containsKey(AttributesM.blockQuote.key)) {
        return defaultStyles!.quote!.decoration;
      }

      if (attrs.containsKey(AttributesM.codeBlock.key)) {
        return defaultStyles!.code!.decoration;
      }
    }
    return null;
  }

  // More lines grouped together forms a block.
  List<Widget> _blockLines(
    BuildContext context,
    Map<int, int> indentLevelCounts,
  ) {
    final styles = _state.styles.styles;
    final blockLength = block.children.length;
    final children = <Widget>[];
    var index = 0;
    final indentWidth = _getIndentWidth();

    for (final line in Iterable.castFrom<dynamic, LineM>(block.children)) {
      index++;

      final editableTextLine = EditableTextLineWidgetRenderer(
        line: line,
        leading: _lineLeadingWidget(
          context,
          line,
          index,
          indentLevelCounts,
          blockLength,
        ),
        underlyingText: TextLine(
          line: line,
          textDirection: textDirection,
          styles: styles,
          linkActionPicker: linkActionPicker,
          state: _state,
        ),
        indentWidth: indentWidth,
        verticalSpacing: _getSpacingForLine(
          line,
          index,
          blockLength,
          styles,
        ),
        textDirection: textDirection,
        textSelection: textSelection,
        highlights: highlights,
        hoveredHighlights: hoveredHighlights,
        hoveredMarkers: hoveredMarkers,
        hasFocus: hasFocus,
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
        state: _state,
      );

      final nodeTextDirection = getDirectionOfNode(line);

      children.add(
        Directionality(
          textDirection: nodeTextDirection,
          child: editableTextLine,
        ),
      );
    }

    return children.toList(
      growable: false,
    );
  }

  // Lines that are part of blocks might have also a dedicated content type before them.
  // That content is called leading. The types of leading's are: ordered lists, unordered lists,
  // checked, unchecked and code blocks.
  Widget? _lineLeadingWidget(
    BuildContext context,
    LineM line,
    int index,
    Map<int, int> indentLevelCounts,
    int blockLength,
  ) {
    final styles = _state.styles.styles;
    final lineStyleAttrs = line.style.attributes;
    final hasLineStyleAttrs = line.style.attributes != null;

    if (hasLineStyleAttrs) {
      // Ordered list
      if (lineStyleAttrs![AttributesM.list.key] == AttributesAliasesM.ol) {
        return NumberPoint(
          blockLength: blockLength,
          indentLevelCounts: indentLevelCounts,
          textStyle: styles.leading!.style,
          attrs: lineStyleAttrs,
          containerWidth: 32,
          endPadding: 8,
        );
      }

      // Unordered list
      if (lineStyleAttrs[AttributesM.list.key] == AttributesAliasesM.ul) {
        return BulletPoint(
          style: styles.leading!.style.copyWith(
            fontWeight: FontWeight.bold,
          ),
          width: 32,
        );
      }

      // Checked
      if (lineStyleAttrs[AttributesM.list.key] == AttributesAliasesM.checked) {
        return CheckboxPoint(
          size: 14,
          value: true,
          enabled: !_state.editorConfig.config.readOnly,
          onChanged: (checked) => onCheckboxTap(line.documentOffset, checked),
          uiBuilder: styles.lists?.checkboxUIBuilder,
        );
      }

      // Unchecked
      if (lineStyleAttrs[AttributesM.list.key] ==
          AttributesAliasesM.unchecked) {
        return CheckboxPoint(
          size: 14,
          value: false,
          enabled: !_state.editorConfig.config.readOnly,
          onChanged: (checked) => onCheckboxTap(line.documentOffset, checked),
          uiBuilder: styles.lists?.checkboxUIBuilder,
        );
      }

      // Code Block
      if (lineStyleAttrs.containsKey(AttributesM.codeBlock.key)) {
        return NumberPoint(
          blockLength: blockLength,
          indentLevelCounts: indentLevelCounts,
          textStyle: styles.code!.style.copyWith(
            color: styles.code!.style.color!.withOpacity(0.4),
          ),
          containerWidth: 32,
          attrs: lineStyleAttrs,
          endPadding: 16,
          hasDotAfterNumber: false,
        );
      }
    }

    return null;
  }

  double _getIndentWidth() {
    final attrs = block.style.attributes;
    final hasAttrs = block.style.attributes != null;
    final indent = attrs?[AttributesM.indent.key];
    var extraIndent = 0.0;
    const indentBaseWidthValue = 16.0;

    if (indent != null && indent.value != null) {
      extraIndent = indentBaseWidthValue * indent.value;
    }

    if (hasAttrs && attrs!.containsKey(AttributesM.blockQuote.key)) {
      return 16.0 + extraIndent;
    }

    var baseIndent = 0.0;

    if (hasAttrs) {
      // Lists or code blocks
      if (attrs!.containsKey(AttributesM.list.key) ||
          attrs.containsKey(AttributesM.codeBlock.key)) {
        baseIndent = 32.0;
      }
    }

    return baseIndent + extraIndent;
  }

  VerticalSpacing _getSpacingForLine(
    LineM node,
    int index,
    int blockLength,
    EditorStylesM? defaultStyles,
  ) {
    var top = 0.0, bottom = 0.0;
    final attrs = block.style.attributes;
    final hasAttrs = block.style.attributes != null;

    if (hasAttrs) {
      if (attrs!.containsKey(AttributesM.header.key)) {
        final level = attrs[AttributesM.header.key]!.value;

        switch (level) {
          case 1:
            top = defaultStyles!.h1!.verticalSpacing.top;
            bottom = defaultStyles.h1!.verticalSpacing.bottom;
            break;

          case 2:
            top = defaultStyles!.h2!.verticalSpacing.top;
            bottom = defaultStyles.h2!.verticalSpacing.bottom;
            break;

          case 3:
            top = defaultStyles!.h3!.verticalSpacing.top;
            bottom = defaultStyles.h3!.verticalSpacing.bottom;
            break;

          default:
            throw 'Invalid level $level';
        }
      } else {
        late VerticalSpacing lineSpacing;

        // TODO Convert to switch
        if (attrs.containsKey(AttributesM.blockQuote.key)) {
          lineSpacing = defaultStyles!.quote!.lineSpacing;
        } else if (attrs.containsKey(AttributesM.indent.key)) {
          lineSpacing = defaultStyles!.indent!.lineSpacing;
        } else if (attrs.containsKey(AttributesM.list.key)) {
          lineSpacing = defaultStyles!.lists!.lineSpacing;
        } else if (attrs.containsKey(AttributesM.codeBlock.key)) {
          lineSpacing = defaultStyles!.code!.lineSpacing;
        } else if (attrs.containsKey(AttributesM.align.key)) {
          lineSpacing = defaultStyles!.align!.lineSpacing;
        }

        top = lineSpacing.top;
        bottom = lineSpacing.bottom;
      }

      if (index == 1) {
        top = 0.0;
      }

      if (index == blockLength) {
        bottom = 0.0;
      }
    }

    return VerticalSpacing(
      top: top,
      bottom: bottom,
    );
  }
}
