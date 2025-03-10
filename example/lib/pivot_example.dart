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
      valueColumns: {
        'Amount': (data) => data.amount,
        'Used Amount': (data) => data.usedAmount,
        'Purchase Amount': (data) => data.lastPurchaseAmount,
      },
      detailColumns: {
        'Item Name': (data) => data.itemName,
      },
      valueFormatter: _formatValue,
    );

    model = PivotTableModel.withColumnBuilder(
      pivotData: pivotData,
      levels: levels,
      columnBuilder: columnBuilder,
    );
  }

  Widget _formatValue(SalesData data, double value, WidgetBuilderParams<SalesData> params) {
    return Text(
      '\$${value.toStringAsFixed(0)}',
      style: TextStyle(
        fontWeight: value == data.amount || value == data.lastPurchaseAmount
            ? FontWeight.bold 
            : FontWeight.normal,
        color: value == data.usedAmount && value < data.amount
            ? Colors.red 
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