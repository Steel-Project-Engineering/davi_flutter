import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: PivotTableExample(),
    ),
  ));
}

class SalesData {
  final String region;
  final String product;
  final double amount;
  
  SalesData(this.region, this.product, this.amount);
}

class PivotTableExample extends StatefulWidget {
  const PivotTableExample({super.key});

  @override
  State<PivotTableExample> createState() => _PivotTableExampleState();
}

class _PivotTableExampleState extends State<PivotTableExample> {
  late PivotTableModel<SalesData> model;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() {
    final data = [
      SalesData('North', 'Product A', 100),
      SalesData('North', 'Product B', 150),
      SalesData('South', 'Product A', 200),
      SalesData('South', 'Product B', 175),
    ];

    final pivotBuilder = PivotBuilder<SalesData>(
      data: data,
      groupBy: (data) => [data.region, data.product],
      aggregate: (groupData) {
        double total = groupData.fold(0, (sum, item) => sum + item.amount);
        return SalesData(
          groupData.first.region,
          groupData.first.product,
          total
        );
      },
    );

    final pivotData = pivotBuilder.build();
    final columns = [
      DaviColumn<SalesData>(
        id: 'region',
        name: 'Region',
        width: 200,
        cellWidget: (params) {
          final level = model.getLevel(params.rowIndex);
          final hasChildren = model.hasChildren(params.rowIndex);
          final isExpanded = model.isExpanded(params.rowIndex);
          
          return Row(
            children: [
              SizedBox(width: level * 24.0),
              if (hasChildren)
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                  ),
                  onPressed: () => setState(() {
                    model.toggleExpand(params.rowIndex);
                  }),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                ),
              if (!hasChildren)
                const SizedBox(width: 20),
              Text(params.data.region),
              if (hasChildren)
                Text(' (${params.data.product})'),
            ],
          );
        },
      ),
      DaviColumn<SalesData>(
        id: 'amount',
        name: 'Amount',
        width: 100,
        cellWidget: (params) => Text(
          '\$${params.data.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: model.hasChildren(params.rowIndex) 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
        ),
      ),
    ];

    model = PivotTableModel<SalesData>(
      pivotData: pivotData,
      columns: columns,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Davi(model);
  }
}