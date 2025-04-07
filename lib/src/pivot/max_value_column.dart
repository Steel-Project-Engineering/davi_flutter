import 'dart:math';
import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

/// A specialized column that calculates and displays the maximum value 
/// from a list of value getters, with efficient caching
class MaxValueColumn<T, L extends HierarchyLevel> extends DaviColumn<T> {
  final PivotTableModel<T, L> model;
  final List<double Function(T)> valueGetters;
  final Widget Function(T, double, WidgetBuilderParams<T>)? valueFormatter;
  
  // Keep track of our listeners to avoid duplicates and allow cleanup
  static final Map<int, VoidCallback> _listeners = {};
  
  MaxValueColumn({
    required this.model,
    required this.valueFormatter,
    required super.width,
    required super.headerBackgroundColor,
    required this.valueGetters,
  }) : super(
    id: 'Max',
    name: 'Max',
    cellAlignment: Alignment.centerLeft,
    cellPadding: EdgeInsets.zero,
    cellWidget: (params) {      
      // Get the max value for this specific row
      final rowMaxValue = valueGetters.length == 1 
          ? valueGetters[0](params.data)
          : valueGetters.map((getter) => getter(params.data)).reduce((a, b) => max(a, b));
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: valueFormatter != null 
          ? valueFormatter(
            params.data, 
            rowMaxValue, 
            params
          )
          : Text(rowMaxValue.toString()),
      );
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