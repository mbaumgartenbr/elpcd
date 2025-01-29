import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/dialogs.dart';
import '../features/class_editor/class_editor_screen.dart';
import '../features/settings/institution_code.dart';
import '../features/settings/settings_controller.dart';
import '../shared/classes_store.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void pop<T extends Object?>([T? result]) {
  navigatorKey.currentState!.pop<T>(result);
}

void closeClassEditor() {
  pop();
  navigatorKey.currentContext!.read<OpenClassNotifier>().value = null;
}

void showClassEditor({int? classId, int? parentId}) {
  navigatorKey.currentContext!.read<OpenClassNotifier>().value = classId;
  showDialog<void>(
    context: navigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (_) => ClassEditorScreen(classId: classId, parentId: parentId),
  );
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
