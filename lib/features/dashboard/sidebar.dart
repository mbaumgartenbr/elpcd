import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../localization.dart';
import '../settings/dark_mode.dart';
import '../settings/institution_code.dart';
import 'dashboard.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final DashboardTab selectedTab;
  final ValueChanged<DashboardTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FocusTraversalGroup(
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        child: SizedBox(
          width: 300,
          child: Column(
            children: [
              const SidebarHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 16, 8),
                  children: [
                    for (final tab in DashboardTab.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: SidebarNavigationTile(
                          icon: tab.icon,
                          label: tab.localizedLabel(l10n),
                          isSelected: tab == selectedTab,
                          onPressed: () => onTabSelected(tab),
                        ),
                      )
                  ],
                ),
              ),
              Card(
                elevation: 0,
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                // TODO: inline editing
                child: const InstitutionCodeListTile(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final colorFilter = ColorFilter.mode(
      theme.colorScheme.onSurface,
      BlendMode.srcIn,
    );
    return ListTile(
      title: Text(l10n.appTitle),
      titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 4, 8, 4),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DarkModeSwitchIconButton(),
          MenuAnchor(
            builder: (BuildContext context, MenuController menu, _) {
              return IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              );
            },
            menuChildren: [
              Link(
                uri: sourceCodeUrl,
                target: LinkTarget.blank,
                builder: (context, _) => MenuItemButton(
                  onPressed: () => launchUrl(sourceCodeUrl),
                  leadingIcon: VectorGraphic(
                    loader: const AssetBytesLoader('assets/github-mark.svg'),
                    height: 20,
                    colorFilter: colorFilter,
                  ),
                  trailingIcon: const Icon(Icons.launch),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.sourceCodeButtonText),
                  ),
                ),
              ),
              Link(
                uri: blogUrl,
                target: LinkTarget.blank,
                builder: (context, _) => MenuItemButton(
                  onPressed: () => launchUrl(blogUrl),
                  leadingIcon: VectorGraphic(
                    loader: const AssetBytesLoader('assets/opds-icon.svg'),
                    height: 20,
                    colorFilter: colorFilter,
                  ),
                  trailingIcon: const Icon(Icons.launch),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(l10n.opdsBlogButtonText),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  static final sourceCodeUrl = Uri.parse('https://github.com/baumths/elpcd');
  static final blogUrl = Uri.parse(
    'https://documentosarquivisticosdigitais.blogspot.com',
  );
}

class SidebarNavigationTile extends StatelessWidget {
  const SidebarNavigationTile({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    late Color backgroundColor;
    late Color foregroundColor;

    if (isSelected) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
      foregroundColor = theme.colorScheme.onSurface;
    } else {
      backgroundColor = Colors.transparent;
      foregroundColor = theme.colorScheme.onSurfaceVariant;
    }

    return Material(
      color: backgroundColor,
      textStyle: theme.textTheme.labelLarge?.copyWith(color: foregroundColor),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 36,
            child: Row(
              spacing: 8,
              children: [
                Icon(icon, size: 20, color: foregroundColor),
                Flexible(child: Text(label)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
