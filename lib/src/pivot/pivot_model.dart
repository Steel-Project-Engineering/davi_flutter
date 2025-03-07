import 'package:davi/davi.dart';
import 'pivot_data.dart';

class PivotTableModel<DATA> extends DaviModel<DATA> {
  final List<PivotData<DATA>> _pivotData;
  final List<PivotRowData<DATA>> _flattenedRows = [];
  
  PivotTableModel({
    required List<PivotData<DATA>> pivotData,
    required List<DaviColumn<DATA>> columns,
  }) : _pivotData = pivotData,
       super(rows: [], columns: columns) {
    _flattenData();
  }

  void _flattenData() {
    _flattenedRows.clear();
    int originalIndex = 0;
    
    void addNode(PivotData<DATA> node, int level) {
      final currentIndex = originalIndex++;
      
      _flattenedRows.add(PivotRowData<DATA>(
        data: node.data,
        level: level,
        hasChildren: node.children.isNotEmpty,
        isExpanded: node.isExpanded,
        originalIndex: currentIndex,
      ));
      
      if (node.isExpanded) {
        for (var child in node.children) {
          addNode(child, level + 1);
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
    PivotData<DATA>? findOriginalNode(List<PivotData<DATA>> nodes, int currentIndex, int targetIndex) {
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
  
  int _countDescendants(PivotData<DATA> node) {
    if (!node.isExpanded) return 0;
    
    int count = 0;
    for (var child in node.children) {
      count++; // Count the child
      count += _countDescendants(child); // Count descendants
    }
    return count;
  }
  
  int getLevel(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _flattenedRows.length) return 0;
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