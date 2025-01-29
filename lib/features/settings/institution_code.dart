import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigator.dart' as navigator;
import '../../localization.dart';
import 'settings_controller.dart';

class InstitutionCodeListTile extends StatelessWidget {
  const InstitutionCodeListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final code = context.select<SettingsController, String>(
      (controller) => controller.institutionCode,
    );
    return ListTile(
      title: Text(AppLocalizations.of(context).institutionCodeTitle),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(code),
      ),
      trailing: const Icon(Icons.edit),
      onTap: () => navigator.showInstitutionCodeEditor(
        context.read<SettingsController>(),
      ),
      subtitleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class InstitutionCodeEditor extends StatefulWidget {
  const InstitutionCodeEditor({
    super.key,
    required this.institutionCode,
    required this.onSubmitted,
    required this.onDismissed,
  });

  final String institutionCode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onDismissed;

  @override
  State<InstitutionCodeEditor> createState() => _InstitutionCodeEditorState();
}

class _InstitutionCodeEditorState extends State<InstitutionCodeEditor> {
  late final textController =
      TextEditingController(text: widget.institutionCode);

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: MediaQuery.viewInsetsOf(context) + const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.cancelButtonText,
            onPressed: widget.onDismissed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              autofocus: true,
              controller: textController,
              onSubmitted: widget.onSubmitted,
              decoration: const InputDecoration(
                hintText: defaultInstitutionCode,
                hintStyle: TextStyle(fontStyle: FontStyle.italic),
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () => widget.onSubmitted(textController.text),
            child: Text(l10n.saveButtonText.toUpperCase()),
          ),
        ],
      ),
    );
  }
}
