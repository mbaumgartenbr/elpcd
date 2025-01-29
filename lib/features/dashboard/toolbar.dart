import 'package:flutter/material.dart';

import '../../app/navigator.dart' as navigator;
import '../../localization.dart';
import '../../shared/data_exchange_handlers.dart';
import '../explorer/search_classes_button.dart';

class DashboardToolbar extends StatelessWidget {
  const DashboardToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final style = IconButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        spacing: 8,
        children: [
          SearchClassesButton(style: style),
          ImportExportMenuButton(style: style),
          IconButton(
            onPressed: () => navigator.showClassEditor(),
            tooltip: AppLocalizations.of(context).newClassButtonText,
            icon: const Icon(Icons.add),
            style: style,
          ),
        ],
      ),
    );
  }
}

class ImportExportMenuButton extends StatelessWidget {
  const ImportExportMenuButton({super.key, this.style});

  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      menuChildren: [
        MenuItemButton(
          onPressed: () => handleAtomIsadCsvExport(context),
          leadingIcon: const Icon(Icons.north_east),
          child: const Text('Export AtoM CSV ISAD(G) Template'),
        ),
        const Divider(),
        MenuItemButton(
          onPressed: () => handleJsonBackupExport(context),
          leadingIcon: const Icon(Icons.cloud_upload_outlined),
          child: const Text('Export Backup'),
        ),
        MenuItemButton(
          onPressed: () => handleJsonBackupImport(context),
          leadingIcon: const Icon(Icons.cloud_download_outlined),
          child: Text('${l10n.importButtonText} Backup'),
        ),
      ],
      child: Text(l10n.exportButtonText),
      builder: (BuildContext context, MenuController menu, _) {
        return IconButton(
          onPressed: () => menu.isOpen ? menu.close() : menu.open(),
          tooltip: l10n.backupSectionTitle,
          icon: const Row(
            spacing: 4,
            children: [
              Icon(Icons.cloud_sync),
              Icon(Icons.arrow_drop_down_rounded),
            ],
          ),
          style: style,
        );
      },
    );
  }
}
