class PivotData<T> {
  final T data;
  final List<PivotData<T>> children;
  bool isExpanded;

  PivotData({
    required this.data,
    this.children = const [],
    this.isExpanded = false,
  });
}

class PivotRowData<T> {
  final T data;
  final int level;
  final bool hasChildren;
  final bool isExpanded;
  final int originalIndex;

  PivotRowData({
    required this.data,
    required this.level,
    required this.hasChildren,
    required this.isExpanded,
    required this.originalIndex,
  });
} 