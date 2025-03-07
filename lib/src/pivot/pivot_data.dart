/// Defines the interface for hierarchy levels in a pivot table.
/// Each level represents a grouping category in the data hierarchy.
abstract class HierarchyLevel {
  /// Display name shown in the UI for this hierarchy level
  String get displayName;
  
  /// Unique identifier for this level
  String get id;
}

/// Represents a node in the pivot table data structure.
/// Contains the actual data and manages the hierarchical relationship.
class PivotData<T, L extends HierarchyLevel> {
  /// The data item this node represents
  final T data;
  
  /// The hierarchy level this node belongs to
  final L level;
  
  /// Child nodes under this node in the hierarchy
  final List<PivotData<T, L>> children;
  
  /// Whether this node's children are currently visible in the UI
  bool isExpanded;

  PivotData({
    required this.data,
    required this.level,
    this.children = const [],
    this.isExpanded = false,
  });
}

/// Internal representation of a row in the flattened pivot table view.
class PivotRowData<T, L extends HierarchyLevel> {
  /// The data item for this row
  final T data;
  
  /// The hierarchy level this row belongs to
  final L level;
  
  /// Whether this row has child rows
  final bool hasChildren;
  
  /// Whether this row's children are currently visible
  final bool isExpanded;
  
  /// Original index in the hierarchy for state management
  final int originalIndex;

  PivotRowData({
    required this.data,
    required this.level,
    required this.hasChildren,
    required this.isExpanded,
    required this.originalIndex,
  });
} 