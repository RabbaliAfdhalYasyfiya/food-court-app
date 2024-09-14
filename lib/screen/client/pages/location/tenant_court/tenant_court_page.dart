import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../services/models/model_product.dart';
import '../../../../../services/models/model_tenant.dart';
import '../../../../../widget/bottom_sheet.dart';
import '../../../../../widget/snackbar.dart';
import '../../../../../widget/tile.dart';
import 'tenant_appbar.dart';
import 'tenant_info.dart';

class TenantCourtPage extends StatefulWidget {
  const TenantCourtPage({
    super.key,
    required this.tenant,
    required this.products,
  });

  final List<MenuProduct> products;
  final Tenant tenant;

  @override
  State<TenantCourtPage> createState() => _TenantCourtPageState();
}

class _TenantCourtPageState extends State<TenantCourtPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

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
        .doc(currentUser.uid)
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

  Widget productNull() {
    return const SizedBox(
      height: 325,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'The Menu',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Text(
            'has not been entered by the Tenant',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          TenantAppbar(imagePlace: widget.tenant.imagePlace),
          SliverToBoxAdapter(
            child: TenantInfo(
              products: widget.products,
              tenant: widget.tenant,
              currentUser: currentUser,
            ),
          ),
          SliverList.separated(
            separatorBuilder: (context, index) => const Gap(10),
            itemCount: widget.products.isEmpty
                ? 1
                : widget.products.length <= 4
                    ? widget.products.length
                    : 4,
            itemBuilder: (context, index) {
              if (widget.products.isEmpty) {
                return productNull();
              } else {
                final product = widget.products[index];
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
              }
            },
          ),
          const SliverGap(15),
        ],
      ),
    );
  }
}
