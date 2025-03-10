import 'package:davi/src/pivot/pivot_data.dart';

/// Builds a hierarchical pivot table structure from flat data.
/// 
/// [T] is the type of data items being organized.
/// [L] is the type of hierarchy levels used for grouping.
class PivotBuilder<T, L extends HierarchyLevel> {
  /// The flat list of data items to organize
  final List<T> data;
  
  /// Available hierarchy levels in order from highest to lowest
  final List<L> levels;

  /// Function to aggregate multiple items into a single representative item
  final T Function(List<T> groupData) aggregate;

  /// Function to calculate max values for each column
  final Map<String, double Function(T)> valueColumns;

  const PivotBuilder({
    required this.data,
    required this.levels,
    required this.aggregate,
    required this.valueColumns,
  });

  /// Builds the hierarchical pivot structure from the flat data
  List<PivotData<T, L>> build() {
    return _buildGroups(data, 0);
  }

  List<PivotData<T, L>> _buildGroups(List<T> items, int levelIndex) {
    if (items.isEmpty || levelIndex >= levels.length) return [];

    final currentLevel = levels[levelIndex];
    Map<String, List<T>> groups = {};
    
    for (var item in items) {
      String key = currentLevel.getValue(item);
      groups.putIfAbsent(key, () => []).add(item);
    }

    return groups.entries.map((entry) {
      List<T> groupItems = entry.value;
      bool isLeaf = levelIndex == levels.length - 1;

      final maxValues = <String, double>{};
      final minValues = <String, double>{};
      for (var column in valueColumns.entries) {
        final values = groupItems.map((item) => column.value(item));
        maxValues[column.key] = values.reduce((a, b) => a > b ? a : b);
        minValues[column.key] = values.reduce((a, b) => a < b ? a : b);
      }

      if (isLeaf) {
        return PivotData<T, L>(
          data: aggregate(groupItems),
          level: currentLevel,
          maxValues: maxValues,
          minValues: minValues,
          children: groupItems.map((item) => 
            PivotData<T, L>(
              data: item,
              level: currentLevel,
              maxValues: maxValues,
              minValues: minValues,
              children: [],
            )
          ).toList(),
        );
      }

      return PivotData<T, L>(
        data: aggregate(groupItems),
        level: currentLevel,
        maxValues: maxValues,
        minValues: minValues,
        children: _buildGroups(groupItems, levelIndex + 1),
      );
    }).toList();
  }
} 