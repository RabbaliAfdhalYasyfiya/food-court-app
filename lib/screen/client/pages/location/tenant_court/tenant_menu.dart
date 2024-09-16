import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../services/models/model_product.dart';
import '../../../../../services/models/model_tenant.dart';
import '../../../../../widget/bottom_sheet.dart';
import '../../../../../widget/snackbar.dart';
import '../../../../../widget/tile.dart';

class TenantMenu extends StatefulWidget {
  const TenantMenu({
    super.key,
    required this.products,
    required this.tenant,
    required this.currentUser,
  });

  final List<MenuProduct> products;
  final Tenant tenant;
  final User currentUser;

  @override
  State<TenantMenu> createState() => _TenantMenuState();
}

class _TenantMenuState extends State<TenantMenu> {
  @override
  Widget build(BuildContext context) {
    Map<String, List<MenuProduct>> categorizedProducts = {};
    for (var product in widget.products) {
      if (categorizedProducts[product.categoryProduct] == null) {
        categorizedProducts[product.categoryProduct] = [];
      }
      categorizedProducts[product.categoryProduct]!.add(product);
    }

    List<Widget> sliverListItems = [];
    categorizedProducts.forEach(
      (category, products) {
        sliverListItems.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 7),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        );
        sliverListItems.add(
          SliverList.separated(
            separatorBuilder: (context, index) => const Gap(10),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return TileMenu(
                image: product.imageProduct,
                nameMenu: product.nameProduct,
                price: product.priceProduct,
                category: product.categoryProduct,
                descMenu: product.descProduct,
                ontap: () {
                  showCardProduct(
                    product.productId,
                    product.imageProduct,
                    product.nameProduct,
                    product.priceProduct,
                    product.categoryProduct,
                    product.descProduct,
                  );
                },
              );
            },
          ),
        );
        sliverListItems.add(
          const SliverGap(15),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black,
        scrolledUnderElevation: 0,
        titleSpacing: 2,
        title: Text(
          'Menu Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
          ),
        ),
        leading: IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Text(
              '(${widget.products.length})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: sliverListItems,
      ),
    );
  }

  void addFavorite(
    String productId,
    String imageProduct,
    String nameProduct,
    String priceProduct,
    String categoryProduct,
    String descriptionProduct,
  ) async {
    await FirebaseFirestore.instance
        .collection('clients')
        .doc(widget.currentUser.uid)
        .collection('favorites')
        .doc(productId)
        .set({
      'product_id': productId,
      'image_product': imageProduct,
      'name_product': nameProduct,
      'price_product': priceProduct,
      'category_product': categoryProduct,
      'description_product': descriptionProduct,
    });
  }

  void showCardProduct(
    String productId,
    String imageProduct,
    String nameProduct,
    String priceProduct,
    String categoryProduct,
    String descProduct,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      enableDrag: false,
      useRootNavigator: false,
      showDragHandle: false,
      useSafeArea: true,
      isDismissible: false,
      elevation: 0,
      scrollControlDisabledMaxHeightRatio: 1 / 1.5,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomMenuInfo(
          productId: productId,
          imageProduct: imageProduct,
          nameProduct: nameProduct,
          priceProduct: priceProduct,
          categoryProduct: categoryProduct,
          descProduct: descProduct,
          onPressed: () {
            addFavorite(
              productId,
              imageProduct,
              nameProduct,
              priceProduct,
              categoryProduct,
              descProduct,
            );

            snackBarCustom(
              context,
              Theme.of(context).primaryColor,
              '$nameProduct add Favorites, Successfully',
              Colors.white,
            );

            Navigator.pop(context);
          },
        );
      },
    );
  }
}
