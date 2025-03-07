import 'package:davi/src/pivot/pivot_data.dart';

class PivotBuilder<T> {
  final List<T> data;
  final List<String> Function(T data) groupBy;
  final T Function(List<T> groupData) aggregate;
  final int _groupLevels;

  PivotBuilder({
    required this.data,
    required this.groupBy,
    required this.aggregate,
  }) : _groupLevels = data.isEmpty ? 0 : groupBy(data[0]).length;

  List<PivotData<T>> build() {
    return _buildGroups(data, 0);
  }

  List<PivotData<T>> _buildGroups(List<T> items, int level) {
    if (items.isEmpty || level >= _groupLevels) return [];

    Map<String, List<T>> groups = {};
    for (var item in items) {
      String key = groupBy(item)[level];
      groups.putIfAbsent(key, () => []).add(item);
    }

    return groups.entries.map((entry) {
      List<T> groupItems = entry.value;
      bool isLeaf = level == _groupLevels - 1;

      return PivotData<T>(
        data: aggregate(groupItems),
        children: isLeaf ? [] : _buildGroups(groupItems, level + 1),
      );
    }).toList();
  }
} 