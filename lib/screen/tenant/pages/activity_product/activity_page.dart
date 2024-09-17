import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../services/models/model_product.dart';
import '../order_product/order_success.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final currentTenant = FirebaseAuth.instance.currentUser;

  Widget activityLoad() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.onPrimary,
          highlightColor: Theme.of(context).colorScheme.onSecondary,
          direction: ShimmerDirection.ltr,
          enabled: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 25,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Divider(
                  thickness: 1.5,
                  color: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        ),
        const Gap(10),
        ListView.separated(
          separatorBuilder: (context, index) => const Gap(10),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  height: 55,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.onPrimary,
                    highlightColor: Theme.of(context).colorScheme.onSecondary,
                    direction: ShimmerDirection.ltr,
                    enabled: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                            ),
                            const Gap(10),
                            Container(
                              height: 25,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 25,
                          width: 85,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(10),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.onPrimary,
                  highlightColor: Theme.of(context).colorScheme.onSecondary,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 55,
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  const Gap(10),
                                  Container(
                                    height: 25,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 25,
                                width: 85,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const Gap(10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 25,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      const Gap(5),
                                      Container(
                                        height: 20,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                height: 22,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Route createRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('vendor_id', isEqualTo: currentTenant!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('${snapshot.error}');
              return Center(
                child: Text('An error occurred: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                separatorBuilder: (context, index) => const Gap(15),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return activityLoad();
                },
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Nodata-pana.png',
                      width: 200,
                    ),
                    const Gap(25),
                    const Text(
                      'Here, no Activities have arrived yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }

            final orderData =
                snapshot.data!.docs.map((doc) => OrderProduct.fromDocument(doc)).toList();

            orderData.sort((a, b) => b.orderTime.compareTo(a.orderTime));

            final orderTimes = <String, List<OrderProduct>>{};
            for (var order in orderData) {
              final orderDate = DateFormat('MMMM dd, yyyy').format(order.orderTime.toDate());
              if (orderTimes.containsKey(orderDate)) {
                orderTimes[orderDate]!.add(order);
              } else {
                orderTimes[orderDate] = [order];
              }
            }

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

            double taxFee = 1.0;
            double totalValue = 0.0;

            for (var product in allProducts) {
              totalValue += product.valueTotal;
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const Gap(10),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: orderTimes.keys.length,
                    itemBuilder: (context, index) {
                      final date = orderTimes.keys.elementAt(index);
                      final orders = orderTimes[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                date,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                              ),
                              const Gap(10),
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ],
                          ),
                          const Gap(5),
                          ListView.separated(
                            separatorBuilder: (context, index) => const Gap(10),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];

                              List<Product> allProducts = [];

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

                              return InkWell(
                                splashColor: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(15),
                                onDoubleTap: () {
                                  debugPrint('Order ID : ${order.orderId}');
                                  Navigator.push(
                                    context,
                                    createRoute(
                                      OrderSuccess(
                                        orderedProducts: allProducts,
                                        priceTotal: order.priceTotal,
                                        payMethod: order.payMethod,
                                        taxFee: 1,
                                        vendorId: currentTenant!.uid,
                                        orderTime: order.orderTime,
                                        initialIndex: 1,
                                      ),
                                    ),
                                  );
                                },
                                child: ExpansionTile(
                                  visualDensity: VisualDensity.comfortable,
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 12.5),
                                  expansionAnimationStyle: AnimationStyle(
                                    curve: Curves.easeInSine,
                                    duration: const Duration(milliseconds: 150),
                                  ),
                                  expandedCrossAxisAlignment: CrossAxisAlignment.end,
                                  expandedAlignment: Alignment.topCenter,
                                  initiallyExpanded: false,
                                  collapsedBackgroundColor:
                                      Theme.of(context).colorScheme.onTertiary,
                                  childrenPadding:
                                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    //side: const BorderSide(width: 0.5, color: Colors.black54),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        width: 0.5, color: Theme.of(context).colorScheme.secondary),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: order.payMethod == 'QRIS'
                                        ? Colors.blue.shade50
                                        : Colors.green.shade50,
                                    child: Icon(
                                      order.payMethod == 'QRIS'
                                          ? Iconsax.scan_barcode
                                          : Iconsax.moneys,
                                      color: order.payMethod == 'QRIS' ? Colors.blue : Colors.green,
                                    ),
                                  ),
                                  title: Text(order.payMethod),
                                  subtitle: Text(
                                    order.orderId,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                  showTrailingIcon: true,
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Rp ${NumberFormat('#,##0.000', 'id_ID').format(order.priceTotal).replaceAll(',', '.')}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        '+ Rp ${NumberFormat('#,##0.000', 'id_ID').format(taxFee).replaceAll(',', '.')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: allProducts.map(
                                    (e) {
                                      return ListTile(
                                        visualDensity: VisualDensity.compact,
                                        leading: AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.grey.shade200,
                                                    Colors.grey.shade100,
                                                    Colors.grey.shade50,
                                                  ],
                                                ),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: e.imageProduct,
                                                filterQuality: FilterQuality.low,
                                                fit: BoxFit.cover,
                                                useOldImageOnUrlChange: true,
                                                fadeInCurve: Curves.easeIn,
                                                fadeOutCurve: Curves.easeOut,
                                                fadeInDuration: const Duration(milliseconds: 500),
                                                fadeOutDuration: const Duration(milliseconds: 750),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          e.nameProduct,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 16,
                                            height: 1,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${e.quantityProduct}x',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        trailing: Text(
                                          'Rp ${NumberFormat('#,##0.000', 'id_ID').format(e.valueTotal).replaceAll(',', '.')}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              );
                            },
                          ),
                          const Gap(10),
                        ],
                      );
                    },
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 25,
                    color: Theme.of(context).navigationBarTheme.shadowColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const Gap(20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Tax Fee',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              Text(
                                'Rp ${NumberFormat('#,##0.000', 'id_ID').format(taxFee * orderData.length).replaceAll(',', '.')}',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          const Gap(5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Sales',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Rp ${NumberFormat('#,##0.000', 'id_ID').format(totalValue).replaceAll(',', '.')}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
