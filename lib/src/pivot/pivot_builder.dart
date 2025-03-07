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

  /// Function to extract the value for a given level from a data item
  final String Function(T data, L level) getValueForLevel;
  
  /// Function to aggregate multiple items into a single representative item
  final T Function(List<T> groupData) aggregate;

  const PivotBuilder({
    required this.data,
    required this.levels,
    required this.getValueForLevel,
    required this.aggregate,
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
      String key = getValueForLevel(item, currentLevel);
      groups.putIfAbsent(key, () => []).add(item);
    }

    return groups.entries.map((entry) {
      List<T> groupItems = entry.value;
      bool isLeaf = levelIndex == levels.length - 1;

      if (isLeaf) {
        // For leaf nodes, create a parent node with individual items as children
        return PivotData<T, L>(
          data: aggregate(groupItems),
          level: currentLevel,
          children: groupItems.map((item) => 
            PivotData<T, L>(
              data: item,
              level: currentLevel,
              children: [],
            )
          ).toList(),
        );
      }

      return PivotData<T, L>(
        data: aggregate(groupItems),
        level: currentLevel,
        children: _buildGroups(groupItems, levelIndex + 1),
      );
    }).toList();
  }
} 