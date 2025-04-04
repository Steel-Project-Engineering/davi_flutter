import 'dart:math';
import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'pivot_data.dart';

/// A specialized column that calculates and displays the maximum value 
/// from a list of value getters, with efficient caching
class MaxValueUsingDisplayedDataColumn<T, L extends HierarchyLevel> extends DaviColumn<T> {
  final PivotTableModel<T, L> model;
  final List<double Function(T)> valueGetters;
  final Widget Function(T, double, WidgetBuilderParams<T>) valueFormatter;
  bool _disposed = false;
  
  // Create a static cache to avoid recalculating for every cell
  static final Map<int, List<double>> _cache = {};
  static final Map<int, int> _cacheRowCount = {};
  
  // Keep track of our listeners to avoid duplicates and allow cleanup
  static final Map<int, VoidCallback> _listeners = {};
  
  MaxValueUsingDisplayedDataColumn({
    required this.model,
    required this.valueFormatter,
    required double width,
    required Color? headerBackgroundColor,
    required this.valueGetters,
  }) : super(
    id: 'Max',
    name: 'Max',
    width: width,
    headerBackgroundColor: headerBackgroundColor,
    cellAlignment: Alignment.centerLeft,
    cellPadding: EdgeInsets.zero,
    cellWidget: (params) {
      final cacheKey = model.hashCode;
      final currentRowCount = model.rows.length;
      
      // Calculate max values only when row count changes
      if (!_cache.containsKey(cacheKey) || 
          _cacheRowCount[cacheKey] != currentRowCount) {
        
        final displayedData = getDisplayedData(model);
        final maxValues = List.filled(valueGetters.length, 0.0);
        
        for (var item in displayedData) {
          for (int i = 0; i < valueGetters.length; i++) {
            maxValues[i] = max(maxValues[i], valueGetters[i](item));
          }
        }
        
        _cache[cacheKey] = maxValues;
        _cacheRowCount[cacheKey] = currentRowCount;
        
        // Setup listener only once per model
        if (!_listeners.containsKey(cacheKey)) {
          final listener = () {
            if (_cacheRowCount[cacheKey] != model.rows.length) {
              _cache.remove(cacheKey);
              _cacheRowCount.remove(cacheKey);
            }
          };
          
          _listeners[cacheKey] = listener;
          model.addListener(listener);
        }
      }
      
      final maxValues = _cache[cacheKey]!;
      final absoluteMax = maxValues.reduce((a, b) => max(a, b));
      
      // Get the max value for this specific row - concise functional approach for n values
      final rowMaxValue = valueGetters.length == 1 
          ? valueGetters[0](params.data)
          : valueGetters.map((getter) => getter(params.data)).reduce((a, b) => max(a, b));
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: valueFormatter(
          params.data, 
          rowMaxValue, 
          params
        ),
      );
    },
  );
  
  @override
  void dispose() {
    _disposed = true;
    final cacheKey = model.hashCode;
    final listener = _listeners.remove(cacheKey);
    if (listener != null) {
      model.removeListener(listener);
    }
    super.dispose();
  }
} 