import 'dart:convert' show utf8;

import 'package:file_saver/file_saver.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization.dart';
import '../../repositories/classes_repository.dart';
import '../../shared/dialogs.dart';
import '../../shared/snackbars.dart';
import '../features/backup/backup_service.dart';
import '../features/class_editor/earq_brasil_metadata.dart';
import '../features/crosswalk/atom_isad_csv_builder.dart';
import '../features/settings/settings_controller.dart';

Future<void> handleJsonBackupImport(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => WarningDialog(
      title: l10n.areYouSureDialogTitle,
      content: l10n.confirmImportDialogContent,
      confirmButtonText: l10n.importButtonText,
      onConfirm: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    ),
  );

  if (!(confirmed ?? false) || !context.mounted) {
    return;
  }

  final classesRepository = context.read<ClassesRepository>();
  final settingsController = context.read<SettingsController>();

  final XFile? file = await openFile(
    acceptedTypeGroups: const <XTypeGroup>[
      XTypeGroup(label: 'JSON', extensions: <String>['json']),
    ],
  );

  if (file == null) return;

  final json = await file.readAsString();

  String? errorMessage;

  try {
    await BackupService.importFromJson(
      json: json,
      classesRepository: classesRepository,
      settingsController: settingsController,
    );

    if (context.mounted) {
      showInfoSnackBar(context, l10n.backupSuccessfullyImportedSnackbarText);
    }
  } on FormatException {
    errorMessage = l10n.backupImportFormatExceptionText;
  } on BackupException {
    errorMessage = l10n.backupImportFailureText;
  } finally {
    if (errorMessage != null && context.mounted) {
      showErrorSnackBar(context, errorMessage);
    }
  }
}

Future<void> handleJsonBackupExport(BuildContext context) async {
  final json = BackupService.exportToJson(
    settingsController: context.read<SettingsController>(),
    classesRepository: context.read<ClassesRepository>(),
  );

  await FileSaver.instance.saveFile(
    name: 'elpcd_backup',
    bytes: utf8.encode(json),
    ext: 'json',
    mimeType: MimeType.json,
  );

  if (context.mounted) {
    showInfoSnackBar(
      context,
      AppLocalizations.of(context).backupSuccessfullyExportedSnackbarText,
    );
  }
}

Future<void> handleAtomIsadCsvExport(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final csv = AtomIsadCsvBuilder(
    institutionCode: context.read<SettingsController>().institutionCode,
    fondsArchivistNote: l10n.csvExportFondsArchivistNote,
    metadataLabels: EarqBrasilMetadata.createKeyToLabelMap(l10n),
  ).buildCsv(
    context.read<ClassesRepository>().getAllClasses(),
  );

  await FileSaver.instance.saveFile(
    bytes: utf8.encode(csv),
    name: 'elpcd_atom_crosswalk',
    ext: 'csv',
    mimeType: MimeType.csv,
  );
}
