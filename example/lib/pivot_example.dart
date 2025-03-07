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
  final double amount;
  final double usedAmount;
  
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
    required this.amount,
    required this.usedAmount,
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
  static const int totalEntries = 100000;

  List<String> _getRandomOptions(String prefix, int count) {
    return List.generate(count, (i) => '$prefix ${i + 1}');
  }

  List<SalesData> _generateData() {
    final stopwatch = Stopwatch()..start();
    final data = <SalesData>[];
    
    // Define possible values for each level
    final divisions = _getRandomOptions('Division', 3);
    final regions = _getRandomOptions('Region', 5);
    final departments = _getRandomOptions('Dept', 4);
    final categories = _getRandomOptions('Category', 6);
    final subCategories = _getRandomOptions('SubCat', 4);
    final products = _getRandomOptions('Product', 8);
    final variants = _getRandomOptions('Variant', 3);
    final sizes = ['S', 'M', 'L', 'XL'];
    final colors = ['Red', 'Blue', 'Green', 'Black', 'White'];
    final batches = _getRandomOptions('Batch', 5);
    
    for (int i = 0; i < totalEntries; i++) {
      final amount = _random.nextDouble() * 10000;
      final usedAmount = amount * (0.6 + (_random.nextDouble() * 0.4));
      
      data.add(SalesData(
        division: divisions[_random.nextInt(divisions.length)],
        region: regions[_random.nextInt(regions.length)],
        department: departments[_random.nextInt(departments.length)],
        category: categories[_random.nextInt(categories.length)],
        subCategory: subCategories[_random.nextInt(subCategories.length)],
        product: products[_random.nextInt(products.length)],
        variant: variants[_random.nextInt(variants.length)],
        size: sizes[_random.nextInt(sizes.length)],
        color: colors[_random.nextInt(colors.length)],
        batch: batches[_random.nextInt(batches.length)],
        amount: amount,
        usedAmount: usedAmount,
      ));
    }

    print('Generated $totalEntries records in ${stopwatch.elapsedMilliseconds}ms');
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
      getLevel: (data) => levels[0],
      getValueForLevel: (data, level) {
        switch (level) {
          case SalesLevel.division: return data.division;
          case SalesLevel.region: return data.region;
          case SalesLevel.department: return data.department;
          case SalesLevel.category: return data.category;
          case SalesLevel.subCategory: return data.subCategory;
          case SalesLevel.product: return data.product;
          case SalesLevel.variant: return data.variant;
          case SalesLevel.size: return data.size;
          case SalesLevel.color: return data.color;
          case SalesLevel.batch: return data.batch;
        }
      },
      aggregate: (groupData) {
        double totalAmount = 0;
        double minUsedAmount = double.infinity;
        
        for (var item in groupData) {
          totalAmount += item.amount;
          minUsedAmount = min(minUsedAmount, item.usedAmount);
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
          amount: totalAmount,
          usedAmount: minUsedAmount,
        );
      },
    );

    final stopwatch = Stopwatch()..start();
    print('Building pivot data...');
    final pivotData = pivotBuilder.build();
    print('Pivot data built in ${stopwatch.elapsedMilliseconds}ms');

    final columns = levels.map((level) => DaviColumn<SalesData>(
      id: level.id,
      name: level.displayName,
      width: 120,
      cellWidget: (params) {
        final hasChildren = model.hasChildren(params.rowIndex);
        final isExpanded = model.isExpanded(params.rowIndex);
        final currentLevel = model.getLevel(params.rowIndex);
        
        if (level != currentLevel) return const SizedBox.shrink();
        
        String text = _getLevelText(params.data, level);
        return Row(
          children: [
            if (hasChildren)
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                ),
                onPressed: () => setState(() => model.toggleExpand(params.rowIndex)),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(),
              ),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: hasChildren ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      },
    )).toList();

    // Add amount columns
    columns.addAll([
      DaviColumn<SalesData>(
        id: 'amount',
        name: 'Amount',
        width: 120,
        cellWidget: (params) => Text(
          '\$${params.data.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: model.hasChildren(params.rowIndex) 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
        ),
      ),
      DaviColumn<SalesData>(
        id: 'usedAmount',
        name: 'Used Amount',
        width: 120,
        cellWidget: (params) => Text(
          '\$${params.data.usedAmount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: model.hasChildren(params.rowIndex) 
                ? FontWeight.bold 
                : FontWeight.normal,
            color: params.data.usedAmount < params.data.amount 
                ? Colors.red 
                : Colors.black,
          ),
        ),
      ),
    ]);

    model = PivotTableModel<SalesData, SalesLevel>(
      pivotData: pivotData,
      columns: columns,
      levels: levels,
    );
  }

  String _getLevelText(SalesData data, SalesLevel level) {
    switch (level) {
      case SalesLevel.division: return data.division;
      case SalesLevel.region: return data.region;
      case SalesLevel.department: return data.department;
      case SalesLevel.category: return data.category;
      case SalesLevel.subCategory: return data.subCategory;
      case SalesLevel.product: return data.product;
      case SalesLevel.variant: return data.variant;
      case SalesLevel.size: return data.size;
      case SalesLevel.color: return data.color;
      case SalesLevel.batch: return data.batch;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Pivot Table with $totalEntries entries and ${SalesLevel.values.length} levels',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(child: Davi(model)),
      ],
    );
  }
}