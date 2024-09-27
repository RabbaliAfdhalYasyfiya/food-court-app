import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';

import '../../../../services/models/model_product.dart';
import '../../../../widget/bottom_sheet.dart';
import '../../../../widget/button.dart';
import '../../../../widget/snackbar.dart';
import '../../../../widget/load.dart';
import 'order_success.dart';

enum ProductTypeEnum { QRIS, Cash }

class CartOrder extends StatefulWidget {
  const CartOrder({
    super.key,
    required this.currentTenant,
    required this.selectedProducts,
    required this.selectedQuantities,
  });

  final User currentTenant;
  final List<MenuProduct> selectedProducts;
  final List<int> selectedQuantities;

  @override
  State<CartOrder> createState() => _CartOrderState();
}

class _CartOrderState extends State<CartOrder> {
  ProductTypeEnum? _productTypeEnum;

  bool isCheckoutCardVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 250),
      () {
        setState(() {
          isCheckoutCardVisible = true;
        });
      },
    );
  }

  void addCheckoutProduct() async {
    showLoading(context);

    final List<Product> orderProduct = [];
    double subTotal = _calculateSubtotal();
    double taxFee = 1;
    double priceTotal = 0.0 + taxFee;

    var payMethod = _productTypeEnum?.name;
    var orderTime = FieldValue.serverTimestamp();
    for (int i = 0; i < widget.selectedProducts.length; i++) {
      final product = widget.selectedProducts[i];
      final quantity = widget.selectedQuantities[i];
      final double price = double.tryParse(product.priceProduct.replaceAll('Rp', '')) ?? 0.0;
      final double valuePrice = price * quantity;

      orderProduct.add(Product(
        productId: product.productId,
        imageProduct: product.imageProduct,
        nameProduct: product.nameProduct,
        priceProduct: price,
        quantityProduct: quantity,
        valueTotal: valuePrice,
        orderTime: Timestamp.now(),
        payMethod: payMethod!,
      ));

      priceTotal += valuePrice;

      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(widget.currentTenant.uid)
          .collection('products')
          .doc(product.productId)
          .update({
        'stock_product': FieldValue.increment(-quantity),
      });
    }

    DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add({
      'vendor_id': widget.currentTenant.uid,
      'product': orderProduct
          .map(
            (p) => {
              'product_id': p.productId,
              'image_product': p.imageProduct,
              'name_product': p.nameProduct,
              'price_product': p.priceProduct,
              'quantity_product': p.quantityProduct,
              'value_total': p.valueTotal,
            },
          )
          .toList(),
      'sub_total': subTotal,
      'price_total': priceTotal,
      'pay_method': payMethod,
      'order_time': orderTime,
    });
    await orderRef.update({
      'order_id': orderRef.id,
    });

    // Get the actual order data including the timestamp
    DocumentSnapshot orderSnapshot = await orderRef.get();
    var actualOrderTime = orderSnapshot.get('order_time') as Timestamp;

    for (var product in orderProduct) {
      product.orderTime = actualOrderTime;
    }

    hideLoading(context);

    Navigator.push(
      context,
      createRoute(
        OrderSuccess(
          orderedProducts: orderProduct,
          priceTotal: priceTotal,
          taxFee: taxFee,
          payMethod: payMethod!,
          tenantId: widget.currentTenant.uid,
          orderTime: actualOrderTime,
          initialIndex: 0,
          badge: true,
        ),
      ),
    );

    snackBarCustom(
      context,
      Colors.greenAccent.shade400,
      'Orders, Menu Successfully',
      Colors.white,
    );
  }

  ScrollController scrollController = ScrollController();

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

  Widget checkoutCard(
    BuildContext context,
    int items,
    double subtotal,
    double taxFee,
    double orderTotal,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 25,
      color: Theme.of(context).navigationBarTheme.shadowColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menu Items',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '$items',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Rp ${NumberFormat('#,##0.000', 'id_ID').format(subtotal).replaceAll(',', '.')}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tax Fee',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Rp ${NumberFormat('#,##0.000', 'id_ID').format(taxFee).replaceAll(',', '.')}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(5),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,##0.000', 'id_ID').format(orderTotal).replaceAll(',', '.')}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 0.5,
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).dividerColor,
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Gap(10),
                      Icon(
                        Iconsax.empty_wallet,
                        size: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(10),
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: RadioListTile<ProductTypeEnum>(
                            visualDensity: VisualDensity.compact,
                            activeColor: Theme.of(context).primaryColor,
                            value: ProductTypeEnum.QRIS,
                            title: Text(
                              ProductTypeEnum.QRIS.name,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            groupValue: _productTypeEnum,
                            onChanged: (value) {
                              setState(() {
                                _productTypeEnum = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: RadioListTile<ProductTypeEnum>(
                            visualDensity: VisualDensity.compact,
                            activeColor: Theme.of(context).primaryColor,
                            value: ProductTypeEnum.Cash,
                            title: Text(
                              ProductTypeEnum.Cash.name,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            groupValue: _productTypeEnum,
                            onChanged: (value) {
                              setState(() {
                                _productTypeEnum = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(10),
            ButtonPrimary(
              onPressed: () {
                if (widget.selectedProducts.isEmpty) {
                  snackBarCustom(
                    context,
                    Colors.redAccent.shade400,
                    'Products, Ordered in Cart are Empty',
                    Colors.white,
                  );
                } else if (_productTypeEnum == null) {
                  snackBarCustom(
                    context,
                    Colors.redAccent.shade400,
                    'Payment Method, not Checked',
                    Colors.white,
                  );
                } else {
                  addCheckoutProduct();
                }
              },
              child: const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(int index) {
    showLoading(context);
    setState(() {
      widget.selectedProducts.removeAt(index);
      widget.selectedQuantities.removeAt(index);
      _calculateSubtotal();
    });
    Navigator.pop(context);
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (int i = 0; i < widget.selectedProducts.length; i++) {
      final double price =
          double.tryParse(widget.selectedProducts[i].priceProduct.replaceAll('Rp', '')) ?? 0;
      subtotal += price * widget.selectedQuantities[i];
    }
    return subtotal;
  }

  void countInfoEdit(
    final String imageProduct,
    final String nameProduct,
    final int quantity,
    final double valuePrice,
    final int index,
    final Function(int) deleteProduct,
  ) {
    showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 1 / 2,
      isScrollControlled: false,
      enableDrag: false,
      useRootNavigator: false,
      showDragHandle: false,
      useSafeArea: true,
      isDismissible: false,
      barrierColor: Theme.of(context).colorScheme.tertiary,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomEditCount(
          imageProduct: imageProduct,
          nameProduct: nameProduct,
          quantity: quantity,
          valuePrice: valuePrice,
          index: index,
          deleteProduct: deleteProduct,
          onSaveChanges: (newQuantity, newTotalPrice) {
            updateProduct(index, newQuantity);
          },
        );
      },
    );
  }

  void updateProduct(int index, int newQuantity) {
    setState(() {
      widget.selectedQuantities[index] = newQuantity;
      _calculateSubtotal(); // Update the subtotal
    });
  }

  @override
  Widget build(BuildContext context) {
    double subTotal = _calculateSubtotal();
    double taxFee = 1; // Example fixed tax fee
    double orderTotal = subTotal + taxFee;

    if (widget.selectedProducts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          Navigator.pop(context);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
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
        title: const Text('Cart Order'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: widget.selectedProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Nodata-pana.png',
                            width: 200,
                          ),
                          const Gap(15),
                          Text(
                            'Here, there are',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Text(
                            'no Menus in Cart yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ScrollbarTheme(
                      data: const ScrollbarThemeData(
                        crossAxisMargin: 0,
                        trackVisibility: WidgetStatePropertyAll(false),
                        thumbVisibility: WidgetStatePropertyAll(true),
                        interactive: true,
                        minThumbLength: 5,
                        radius: Radius.circular(50),
                        thickness: WidgetStatePropertyAll(5),
                        mainAxisMargin: 50,
                        thumbColor: WidgetStatePropertyAll(Colors.black26),
                      ),
                      child: Scrollbar(
                        controller: scrollController,
                        child: ListView.separated(
                          separatorBuilder: (context, index) => const Gap(10),
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: widget.selectedProducts.length,
                          itemBuilder: (context, index) {
                            final product = widget.selectedProducts[index];
                            final quantity = widget.selectedQuantities[index];
                            final double price =
                                double.tryParse(product.priceProduct.replaceAll('Rp', '')) ?? 0;
                            final double valuePrice = price * quantity;
                            return Slidable(
                              closeOnScroll: true,
                              direction: Axis.horizontal,
                              enabled: true,
                              dragStartBehavior: DragStartBehavior.start,
                              endActionPane: ActionPane(
                                motion: const BehindMotion(),
                                extentRatio: 0.15,
                                children: [
                                  SlidableAction(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    backgroundColor: Colors.redAccent.shade400,
                                    borderRadius: BorderRadius.circular(15),
                                    foregroundColor: Colors.white,
                                    icon: Iconsax.trash,
                                    autoClose: true,
                                    onPressed: (context) {
                                      _deleteProduct(index);
                                    },
                                  ),
                                ],
                              ),
                              child: ListTile(
                                tileColor: Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                      color: Theme.of(context).colorScheme.outline, width: 0.5),
                                ),
                                autofocus: true,
                                dense: false,
                                style: ListTileStyle.list,
                                visualDensity: VisualDensity.comfortable,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12.5, vertical: 5),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: Container(
                                        height: double.infinity,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Theme.of(context).colorScheme.onPrimary,
                                              Theme.of(context).colorScheme.onSecondary,
                                              Theme.of(context).colorScheme.onTertiary,
                                            ],
                                          ),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: product.imageProduct,
                                          filterQuality: FilterQuality.low,
                                          fit: BoxFit.cover,
                                          useOldImageOnUrlChange: true,
                                          fadeInCurve: Curves.easeIn,
                                          fadeOutCurve: Curves.easeOut,
                                          fadeInDuration: const Duration(milliseconds: 500),
                                          fadeOutDuration: const Duration(milliseconds: 750),
                                        )
                                        //Image.network(e.imageProduct),
                                        ),
                                  ),
                                ),
                                title: Text(
                                  product.nameProduct,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    height: 1,
                                  ),
                                ),
                                subtitle: Text(
                                  '${quantity}x',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onLongPress: () {
                                        _deleteProduct(index);
                                      },
                                      onTap: () {
                                        countInfoEdit(
                                          product.imageProduct,
                                          product.nameProduct,
                                          quantity,
                                          valuePrice,
                                          index,
                                          (index) {
                                            _deleteProduct(index);
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      radius: 15,
                                      splashColor: Theme.of(context).primaryColor.withOpacity(0.15),
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Rp ${NumberFormat('#,##0.000', 'id_ID').format(valuePrice).replaceAll(',', '.')}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
            Expanded(
              flex: 6,
              child: AnimatedSlide(
                offset: isCheckoutCardVisible ? const Offset(0, 0) : const Offset(0, 1),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: checkoutCard(
                  context,
                  widget.selectedProducts.length,
                  subTotal,
                  taxFee,
                  orderTotal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
