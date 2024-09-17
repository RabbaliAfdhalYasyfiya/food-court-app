import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../services/models/model_product.dart';

class TenantTable extends StatefulWidget {
  const TenantTable({
    super.key,
    required this.allProducts,
  });

  final List<Product> allProducts;

  @override
  State<TenantTable> createState() => _TenantTableState();
}

class _TenantTableState extends State<TenantTable> {
  Widget dataColumn(
    String title,
  ) {
    return Text(
      title,
      maxLines: 2,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        height: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
          ),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 2,
        title: const Text('Table Order'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              radius: 10,
              splashColor: Theme.of(context).primaryColor.withOpacity(0.15),
              overlayColor:
                  WidgetStatePropertyAll(Theme.of(context).primaryColor.withOpacity(0.15)),
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'Print',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 115,
                  child: DataTable(
                    showBottomBorder: true,
                    horizontalMargin: 10,
                    dividerThickness: 0.15,
                    border: const TableBorder.symmetric(inside: BorderSide(width: 0.05)),
                    headingRowColor: WidgetStatePropertyAll(Colors.black12.withOpacity(0.015)),
                    columns: [
                      DataColumn(
                        label: dataColumn('Menu'),
                      ),
                    ],
                    rows: widget.allProducts.map(
                      (e) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                e.nameProduct,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            )
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ),
                const Gap(5),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 25,
                      showBottomBorder: true,
                      dividerThickness: 0.15,
                      horizontalMargin: 15,
                      border: const TableBorder.symmetric(inside: BorderSide(width: 0.05)),
                      headingRowColor: WidgetStatePropertyAll(Colors.black12.withOpacity(0.015)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      columns: [
                        DataColumn(
                          label: dataColumn('Date Due'),
                          headingRowAlignment: MainAxisAlignment.center,
                        ),
                        DataColumn(
                          label: dataColumn('Pay Method'),
                          headingRowAlignment: MainAxisAlignment.center,
                        ),
                        DataColumn(
                          label: dataColumn('Qty'),
                          headingRowAlignment: MainAxisAlignment.center,
                        ),
                        DataColumn(
                          label: dataColumn('Amount'),
                          headingRowAlignment: MainAxisAlignment.center,
                        ),
                      ],
                      rows: widget.allProducts.map(
                        (e) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Center(
                                  child: Text(
                                    DateFormat('dd/MMM/yyyy, hh:mm').format(e.orderTime.toDate()),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: e.payMethod != 'Cash'
                                          ? Colors.blue.shade50
                                          : Colors.green.shade50,
                                      border: Border.all(
                                        width: 1,
                                        color: e.payMethod != 'Cash' ? Colors.blue : Colors.green,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      e.payMethod,
                                      style: TextStyle(
                                        color: e.payMethod != 'Cash' ? Colors.blue : Colors.green,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    '${e.quantityProduct.toString()}x',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  'Rp ${NumberFormat('#,##0.000', 'id_ID').format(e.valueTotal).replaceAll(',', '.')}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  // 'Rp ${e.valueTotal.toStringAsFixed(3)}',
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
