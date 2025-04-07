import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

/// A specialized column that calculates and displays the maximum value 
/// from a list of value getters, with efficient caching
class MaxValueColumn<T, L extends HierarchyLevel> extends DaviColumn<T> {
  final PivotTableModel<T, L> model;
  final Map<String, double Function(T)> valueColumns;
  final Widget Function(T, double, WidgetBuilderParams<T>, String)? valueFormatter;
  
  // Keep track of our listeners to avoid duplicates and allow cleanup
  static final Map<int, VoidCallback> _listeners = {};
  
  MaxValueColumn({
    required this.model,
    required this.valueFormatter,
    required super.width,
    required super.headerBackgroundColor,
    required this.valueColumns
  }) : super(
    id: 'Max',
    name: 'Max',
    cellAlignment: Alignment.centerLeft,
    cellPadding: EdgeInsets.zero,
    cellWidget: (params) {      
      // Get the max value and its column name for this specific row
      double maxValue = valueColumns.values.first(params.data);
      String maxColumnName = valueColumns.keys.first;
      
      for (var entry in valueColumns.entries) {
        final value = entry.value(params.data);
        if (value > maxValue) {
          maxValue = value;
          maxColumnName = entry.key;
        }
      }
      
      return valueFormatter != null
                ? valueFormatter(params.data, maxValue, params, maxColumnName)
                : Text(maxValue.toString());
    },
  );
  
  @override
  void dispose() {
    final cacheKey = model.hashCode;
    final listener = _listeners.remove(cacheKey);
    if (listener != null) {
      model.removeListener(listener);
    }
    super.dispose();
  }
} 