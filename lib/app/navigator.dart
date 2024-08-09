import 'package:flutter/material.dart';

import '../../shared/dialogs.dart';
import '../features/class_editor/class_editor_screen.dart';
import '../features/settings/institution_code.dart';
import '../features/settings/settings_controller.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void pop<T extends Object?>([T? result]) {
  navigatorKey.currentState!.pop<T>(result);
}

void closeClassEditor() => pop();

void showClassEditor({int? classId, int? parentId}) {
  navigatorKey.currentState!.push(MaterialPageRoute<void>(
    builder: (_) => ClassEditorScreen(classId: classId, parentId: parentId),
  ));
}

void showInstitutionCodeEditor(SettingsController settings) {
  showModalBottomSheet<void>(
    context: navigatorKey.currentContext!,
    builder: (context) => InstitutionCodeEditor(
      institutionCode: settings.institutionCode,
      onSubmitted: (String value) {
        settings.updateInstitutionCode(value);
        pop();
      },
      onDismissed: () => pop(),
    ),
  );
}

Future<bool?> showWarningDialog({
  required String title,
  required String confirmButtonText,
}) {
  return showDialog<bool>(
    context: navigatorKey.currentContext!,
    builder: (_) => WarningDialog(
      title: title,
      confirmButtonText: confirmButtonText,
      onCancel: () => pop<bool>(false),
      onConfirm: () => pop<bool>(true),
    ),
  );
}
