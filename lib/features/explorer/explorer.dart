import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../app/navigator.dart' as navigator;
import '../../../entities/classe.dart';
import '../../../localization.dart';
import '../../shared/class_title.dart';
import '../../shared/classes_store.dart';

class ClassesExplorer extends StatefulWidget {
  const ClassesExplorer({super.key, required this.classesStore});

  final ClassesStore classesStore;

  @override
  State<ClassesExplorer> createState() => _ClassesExplorerState();
}

class _ClassesExplorerState extends State<ClassesExplorer> {
  late List<TreeViewNode<Classe>> tree = <TreeViewNode<Classe>>[];

  @override
  void initState() {
    super.initState();
    tree = buildTree();
    widget.classesStore.addListener(rebuildTree);
  }

  @override
  void dispose() {
    tree.clear();
    widget.classesStore.removeListener(rebuildTree);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (tree.isEmpty) return const EmptyExplorer();

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.titleMedium!,
      child: ClassesTreeView(tree: tree),
    );
  }

  void rebuildTree() {
    if (mounted) {
      setState(() {
        tree = buildTree();
      });
    }
  }

  List<TreeViewNode<Classe>> buildTree() {
    final controller = context.read<ClassesTreeViewController>();

    int compareNodes(TreeViewNode<Classe> a, TreeViewNode<Classe> b) {
      return a.content.compareTo(b.content);
    }

    List<TreeViewNode<Classe>>? traverse(int? id) {
      return widget.classesStore.getSubclasses(id)?.map((Classe clazz) {
        return TreeViewNode<Classe>(
          clazz,
          children: traverse(clazz.id),
          expanded: controller.isExpanded(clazz.id),
        );
      }).toList()
        ?..sort(compareNodes);
    }

    return traverse(Classe.rootId) ?? <TreeViewNode<Classe>>[];
  }
}

class EmptyExplorer extends StatelessWidget {
  const EmptyExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: 128,
              child: VectorGraphic(
                width: 128,
                loader: const AssetBytesLoader('assets/create-new-folder.svg'),
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).emptyClassesExplorerBodyText,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class ClassesTreeViewController {
  final treeController = TreeViewController();

  final Map<int, bool> _expansionStates = <int, bool>{};

  bool isExpanded(int? id) => _expansionStates[id] ?? false;

  @protected
  void updateExpansionState(int? id, bool state) {
    if (id == null) return;
    _expansionStates[id] = state;
  }

  void ensureExpanded(int? id) {
    if (id == null) return;
    _expansionStates[id] = true;
  }
}

class ClassesTreeView extends StatelessWidget {
  const ClassesTreeView({super.key, required this.tree});

  final List<TreeViewNode<Classe>> tree;

  static const Curve defaultAnimationCurve = Easing.standard;
  static const Duration defaultAnimationDuration = Durations.short4;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ClassesTreeViewController>();

    return TreeView(
      tree: tree,
      treeNodeBuilder: (_, TreeViewNode<Classe> node, __) {
        return ClassesTreeViewNode(
          key: ValueKey(node.content.id ?? Object()),
          node: node,
        );
      },
      treeRowBuilder: (_) => const TreeRow(extent: FixedSpanExtent(40)),
      onNodeToggle: (TreeViewNode<Classe> node) {
        controller.updateExpansionState(node.content.id, node.isExpanded);
      },
      indentation: TreeViewIndentationType.custom(20),
      toggleAnimationStyle: AnimationStyle(
        curve: defaultAnimationCurve,
        duration: defaultAnimationDuration,
      ),
    );
  }
}

class ClassesTreeViewNode extends StatelessWidget {
  const ClassesTreeViewNode({super.key, required this.node});

  final TreeViewNode<Classe> node;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: AnimatedRotation(
            turns: node.isExpanded ? 0.25 : 0.0,
            curve: ClassesTreeView.defaultAnimationCurve,
            duration: ClassesTreeView.defaultAnimationDuration,
            child: const Icon(Icons.arrow_right_rounded),
          ),
          onPressed: node.children.isEmpty
              ? null
              : () => TreeViewController.of(context).toggleNode(node),
        ),
        ClassActionsMenuButton(
          clazz: node.content,
          canDelete: node.children.isEmpty,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ClassesTreeViewNodeTitle(clazz: node.content),
        ),
      ],
    );
  }
}

class ClassesTreeViewNodeTitle extends StatefulWidget {
  const ClassesTreeViewNodeTitle({super.key, required this.clazz});

  final Classe clazz;

  @override
  State<ClassesTreeViewNodeTitle> createState() =>
      _ClassesTreeViewNodeTitleState();
}

class _ClassesTreeViewNodeTitleState extends State<ClassesTreeViewNodeTitle> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isOpen = context.watch<OpenClassNotifier>().value == widget.clazz.id;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () => navigator.showClassEditor(classId: widget.clazz.id),
        child: ClassTitle(
          clazz: widget.clazz,
          textStyle: isHovered || isOpen
              ? const TextStyle(decoration: TextDecoration.underline)
              : null,
        ),
      ),
    );
  }
}

class ClassActionsMenuButton extends StatelessWidget {
  const ClassActionsMenuButton({
    super.key,
    required this.clazz,
    required this.canDelete,
  });

  final Classe clazz;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = context.read<ClassesStore>();

    if (MediaQuery.sizeOf(context).width >= 600) {
      return MenuAnchor(
        builder: (BuildContext context, MenuController menu, _) {
          return IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => menu.isOpen ? menu.close() : menu.open(),
          );
        },
        menuChildren: <Widget>[
          MenuItemButton(
            onPressed: () {
              ensureExpanded(context);
              onAddSubordinateClassPressed();
            },
            leadingIcon: const Icon(Icons.add),
            child: Text(l10n.newSubordinateClassButtonText),
          ),
          MenuItemButton(
            onPressed: canDelete ? () => onDeletePressed(l10n, store) : null,
            leadingIcon: const Icon(Icons.delete),
            child: Text(l10n.deleteButtonText),
          ),
        ],
      );
    }

    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuItemButton(
                  onPressed: () {
                    ensureExpanded(context);
                    Navigator.pop(context);
                    onAddSubordinateClassPressed();
                  },
                  leadingIcon: const Icon(Icons.add),
                  child: Text(l10n.newSubordinateClassButtonText),
                ),
                MenuItemButton(
                  onPressed: canDelete
                      ? () {
                          Navigator.pop(context);
                          onDeletePressed(l10n, store);
                        }
                      : null,
                  leadingIcon: const Icon(Icons.delete),
                  child: Text(l10n.deleteButtonText),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void ensureExpanded(BuildContext context) {
    context.read<ClassesTreeViewController>().ensureExpanded(clazz.id);
  }

  void onAddSubordinateClassPressed() {
    navigator.showClassEditor(parentId: clazz.id);
  }

  void onDeletePressed(AppLocalizations l10n, ClassesStore store) async {
    final bool? delete = await navigator.showWarningDialog(
      title: l10n.areYouSureDialogTitle,
      confirmButtonText: l10n.deleteButtonText,
    );
    if (delete ?? false) {
      await store.delete(clazz);
    }
  }
}
