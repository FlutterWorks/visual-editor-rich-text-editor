import 'package:flutter/material.dart';

import '../../controller/controllers/editor-controller.dart';
import '../../documents/models/attribute.model.dart';
import '../../documents/models/attributes/attributes-aliases.model.dart';
import '../../documents/models/attributes/attributes.model.dart';
import '../../documents/services/attribute.utils.dart';
import 'intents.utils.dart';

class IndentSelectionAction extends Action<IndentSelectionIntent> {
  IndentSelectionAction(this.controller);

  final EditorController controller;

  @override
  void invoke(IndentSelectionIntent intent, [BuildContext? context]) {
    controller.indentSelection(
      intent.isIncrease,
    );
  }

  @override
  bool get isActionEnabled => true;
}

class ApplyHeaderAction extends Action<ApplyHeaderIntent> {
  ApplyHeaderAction(this.controller);

  final EditorController controller;

  // TODO Make it a shared method. Same method used in other parts too.
  AttributeM<dynamic> _getHeaderValue() {
    final attr = controller.toolbarButtonToggler[AttributesM.header.key];
    if (attr != null) {
      // Checkbox tapping causes controller.selection to go to offset 0
      controller.toolbarButtonToggler.remove(AttributesM.header.key);
      return attr;
    }
    return controller.getSelectionStyle().attributes?[AttributesM.header.key] ??
        AttributesM.header;
  }

  @override
  void invoke(ApplyHeaderIntent intent, [BuildContext? context]) {
    final _attribute =
        _getHeaderValue() == intent.header ? AttributesM.header : intent.header;
    controller.formatSelection(_attribute);
  }

  @override
  bool get isActionEnabled => true;
}

class ApplyCheckListAction extends Action<ApplyCheckListIntent> {
  ApplyCheckListAction(this.controller);

  final EditorController controller;

  // TODO Make it a shared method. It's used in multiple places.
  bool _getIsToggled() {
    final attrs = controller.getSelectionStyle().attributes;
    var attribute = controller.toolbarButtonToggler[AttributesM.list.key];

    if (attribute == null) {
      attribute = attrs?[AttributesM.list.key];
    } else {
      // checkbox tapping causes controller.selection to go to offset 0
      controller.toolbarButtonToggler.remove(AttributesM.list.key);
    }

    if (attribute == null) {
      return false;
    }
    return attribute.value == AttributesAliasesM.unchecked.value ||
        attribute.value == AttributesAliasesM.checked.value;
  }

  @override
  void invoke(ApplyCheckListIntent intent, [BuildContext? context]) {
    controller.formatSelection(_getIsToggled()
        ? AttributeUtils.clone(AttributesAliasesM.unchecked, null)
        : AttributesAliasesM.unchecked);
  }

  @override
  bool get isActionEnabled => true;
}

// Toggles a text style (underline, bold, italic, strikethrough) on, or off.
class ToggleTextStyleAction extends Action<ToggleTextStyleIntent> {
  ToggleTextStyleAction(this.controller);

  final EditorController controller;

  bool _isStyleActive(AttributeM styleAttr, Map<String, AttributeM> attrs) {
    if (styleAttr.key == AttributesM.list.key) {
      final attribute = attrs[styleAttr.key];
      if (attribute == null) {
        return false;
      }
      return attribute.value == styleAttr.value;
    }
    return attrs.containsKey(styleAttr.key);
  }

  @override
  void invoke(ToggleTextStyleIntent intent, [BuildContext? context]) {
    final isActive = _isStyleActive(
        intent.attribute, controller.getSelectionStyle().attributes!);
    controller.formatSelection(
      isActive
          ? AttributeUtils.clone(intent.attribute, null)
          : intent.attribute,
    );
  }

  @override
  bool get isActionEnabled => true;
}
