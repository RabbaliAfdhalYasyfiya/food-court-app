import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../services/models/model.dart';
import '../../../../services/models/model_product.dart';
import '../../../../services/models/model_tenant.dart';
import 'tenant_table.dart';

class VendorLaporanPage extends StatefulWidget {
  const VendorLaporanPage({
    super.key,
    required this.products,
    required this.tenant,
  });

  final List<MenuProduct> products;
  final Tenant tenant;

  @override
  State<VendorLaporanPage> createState() => _VendorLaporanPageState();
}

class _VendorLaporanPageState extends State<VendorLaporanPage> {
  Widget getBottomTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w500,
      fontSize: 13,
    );

    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('Sun', style: style);
        break;
      case 1:
        text = Text('Mon', style: style);
        break;
      case 2:
        text = Text('Tue', style: style);
        break;
      case 3:
        text = Text('Wes', style: style);
        break;
      case 4:
        text = Text('Thu', style: style);
        break;
      case 5:
        text = Text('Fri', style: style);
        break;
      case 6:
        text = Text('Sat', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }

    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

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

  Widget totalCard(
    BuildContext context,
    Color bgColor,
    Color lineColor,
    Icon iconTotal,
    String nameTotal,
    String total,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(width: 2, color: lineColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nameTotal,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                  height: 1,
                ),
              ),
              const Gap(5),
              iconTotal,
            ],
          ),
          const Gap(5),
          Padding(
            padding: const EdgeInsets.only(left: 7.5),
            child: Text(
              total,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
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
        title: const Text('Report'),
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
                    'Edit',
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('vendor_id', isEqualTo: widget.tenant.vendorId)
              .snapshots(),
          builder: (context, AsyncSnapshot orderSnapshot) {
            if (orderSnapshot.hasError) {
              debugPrint('${orderSnapshot.error}');
              return Center(
                child: Text('An error occurred: ${orderSnapshot.error}'),
              );
            }

            if (orderSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final orderData =
                orderSnapshot.data!.docs.map((doc) => OrderProduct.fromDocument(doc)).toList();

            orderData.sort((a, b) => b.orderTime.compareTo(a.orderTime) as int);

            int totalProduct = orderData.fold(0, (sum, order) => sum + order.product.length);

            List<Product> allProducts = [];

            for (var order in orderData) {
              for (var product in order.product) {
                allProducts.add(
                  Product.fromDocument(
                    {
                      'product_id': product.productId,
                      'image_product': product.imageProduct,
                      'name_product': product.nameProduct,
                      'price_product': product.priceProduct,
                      'quantity_product': product.quantityProduct,
                      'value_total': product.valueTotal,
                    },
                    order.orderTime,
                    order.payMethod,
                  ),
                );
              }
            }

            double totalValue = 0.0;
            for (var product in allProducts) {
              totalValue += product.valueTotal;
            }

            debugPrint('Total : $totalValue');

            Map<int, double> totalsByDay = {0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0};

            for (var product in allProducts) {
              int day =
                  product.orderTime.toDate().weekday % 7; // 0 untuk Minggu, 1 untuk Senin, dst.
              totalsByDay[day] = totalsByDay[day]! + product.valueTotal;
            }

            BarData barData = BarData(
              sunTotal: totalsByDay[0]!,
              monTotal: totalsByDay[1]!,
              tueTotal: totalsByDay[2]!,
              wedTotal: totalsByDay[3]!,
              thuTotal: totalsByDay[4]!,
              friTotal: totalsByDay[5]!,
              satTotal: totalsByDay[6]!,
            );

            barData.initalizeBarData();

            double maxYValue = barData.barData.map((bar) => bar.y).reduce((a, b) => a > b ? a : b);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.tenant.vendorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GridView(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      totalCard(
                        context,
                        Colors.indigoAccent.shade400.withOpacity(0.05),
                        Colors.indigoAccent.shade400.withOpacity(0.1),
                        Icon(
                          Iconsax.people5,
                          size: 25,
                          color: Colors.indigoAccent.shade400,
                        ),
                        'Total Customers',
                        '${orderData.length}',
                      ),
                      totalCard(
                        context,
                        Colors.greenAccent.shade400.withOpacity(0.05),
                        Colors.greenAccent.shade400.withOpacity(0.1),
                        Icon(
                          Iconsax.shopping_cart5,
                          size: 25,
                          color: Colors.greenAccent.shade400,
                        ),
                        'Total Orders',
                        '$totalProduct',
                      ),
                      totalCard(
                        context,
                        Colors.purpleAccent.shade400.withOpacity(0.05),
                        Colors.purpleAccent.shade400.withOpacity(0.1),
                        Icon(
                          Iconsax.note_215,
                          size: 25,
                          color: Colors.purpleAccent.shade400,
                        ),
                        'Total Products',
                        '${widget.products.length}',
                      ),
                      totalCard(
                        context,
                        Colors.amberAccent.shade400.withOpacity(0.05),
                        Colors.amberAccent.shade400.withOpacity(0.1),
                        Icon(
                          Iconsax.dollar_square5,
                          size: 25,
                          color: Colors.amberAccent.shade400,
                        ),
                        'Total Sales',
                        'Rp ${totalValue == 0 ? '-' : NumberFormat('#,##0.000', 'id_ID').format(totalValue).replaceAll(',', '.')}',
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.shade400.withOpacity(0.05),
                        border: Border.all(
                            width: 2, color: Colors.cyanAccent.shade400.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: allProducts.isEmpty
                          ? Center(
                              child: Text(
                                'Order results has no data',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Order Results',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => TenantTable(
                                              allProducts: allProducts,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Theme.of(context).primaryColor.withOpacity(0.1)),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: Text(
                                        'See all',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(5),
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    physics: const NeverScrollableScrollPhysics(),
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
                                            border: TableBorder.symmetric(
                                              inside: BorderSide(
                                                width: 0.05,
                                                color: Theme.of(context).colorScheme.secondary,
                                              ),
                                            ),
                                            headingRowColor: WidgetStatePropertyAll(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.015),
                                            ),
                                            columns: [
                                              DataColumn(
                                                label: dataColumn('Menu'),
                                              ),
                                            ],
                                            rows: allProducts.map(
                                              (e) {
                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text(
                                                        e.nameProduct,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                        style:
                                                            Theme.of(context).textTheme.bodySmall,
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
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              columnSpacing: 15,
                                              showBottomBorder: true,
                                              dividerThickness: 0.15,
                                              horizontalMargin: 15,
                                              border: TableBorder.symmetric(
                                                inside: BorderSide(
                                                  width: 0.05,
                                                  color: Theme.of(context).colorScheme.secondary,
                                                ),
                                              ),
                                              headingRowColor: WidgetStatePropertyAll(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.015),
                                              ),
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
                                              rows: allProducts.map(
                                                (e) {
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Center(
                                                          child: Text(
                                                            DateFormat('dd/MMM/yyyy, hh:mm')
                                                                .format(e.orderTime.toDate()),
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodySmall,
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Center(
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 7.5, vertical: 2.5),
                                                            decoration: BoxDecoration(
                                                              color: e.payMethod != 'Cash'
                                                                  ? Colors.blue.shade50
                                                                      .withOpacity(0.85)
                                                                  : Colors.green.shade50
                                                                      .withOpacity(0.85),
                                                              border: Border.all(
                                                                width: 1,
                                                                color: e.payMethod != 'Cash'
                                                                    ? Colors.blue
                                                                    : Colors.green,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(50),
                                                            ),
                                                            child: Text(
                                                              e.payMethod,
                                                              style: TextStyle(
                                                                color: e.payMethod != 'Cash'
                                                                    ? Colors.blue
                                                                    : Colors.green,
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
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodySmall,
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          'Rp ${NumberFormat('#,##0.000', 'id_ID').format(e.valueTotal).replaceAll(',', '.')}',
                                                          style:
                                                              Theme.of(context).textTheme.bodySmall,
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
                                const Gap(10),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                                    decoration: BoxDecoration(
                                      color: Colors.cyanAccent.shade400.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: LineChart(
                                      curve: Curves.easeIn,
                                      duration: const Duration(milliseconds: 250),
                                      LineChartData(
                                        maxY: maxYValue * 1.15,
                                        minY: 0,
                                        maxX: 6,
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 0.25,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            left: BorderSide(
                                              width: 0.25,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            right: BorderSide(
                                              width: 0.25,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          leftTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            drawBelowEverything: true,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 25,
                                              getTitlesWidget: getBottomTitles,
                                            ),
                                          ),
                                        ),
                                        extraLinesData: ExtraLinesData(
                                          horizontalLines: barData.barData.map(
                                            (e) {
                                              return HorizontalLine(
                                                y: e.y.toDouble(),
                                                strokeWidth: 0.5,
                                                color: e.y == 0
                                                    ? Colors.transparent
                                                    : Theme.of(context).colorScheme.secondary,
                                                strokeCap: StrokeCap.butt,
                                                label: HorizontalLineLabel(
                                                  show: true,
                                                  direction: LabelDirection.horizontal,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: e.x.toDouble() * 40,
                                                    vertical: 5,
                                                  ),
                                                  style: TextStyle(
                                                    color: e.y == maxYValue
                                                        ? Theme.of(context).primaryColor
                                                        : Theme.of(context).colorScheme.primary,
                                                    fontWeight: e.y == maxYValue
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                  ),
                                                  labelResolver: (line) => line.y == 0
                                                      ? ''
                                                      : 'Rp ${NumberFormat('#,##0.000', 'id_ID').format(line.y).replaceAll(',', '.')}',
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: barData.barData.map((bar) {
                                              return FlSpot(bar.x.toDouble(), bar.y.toDouble());
                                            }).toList(),
                                            isCurved: true,
                                            curveSmoothness: 0.5,
                                            preventCurveOverShooting: true,
                                            preventCurveOvershootingThreshold: 10,
                                            color: Theme.of(context).primaryColor,
                                            barWidth: 2,
                                            dotData: const FlDotData(show: true),
                                            show: true,
                                            showingIndicators: List.generate(
                                                barData.barData.length, (index) => index),
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              color:
                                                  Theme.of(context).primaryColor.withOpacity(0.2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
