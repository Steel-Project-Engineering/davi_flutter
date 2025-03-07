import 'package:davi/davi.dart';

/// Model for managing pivot table state and data presentation.
/// 
/// Extends [DaviModel] to provide pivot-specific functionality while maintaining
/// compatibility with the Davi table widget.
/// 
/// [T] is the type of data items being displayed.
/// [L] is the type of hierarchy levels used for grouping.
class PivotTableModel<T, L extends HierarchyLevel> extends DaviModel<T> {
  final List<PivotData<T, L>> _pivotData;
  final List<PivotRowData<T, L>> _flattenedRows = [];
  final List<L> levels;
  
  /// Creates a pivot table model with predefined columns
  PivotTableModel({
    required List<PivotData<T, L>> pivotData,
    required List<DaviColumn<T>> columns,
    required this.levels,
  }) : _pivotData = pivotData,
       super(rows: [], columns: columns) {
    _flattenData();
  }

  /// Creates a pivot table model using a column builder
  /// 
  /// This is the recommended constructor as it handles proper column setup
  /// for hierarchy levels and value columns.
  factory PivotTableModel.withColumnBuilder({
    required List<PivotData<T, L>> pivotData,
    required List<L> levels,
    required PivotColumnBuilder<T, L> columnBuilder,
  }) {
    final model = PivotTableModel<T, L>(
      pivotData: pivotData,
      columns: [],
      levels: levels,
    );
    
    final columns = columnBuilder.build(model);
    model.addColumns(columns);
    
    return model;
  }

  void _flattenData() {
    _flattenedRows.clear();
    int originalIndex = 0;
    
    void addNode(PivotData<T, L> node, int levelIndex) {
      final currentIndex = originalIndex++;
      
      _flattenedRows.add(PivotRowData<T, L>(
        data: node.data,
        level: node.level,
        hasChildren: node.children.isNotEmpty,
        isExpanded: node.isExpanded,
        originalIndex: currentIndex,
      ));
      
      if (node.isExpanded) {
        for (var child in node.children) {
          addNode(child, levelIndex + 1);
        }
      }
    }
    
    for (var root in _pivotData) {
      addNode(root, 0);
    }
    
    // Update displayed rows
    removeRows();
    addRows(_flattenedRows.map((row) => row.data).toList());
  }
  
  /// Toggles the expanded state of a row
  void toggleExpand(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _flattenedRows.length) return;
    
    final rowData = _flattenedRows[rowIndex];
    if (!rowData.hasChildren) return;
    
    // Find the original node and toggle it
    PivotData<T, L>? findOriginalNode(List<PivotData<T, L>> nodes, int currentIndex, int targetIndex) {
      for (var node in nodes) {
        if (currentIndex == targetIndex) return node;
        currentIndex++;
        
        if (node.isExpanded) {
          final result = findOriginalNode(node.children, currentIndex, targetIndex);
          if (result != null) return result;
          currentIndex += _countDescendants(node);
        }
      }
      return null;
    }
    
    final originalNode = findOriginalNode(_pivotData, 0, rowData.originalIndex);
    if (originalNode != null) {
      originalNode.isExpanded = !originalNode.isExpanded;
      _flattenData();
      notifyListeners();
    }
  }
  
  int _countDescendants(PivotData<T, L> node) {
    if (!node.isExpanded) return 0;
    
    int count = 0;
    for (var child in node.children) {
      count++; // Count the child
      count += _countDescendants(child); // Count descendants
    }
    return count;
  }
  
  /// Gets the hierarchy level for a row
  L getLevel(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _flattenedRows.length) return levels[0];
    return _flattenedRows[rowIndex].level;
  }
  
  /// Checks if a row has child rows
  bool hasChildren(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _flattenedRows.length) return false;
    return _flattenedRows[rowIndex].hasChildren;
  }
  
  /// Checks if a row's children are currently visible
  bool isExpanded(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _flattenedRows.length) return false;
    return _flattenedRows[rowIndex].isExpanded;
  }

  void expandAll() {
    _setExpansionState(true);
  }

  void collapseAll() {
    _setExpansionState(false);
  }

  void _setExpansionState(bool expand) {
    void traverse(List<PivotData<T, L>> nodes) {
      for (var node in nodes) {
        node.isExpanded = expand;
        traverse(node.children);
      }
    }

    traverse(_pivotData);
    _flattenData();
    notifyListeners();
  }
}