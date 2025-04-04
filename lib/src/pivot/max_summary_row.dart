import 'dart:math';
import 'package:davi/davi.dart';
import 'pivot_data.dart';

/// Utility class for creating and managing summary rows with maximum values
class MaxSummaryRow {
  /// Adds a fake summary row to the model
  static List<double> getSummaryValues<T, L extends HierarchyLevel>({
    required PivotTableModel<T, L> model, 
    required List<double Function(T)> valueGetters,
  }) {
    // Get all currently displayed data
    final displayedData = getDisplayedData(model);
    
    // Skip if no data
    if (displayedData.isEmpty) {
      return [];
    }
    
    // Find the maximum values across all displayed data
    List<double> maxValues = [];
    for (int i = 0; i < valueGetters.length; i++) {
      maxValues.add(0);
    }
      
    
    for (var item in displayedData) {
      for (int i = 0; i < valueGetters.length; i++) {
        maxValues[i] = max(maxValues[i], valueGetters[i](item));
      }
    }
    
    return maxValues;
  }
} 