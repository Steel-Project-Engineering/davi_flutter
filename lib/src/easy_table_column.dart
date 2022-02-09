import 'package:easy_table/src/easy_table_cell.dart';
import 'package:easy_table/src/easy_table_cell_builder.dart';
import 'package:easy_table/src/easy_table_header_cell_builder.dart';
import 'package:easy_table/src/theme/easy_table_theme.dart';
import 'package:easy_table/src/theme/easy_table_theme_data.dart';
import 'package:easy_table/src/easy_table_value_mapper.dart';
import 'package:flutter/widgets.dart';

/// The [EasyTable] column.
abstract class EasyTableColumn<ROW> {
  /// Builds a column by defining the Widget.
  factory EasyTableColumn.builder(EasyTableCellBuilder<ROW> cellBuilder,
      {String? name,
      dynamic id,
      double initialWidth = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder}) {
    return _EasyTableColumnBuilder(
        cellBuilder: cellBuilder,
        name: name,
        id: id,
        initialWidth: initialWidth,
        headerCellBuilder: headerCellBuilder);
  }

  /// Builds a column by mapping the value of a row.
  factory EasyTableColumn.auto(EasyTableValueMapper<ROW> valueMapper,
      {int? fractionDigits,
      dynamic id,
      String? name,
      double initialWidth = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder}) {
    return _EasyTableColumnAuto(
        valueMapper: valueMapper,
        id: id,
        name: name,
        initialWidth: initialWidth,
        fractionDigits: fractionDigits,
        headerCellBuilder: headerCellBuilder);
  }

  EasyTableColumn(
      {this.id, required this.initialWidth, this.name, this.headerCellBuilder});

  final dynamic id;
  final String? name;
  final double initialWidth;
  final EasyTableHeaderCellBuilder? headerCellBuilder;

  Widget? buildCellWidget(BuildContext context, ROW row);
}

class _EasyTableColumnBuilder<ROW> extends EasyTableColumn<ROW> {
  _EasyTableColumnBuilder(
      {required this.cellBuilder,
      dynamic id,
      String? name,
      required double initialWidth,
      EasyTableHeaderCellBuilder? headerCellBuilder})
      : super(
            id: id,
            name: name,
            initialWidth: initialWidth,
            headerCellBuilder: headerCellBuilder);

  final EasyTableCellBuilder<ROW> cellBuilder;

  @override
  Widget? buildCellWidget(BuildContext context, ROW row) {
    return cellBuilder(context, row);
  }
}

class _EasyTableColumnAuto<ROW> extends EasyTableColumn<ROW> {
  _EasyTableColumnAuto(
      {required this.valueMapper,
      dynamic id,
      this.fractionDigits,
      String? name,
      required double initialWidth,
      EasyTableHeaderCellBuilder? headerCellBuilder})
      : super(
            id: id,
            name: name,
            initialWidth: initialWidth,
            headerCellBuilder: headerCellBuilder);

  final EasyTableValueMapper<ROW> valueMapper;
  final int? fractionDigits;

  @override
  Widget? buildCellWidget(BuildContext context, ROW row) {
    dynamic cellValue = valueMapper(row);
    EasyTableThemeData theme = EasyTableTheme.of(context);
    final TextStyle? textStyle = theme.cell.textStyle;
    if (cellValue is String) {
      return EasyTableCell(value: cellValue, textStyle: textStyle);
    } else if (cellValue is int) {
      return EasyTableCell.int(value: cellValue, textStyle: textStyle);
    } else if (cellValue is double) {
      return EasyTableCell.double(
          value: cellValue,
          fractionDigits: fractionDigits,
          textStyle: textStyle);
    } else if (cellValue == null) {
      return EasyTableCell(textStyle: textStyle);
    }
    return EasyTableCell(value: cellValue.toString(), textStyle: textStyle);
  }
}
