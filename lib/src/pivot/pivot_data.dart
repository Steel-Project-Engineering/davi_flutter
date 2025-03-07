// First, define a type for hierarchy levels
abstract class HierarchyLevel {
  String get displayName;
  String get id;
}

class PivotData<T, L extends HierarchyLevel> {
  final T data;
  final L level;
  final List<PivotData<T, L>> children;
  bool isExpanded;

  PivotData({
    required this.data,
    required this.level,
    this.children = const [],
    this.isExpanded = false,
  });
}

class PivotRowData<T, L extends HierarchyLevel> {
  final T data;
  final L level;
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