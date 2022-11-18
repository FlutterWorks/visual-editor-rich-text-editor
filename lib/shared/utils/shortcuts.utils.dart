import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../documents/models/attributes/attributes-aliases.model.dart';
import '../../documents/models/attributes/attributes.model.dart';
import 'intents.utils.dart';

final Map<ShortcutActivator, Intent> shortcuts = {
  // === Indentation ===
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.bracketRight):
      const IndentSelectionIntent(true),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.bracketLeft):
      const IndentSelectionIntent(false),

  // === Selection Formatting ===
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB):
      ToggleTextStyleIntent(AttributesM.bold),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyU):
      ToggleTextStyleIntent(AttributesM.underline),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyI):
      ToggleTextStyleIntent(AttributesM.italic),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyS):
      ToggleTextStyleIntent(AttributesM.strikeThrough),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.backquote):
      ToggleTextStyleIntent(AttributesM.inlineCode),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyL):
      ToggleTextStyleIntent(AttributesAliasesM.ul),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO):
      ToggleTextStyleIntent(AttributesAliasesM.ol),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyB): ToggleTextStyleIntent(AttributesM.blockQuote),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
      LogicalKeyboardKey.tilde): ToggleTextStyleIntent(AttributesM.codeBlock),

  // === Headers ===

  // H1
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1):
      ApplyHeaderIntent(AttributesAliasesM.h1),

  // H2
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2):
      ApplyHeaderIntent(AttributesAliasesM.h2),

  // H3
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3):
      ApplyHeaderIntent(AttributesAliasesM.h3),

  // No heading
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit0):
      ApplyHeaderIntent(AttributesM.header),

  // === Checklist ===
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyL): const ApplyCheckListIntent(),
};
