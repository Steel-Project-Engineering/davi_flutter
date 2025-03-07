import 'package:flutter/material.dart';
import 'package:davi/davi.dart';
import 'pivot_model.dart';
import 'pivot_data.dart';

/// Builds columns for the pivot table with support for hierarchy levels and value columns.
/// 
/// [T] is the type of data items being displayed.
/// [L] is the type of hierarchy levels used for grouping.
class PivotColumnBuilder<T, L extends HierarchyLevel> {
  /// Available hierarchy levels in order
  final List<L> levels;
  
  /// Function to extract display text for a level from a data item
  final String Function(T data, L level) getValueForLevel;
  
  /// Optional custom formatter for value columns
  final Widget Function(T data, double value, WidgetBuilderParams<T>)? valueFormatter;
  
  /// Map of value column names to functions that extract their values
  final Map<String, double Function(T)> valueColumns;
  
  /// Default width for all columns
  final double defaultColumnWidth;

  const PivotColumnBuilder({
    required this.levels,
    required this.getValueForLevel,
    this.valueFormatter,
    this.valueColumns = const {},
    this.defaultColumnWidth = 120,
  });

  /// Builds the column definitions for the pivot table
  List<DaviColumn<T>> build(PivotTableModel<T, L> model) {
    final levelColumns = levels.map((level) {
      return DaviColumn<T>(
        id: level.id,
        name: level.displayName,
        width: defaultColumnWidth,
        cellWidget: (params) {
          final hasChildren = model.hasChildren(params.rowIndex);
          final isExpanded = model.isExpanded(params.rowIndex);
          final currentLevel = model.getLevel(params.rowIndex);
          
          if (level != currentLevel) return const SizedBox.shrink();
          
          String text = getValueForLevel(params.data, level);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasChildren)
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                  ),
                  onPressed: () => model.toggleExpand(params.rowIndex),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                ),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: hasChildren ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }).toList();
    
    final valueColumnsResult = valueColumns.entries.map((entry) {
      return DaviColumn<T>(
        id: entry.key,
        name: entry.key,
        width: defaultColumnWidth,
        cellWidget: (params) {
          final value = entry.value(params.data);
          if (valueFormatter != null) {
            return valueFormatter!(params.data, value, params);
          }
          return Text(
            value.toString(),
            style: TextStyle(
              fontWeight: model.hasChildren(params.rowIndex) 
                  ? FontWeight.bold 
                  : FontWeight.normal,
            ),
          );
        },
      );
    }).toList();
    
    final allColumns = [...levelColumns, ...valueColumnsResult];
    return allColumns;
  }
} 