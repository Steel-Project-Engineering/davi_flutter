import 'package:davi/davi.dart';
import 'pivot_data.dart';

class PivotTableModel<T, L extends HierarchyLevel> extends DaviModel<T> {
  final List<PivotData<T, L>> _pivotData;
  final List<PivotRowData<T, L>> _flattenedRows = [];
  final List<L> levels;
  
  PivotTableModel({
    required List<PivotData<T, L>> pivotData,
    required List<DaviColumn<T>> columns,
    required this.levels,
  }) : _pivotData = pivotData,
       super(rows: [], columns: columns) {
    _flattenData();
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
  
  L getLevel(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _flattenedRows.length) return levels[0];
    return _flattenedRows[rowIndex].level;
  }
  
  bool hasChildren(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _flattenedRows.length) return false;
    return _flattenedRows[rowIndex].hasChildren;
  }
  
  bool isExpanded(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _flattenedRows.length) return false;
    return _flattenedRows[rowIndex].isExpanded;
  }
}