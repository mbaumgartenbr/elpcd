import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../../entities/classe.dart';
import '../../localization.dart';
import '../../shared/class_title.dart';
import '../../shared/classes_store.dart';
import '../class_editor/earq_brasil_metadata.dart';

extension type TemporalityTableItem(Classe clazz) {
  String _valueOf(EarqBrasilMetadata entry) => clazz.metadata[entry.key] ?? '';

  String get currentAge => _valueOf(EarqBrasilMetadata.prazoCorrente);

  String get intermediateAge => _valueOf(EarqBrasilMetadata.prazoIntermediaria);

  String get disposal => _valueOf(EarqBrasilMetadata.destinacao);

  String get notes => _valueOf(EarqBrasilMetadata.observacoes);
}

class TemporalityTable extends StatefulWidget {
  const TemporalityTable({super.key, required this.classesStore});

  final ClassesStore classesStore;

  @override
  State<TemporalityTable> createState() => _TemporalityTableState();
}

class _TemporalityTableState extends State<TemporalityTable> {
  late AppLocalizations l10n;
  late var items = <TemporalityTableItem>[];

  @override
  void initState() {
    super.initState();
    items = buildItems();
    widget.classesStore.addListener(classesStoreListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    l10n = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    items.clear();
    widget.classesStore.removeListener(classesStoreListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderSide = BorderSide(color: theme.colorScheme.outlineVariant);

    return TableView.builder(
      columnCount: 5,
      pinnedRowCount: 2,
      rowCount: 2 + items.length,
      columnBuilder: (int index) => TableSpan(
        extent: columnExtends[index],
        backgroundDecoration: SpanDecoration(
          border: SpanBorder(
            leading: index == 0 ? borderSide : BorderSide.none,
            trailing: borderSide,
          ),
        ),
      ),
      rowBuilder: (int index) => TableSpan(
        extent: const FixedSpanExtent(48),
        backgroundDecoration: SpanDecoration(
          color: index < 2 ? theme.colorScheme.surfaceContainer : null,
          border: SpanBorder(
            leading: index == 0 ? borderSide : BorderSide.none,
            trailing: borderSide,
          ),
        ),
      ),
      cellBuilder: (BuildContext context, TableVicinity vicinity) {
        if (vicinity.row < 2) {
          return buildHeader(vicinity);
        }

        final item = items[vicinity.row - 2];

        return switch (vicinity.column) {
          0 => buildContentCell(
              item.clazz.name,
              child: ClassTitle(clazz: item.clazz),
            ),
          1 => buildContentCell(item.currentAge),
          2 => buildContentCell(item.intermediateAge),
          3 => buildContentCell(item.disposal),
          4 => buildContentCell(item.notes),
          _ => const TableViewCell(child: SizedBox.shrink()),
        };
      },
    );
  }

  List<TemporalityTableItem> buildItems() {
    final items = <TemporalityTableItem>[];

    void traverse(int? id) {
      if (widget.classesStore.getSubclasses(id) case final children?
          when children.isNotEmpty) {
        for (final Classe child in children) {
          items.add(TemporalityTableItem(child));
          traverse(child.id);
        }
      }
    }

    traverse(Classe.rootId);
    return items;
  }

  void classesStoreListener() {
    if (mounted) {
      setState(() {
        items = buildItems();
      });
    }
  }

  // Header Layout:
  //
  //              0                1            2            3          4
  // 0 |    Classification    |____Retention Period____| Disposal |   Notes  |
  // 1 |______________________| Current | Intermediate |__________|__________|
  TableViewCell buildHeader(TableVicinity vicinity) {
    return switch (vicinity.row) {
      0 => switch (vicinity.column) {
          0 => buildHeaderCell(
              l10n.temporalityTableHeaderClassification,
              rowMergeStart: 0,
              rowMergeSpan: 2,
            ),
          1 => buildHeaderCell(
              l10n.temporalityTableHeaderRententionPeriod,
              columnMergeStart: 1,
              columnMergeSpan: 2,
            ),
          3 => buildHeaderCell(
              l10n.temporalityTableHeaderDisposal,
              rowMergeStart: 0,
              rowMergeSpan: 2,
            ),
          4 => buildHeaderCell(
              l10n.temporalityTableHeaderNotes,
              rowMergeStart: 0,
              rowMergeSpan: 2,
            ),
          _ => const TableViewCell(child: SizedBox.shrink()),
        },
      1 => switch (vicinity.column) {
          1 => buildHeaderCell(l10n.temporalityTableHeaderCurrentAge),
          2 => buildHeaderCell(l10n.temporalityTableHeaderIntermediateAge),
          _ => const TableViewCell(child: SizedBox.shrink()),
        },
      _ => const TableViewCell(child: SizedBox.shrink()),
    };
  }

  late final columnExtends = List<SpanExtent>.unmodifiable([
    const MaxSpanExtent(FractionalSpanExtent(.40), FixedSpanExtent(400)),
    const MaxSpanExtent(FractionalSpanExtent(.15), FixedSpanExtent(175)),
    const MaxSpanExtent(FractionalSpanExtent(.15), FixedSpanExtent(175)),
    const MaxSpanExtent(FractionalSpanExtent(.15), FixedSpanExtent(175)),
    const MaxSpanExtent(FractionalSpanExtent(.15), FixedSpanExtent(175)),
  ]);

  TableViewCell buildHeaderCell(
    String content, {
    int? rowMergeStart,
    int? rowMergeSpan,
    int? columnMergeStart,
    int? columnMergeSpan,
  }) {
    return TableViewCell(
      rowMergeStart: rowMergeStart,
      rowMergeSpan: rowMergeSpan,
      columnMergeStart: columnMergeStart,
      columnMergeSpan: columnMergeSpan,
      child: Center(
        child: Text(
          content.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  TableViewCell buildContentCell(
    String? content, {
    Widget? child,
    int? columnMergeStart,
    int? columnMergeSpan,
  }) {
    content ??= '';
    child ??= Text(
      content,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    return TableViewCell(
      columnMergeStart: columnMergeStart,
      columnMergeSpan: columnMergeSpan,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Tooltip(
            message: content,
            child: child,
          ),
        ),
      ),
    );
  }
}
