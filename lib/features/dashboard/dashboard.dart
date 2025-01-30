import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization.dart';
import '../../shared/classes_store.dart';
import '../explorer/explorer.dart';
import '../temporality_table/temporality_table.dart';
import 'sidebar.dart';
import 'toolbar.dart';

enum DashboardTab {
  classification(Icons.segment),
  temporality(Icons.table_chart_outlined);

  const DashboardTab(this.icon);

  final IconData icon;

  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      DashboardTab.classification => l10n.temporalityTableHeaderClassification,
      DashboardTab.temporality => l10n.temporalityTableHeaderRententionPeriod,
    };
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSidebarOpen = true;
  DashboardTab selectedTab = DashboardTab.classification;

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      scaffoldKey: scaffoldKey,
      header: AppBar(
        notificationPredicate: (_) => false,
        leading: IconButton(
          tooltip: 'Toggle Sidebar',
          icon: const RotatedBox(
            quarterTurns: 2,
            child: Icon(Icons.view_sidebar_outlined),
          ),
          onPressed: toggleSidebar,
        ),
        actions: const [DashboardToolbar()],
      ),
      isSidebarOpen: isSidebarOpen,
      sidebar: Sidebar(
        selectedTab: selectedTab,
        onTabSelected: handleTabSelected,
      ),
      body: switch (selectedTab) {
        DashboardTab.classification => ClassesExplorer(
            classesStore: context.read<ClassesStore>(),
          ),
        DashboardTab.temporality => TemporalityTable(
            classesStore: context.read<ClassesStore>(),
          ),
      },
    );
  }

  void toggleSidebar() {
    // Opens the Drawer if available, otherwise toggles the sidebar.
    if (scaffoldKey.currentState case final scaffoldState?
        when scaffoldState.hasDrawer && !scaffoldState.isDrawerOpen) {
      scaffoldState.openDrawer();
    } else {
      setState(() {
        isSidebarOpen = !isSidebarOpen;
      });
    }
  }

  void handleTabSelected(DashboardTab tab) {
    if (tab == selectedTab) return;

    if (scaffoldKey.currentState case final scaffoldState?
        when scaffoldState.hasDrawer && scaffoldState.isDrawerOpen) {
      scaffoldState.closeDrawer();
    }

    setState(() {
      selectedTab = tab;
    });
  }
}

class DashboardLayout extends StatelessWidget {
  const DashboardLayout({
    super.key,
    required this.scaffoldKey,
    required this.body,
    required this.header,
    required this.sidebar,
    required this.isSidebarOpen,
  });

  final Key scaffoldKey;
  final Widget body;
  final PreferredSizeWidget header;
  final Widget sidebar;
  final bool isSidebarOpen;

  @override
  Widget build(BuildContext context) {
    return switch (MediaQuery.sizeOf(context).width) {
      >= 1200 => Scaffold(
          key: scaffoldKey,
          body: Row(
            children: [
              if (isSidebarOpen) ...[
                sidebar,
                const VerticalDivider(width: 1),
              ],
              Expanded(
                child: Column(
                  children: [
                    header,
                    Expanded(
                      child: body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      _ => Scaffold(
          key: scaffoldKey,
          appBar: header,
          drawer: Drawer(child: sidebar),
          body: body,
        ),
    };
  }
}
