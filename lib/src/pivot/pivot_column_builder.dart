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
  
  /// Optional custom formatter for value columns
  final Widget Function(T data, double value, WidgetBuilderParams<T>)? valueFormatter;
  
  /// Optional custom header background color
  final Color? headerBackgroundColor;
  
  /// Optional builder for dynamic header background colors
  final Color Function(String header)? headerBackgroundColorBuilder;
  
  /// Map of value column names to functions that extract their values
  final Map<String, double Function(T)> valueColumns;
  
  /// Map of detail column names to functions that extract their values
  /// These columns only show up for leaf nodes (non-aggregated rows)
  final Map<String, String Function(T)> detailColumns;
  
  final double defaultColumnWidth;
  /// Default width for all columns

  final Color? maxValueColor;
  final Color? minValueColor;

  final Map<String, dynamic> columnProps;

  const PivotColumnBuilder({
    required this.levels,
    this.valueFormatter,
    this.headerBackgroundColor,
    this.headerBackgroundColorBuilder,
    this.valueColumns = const {},
    this.detailColumns = const {},
    this.defaultColumnWidth = 120,
    this.maxValueColor,
    this.minValueColor,
    this.columnProps = const {},
  });

  /// Builds the column definitions for the pivot table
  List<DaviColumn<T>> build(PivotTableModel<T, L> model) {
    final levelColumns = levels.map((level) {
      return DaviColumn<T>(
        id: level.id,
        name: level.displayName,
        width: defaultColumnWidth,
        headerBackgroundColor: headerBackgroundColorBuilder?.call(level.displayName) ?? headerBackgroundColor,
        cellWidget: (params) {
          final hasChildren = model.hasChildren(params.rowIndex);
          final currentLevel = model.getLevel(params.rowIndex);
          
          if (!hasChildren || level != currentLevel) {
            // Shrink by default for detail rows or non-matching levels
            return const SizedBox.shrink();
          }
          
          final isExpanded = model.isExpanded(params.rowIndex);
          String text = level.getValue(params.data);
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
        headerBackgroundColor: headerBackgroundColor,
        cellAlignment: Alignment.centerLeft,
        cellPadding: EdgeInsets.zero,
        cellBackground: (params) => !model.hasChildren(params.rowIndex) 
            ? entry.value(params.data) == model.getMaxValue(params.rowIndex, entry.key)
                ? maxValueColor
                : entry.value(params.data) == model.getMinValue(params.rowIndex, entry.key)
                    ? minValueColor
                    : null
            : null,
        cellWidget: (params) {
          final value = entry.value(params.data);
          final hasChildren = model.hasChildren(params.rowIndex);
          
          Widget content = valueFormatter != null 
              ? valueFormatter!(params.data, value, params)
              : Text(
                  value.toString(),
                  style: TextStyle(
                    fontWeight: hasChildren ? FontWeight.bold : FontWeight.normal,
                  ),
                );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: content,
          );
        },
      );
    }).toList();
    
    // Add detail columns
    final detailColumnsResult = detailColumns.entries.map((entry) {
      return DaviColumn<T>(
        id: entry.key,
        name: entry.key,
        width: defaultColumnWidth,
        headerBackgroundColor: headerBackgroundColor,
        cellWidget: (params) {
          // Only show content for non-aggregated rows (no children)
          if (model.hasChildren(params.rowIndex)) {
            return const SizedBox.shrink();
          }
          final value = entry.value(params.data);
          return Text(
            value,
            overflow: TextOverflow.ellipsis,
          );
        },
      );
    }).toList();
    
    final allColumns = [
      ...levelColumns, 
      ...detailColumnsResult,
      ...valueColumnsResult,
    ];
    return allColumns;
  }
} 