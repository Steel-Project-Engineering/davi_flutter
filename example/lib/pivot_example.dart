import 'dart:math';

import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: PivotTableExample(),
    ),
  ));
}

// Define hierarchy levels
enum SalesLevel implements HierarchyLevel {
  division('Division'),
  region('Region'),
  department('Department'),
  category('Category'),
  subCategory('SubCategory'),
  product('Product'),
  variant('Variant'),
  size('Size'),
  color('Color'),
  batch('Batch');

  @override
  final String displayName;
  
  const SalesLevel(this.displayName);
  
  @override
  String get id => name;

  @override
  String getValue(dynamic data) {
    final salesData = data as SalesData;
    switch (this) {
      case SalesLevel.division: return salesData.division;
      case SalesLevel.region: return salesData.region;
      case SalesLevel.department: return salesData.department;
      case SalesLevel.category: return salesData.category;
      case SalesLevel.subCategory: return salesData.subCategory;
      case SalesLevel.product: return salesData.product;
      case SalesLevel.variant: return salesData.variant;
      case SalesLevel.size: return salesData.size;
      case SalesLevel.color: return salesData.color;
      case SalesLevel.batch: return salesData.batch;
    }
  }
}

class SalesData {
  final String division;     // Level 1
  final String region;       // Level 2
  final String department;   // Level 3
  final String category;     // Level 4
  final String subCategory;  // Level 5
  final String product;      // Level 6
  final String variant;      // Level 7
  final String size;        // Level 8
  final String color;       // Level 9
  final String batch;       // Level 10
  final String itemName;
  final double amount;
  final double usedAmount;
  final double lastPurchaseAmount;

  const SalesData({
    required this.division,
    required this.region,
    required this.department,
    required this.category,
    required this.subCategory,
    required this.product,
    required this.variant,
    required this.size,
    required this.color,
    required this.batch,
    required this.itemName,
    required this.amount,
    required this.usedAmount,
    required this.lastPurchaseAmount,
  });
}

class PivotTableExample extends StatefulWidget {
  const PivotTableExample({super.key});

  @override
  State<PivotTableExample> createState() => _PivotTableExampleState();
}

class _PivotTableExampleState extends State<PivotTableExample> {
  late PivotTableModel<SalesData, SalesLevel> model;
  static final _random = Random();
  static const int totalEntries = 1000000;
  SalesData? _summaryRow;
  bool _isUpdatingSummaryRow = false;
  final _valueColumns = <String, double Function(SalesData)>{
    'Amount': (data) => data.amount,
    'Used Amount': (data) => data.usedAmount,
    'Purchase Amount': (data) => data.lastPurchaseAmount,
  };
  // Track the current number of visible rows to detect expansion changes
  int _lastVisibleRowCount = 0;


  List<String> _getRandomOptions(String prefix, int count) {
    return List.generate(count, (i) => '$prefix ${i + 1}');
  }

  List<SalesData> _generateData() {
    final stopwatch = Stopwatch()..start();
    final data = <SalesData>[];
    
    final divisions = _getRandomOptions('Division', 2);
    final regions = _getRandomOptions('Region', 3);
    final departments = _getRandomOptions('Dept', 2);
    final categories = _getRandomOptions('Category', 3);
    final subCategories = _getRandomOptions('SubCat', 2);
    final products = _getRandomOptions('Product', 4);
    final variants = _getRandomOptions('Variant', 2);
    final sizes = ['S', 'M', 'L'];
    final colors = ['Red', 'Blue', 'Black'];
    final batches = _getRandomOptions('Batch', 3);
    
    final combinationsPerBatch = divisions.length * regions.length * departments.length * 
        categories.length * subCategories.length * products.length * variants.length * 
        sizes.length * colors.length * batches.length;
        
    final itemsPerBatch = (totalEntries / combinationsPerBatch).ceil();
    
    print('Target entries: $totalEntries');
    print('Combinations per batch: $combinationsPerBatch');
    print('Items per batch: $itemsPerBatch');
    
    var lastProgress = 0;
    for (var division in divisions) {
      for (var region in regions) {
        for (var department in departments) {
          for (var category in categories) {
            for (var subCategory in subCategories) {
              for (var product in products) {
                for (var variant in variants) {
                  for (var size in sizes) {
                    for (var color in colors) {
                      for (var batch in batches) {
                        for (int i = 0; i < itemsPerBatch && data.length < totalEntries; i++) {
                          final amount = _random.nextDouble() * 10000;
                          final usedAmount = amount * (0.6 + (_random.nextDouble() * 0.4));
                          final lastPurchaseAmount = _random.nextDouble() * 10000;
                          
                          data.add(SalesData(
                            division: division,
                            region: region,
                            department: department,
                            category: category,
                            subCategory: subCategory,
                            product: product,
                            variant: variant,
                            size: size,
                            color: color,
                            batch: batch,
                            itemName: 'Item ${batch}-${i + 1}',
                            amount: amount,
                            usedAmount: usedAmount,
                            lastPurchaseAmount: lastPurchaseAmount,
                          ));

                          // Print progress every 10%
                          final progress = ((data.length / totalEntries) * 100).floor();
                          if (progress != lastProgress && progress % 10 == 0) {
                            print('Generated ${data.length} records (${progress}%) in ${stopwatch.elapsedMilliseconds}ms');
                            lastProgress = progress;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    print('Final: Generated ${data.length} records in ${stopwatch.elapsedMilliseconds}ms');
    return data;
  }

  @override
  void initState() {
    super.initState();
    final stopwatch = Stopwatch()..start();
    print('Starting model initialization...');
    _initializeModel();
    print('Model initialized in ${stopwatch.elapsedMilliseconds}ms');
  }

  void _initializeModel() {
    final data = _generateData();
    final levels = SalesLevel.values;
    
    final pivotBuilder = PivotBuilder<SalesData, SalesLevel>(
      data: data,
      levels: levels,
      valueColumns: _valueColumns,
      aggregate: (groupData) {
        double maxAmount = 0;
        double minUsedAmount = double.infinity;
        double totalLastPurchaseAmount = 0;
        for (var item in groupData) {
          maxAmount = max(maxAmount, item.amount);
          minUsedAmount = min(minUsedAmount, item.usedAmount);
          totalLastPurchaseAmount += item.lastPurchaseAmount;
        }

        return SalesData(
          division: groupData.first.division,
          region: groupData.first.region,
          department: groupData.first.department,
          category: groupData.first.category,
          subCategory: groupData.first.subCategory,
          product: groupData.first.product,
          variant: groupData.first.variant,
          size: groupData.first.size,
          color: groupData.first.color,
          batch: groupData.first.batch,
          itemName: '',
          amount: maxAmount,
          usedAmount: minUsedAmount,
          lastPurchaseAmount: totalLastPurchaseAmount,
        );
      },
    );

    final pivotData = pivotBuilder.build();

    final columnBuilder = PivotColumnBuilder<SalesData, SalesLevel>(
      levels: levels,
      valueColumns: _valueColumns,
      detailColumns: {
        'Item Name': (data) => data.itemName,
      },
      valueFormatter: _formatValue,
      maxValueColor: Colors.green,
      minValueColor: Colors.red,
      headerBackgroundColor: Colors.pink.shade100, // This gets overridden by the builder below
      headerBackgroundColorBuilder: (header) {
        if (header == 'Item Name') {
          return Colors.orange.shade100;
        }
        return Colors.purple.shade100;
      },
    );

    model = PivotTableModel.withColumnBuilder(
      pivotData: pivotData,
      levels: levels,
      columnBuilder: columnBuilder,
    );
    
    // Add a custom column that calculates the maximum value for each displayed row
    model.addColumns([
      MaxValueColumn(
        model: model,
        valueFormatter: _formatValue,
        width: 150,
        headerBackgroundColor: Colors.purple.shade100,
        valueGetters: _valueColumns.values.toList(),
      ),
    ]);
    
    // Add a smarter listener that only triggers on data visibility changes
    model.addListener(_onModelChanged);
    
    // Initial addition of summary row
    _updateSummaryRow(_valueColumns.values.toList());
    _lastVisibleRowCount = model.rows.length;
  }

  void _onModelChanged() {
    // Only update if the number of visible rows has changed (expand/collapse)
    // or if we're initializing (_lastVisibleRowCount == 0)
    final currentRowCount = model.rows.length;
    if (currentRowCount != _lastVisibleRowCount) {
      _updateSummaryRow(_valueColumns.values.toList());
      _lastVisibleRowCount = currentRowCount;
    }
  }

  void _updateSummaryRow(List<double Function(SalesData)> valueGetters) {
    // Prevent recursive calls from the model listener
    if (_isUpdatingSummaryRow) return;
    
    try {
      _isUpdatingSummaryRow = true;
      
      // First, remove the existing summary row if it exists
      if (_summaryRow != null) {
        model.removeRow(_summaryRow!);
        _summaryRow = null;
      }
      
      // Calculate new summary values
      final summaryValues = MaxSummaryRow.getSummaryValues<SalesData, SalesLevel>(
        model: model,
        valueGetters: valueGetters,
      );
      
      // Skip adding the summary row if there are no values
      if (summaryValues.isEmpty) return;
      
      // Create and add the new summary row
      _summaryRow = SalesData(
        division: '',
        region: '',
        department: '',
        category: '',
        subCategory: '',
        product: '',
        variant: '',
        size: '',
        color: '',
        batch: '',
        itemName: '',
        amount: summaryValues[0],
        usedAmount: summaryValues[1],
        lastPurchaseAmount: summaryValues[2],
      );
      
      model.addRow(_summaryRow!);
    } finally {
      _isUpdatingSummaryRow = false;
    }
  }

  @override
  void dispose() {
    // Remove the listener
    model.removeListener(_onModelChanged);
    super.dispose();
  }

 // Example of conditional formatting
  Widget _formatValue(SalesData data, double value, WidgetBuilderParams<SalesData> params) {
    return Text(
      '\$${value.toStringAsFixed(0)}',
      style: TextStyle(
        fontWeight: value == data.amount || value == data.lastPurchaseAmount
            ? FontWeight.bold 
            : FontWeight.normal,
        color: value == data.usedAmount && value < 100
            ? Colors.yellow 
            : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                'Pivot Table with $totalEntries entries and ${SalesLevel.values.length} levels',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => model.expandAll(),
                child: const Text('Expand All'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => model.collapseAll(),
                child: const Text('Collapse All'),
              ),
            ],
          ),
        ),
        Expanded(child: Davi(model)),
      ],
    );
  }
}
