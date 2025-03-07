import 'package:davi/src/pivot/pivot_data.dart';

class PivotBuilder<T, L extends HierarchyLevel> {
  final List<T> data;
  final List<L> levels;
  final L Function(T data) getLevel;
  final T Function(List<T> groupData) aggregate;
  final String Function(T data, L level) getValueForLevel;

  PivotBuilder({
    required this.data,
    required this.levels,
    required this.getLevel,
    required this.aggregate,
    required this.getValueForLevel,
  });

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

      return PivotData<T, L>(
        data: aggregate(groupItems),
        level: currentLevel,
        children: isLeaf ? [] : _buildGroups(groupItems, levelIndex + 1),
      );
    }).toList();
  }
} 