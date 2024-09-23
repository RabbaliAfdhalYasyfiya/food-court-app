import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';

import '../../../../services/models/model_product.dart';
import '../../../../widget/snackbar.dart';
import '../../../../widget/tile.dart';
import '../add_product.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final currentTenant = FirebaseAuth.instance.currentUser;

  Future<List<String>> fetchCategories() async {
    final categories = <String>{}; // Menggunakan Set untuk menghindari duplikasi

    // Ambil dokumen produk berdasarkan vendorId
    final productsSnapshot = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(currentTenant!.uid)
        .collection('products')
        .get();

    // Iterasi dokumen untuk mendapatkan category_product
    for (var doc in productsSnapshot.docs) {
      final category = doc.data()['category_product'] as String;
      if (category.isNotEmpty) {
        categories.add(category); // Menambahkan ke Set (otomatis menghindari duplikasi)
      }
    }

    return categories.toList(); // Konversi Set ke List
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        disabledElevation: 5,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AddProduct(
                currentTenant: currentTenant!,
              ),
            ),
          );
        },
        isExtended: true,
        tooltip: 'Add Product',
        child: const Icon(
          Iconsax.additem,
          color: Colors.white,
          size: 30,
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vendors')
              .doc(currentTenant!.uid)
              .collection('products')
              .snapshots(),
          builder: (context, AsyncSnapshot productSnapshot) {
            if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Nodata-pana.png',
                      width: 200,
                    ),
                    const Gap(25),
                    Text(
                      'Here, no Products have arrived yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (productSnapshot.hasError) {
              debugPrint('${productSnapshot.error}');
              return Center(
                child: Text('An error occurred: ${productSnapshot.error}'),
              );
            }

            if (productSnapshot.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                separatorBuilder: (context, index) => const Gap(15),
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                itemCount: 2,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade100,
                        direction: ShimmerDirection.ltr,
                        enabled: true,
                        child: Container(
                          height: 22,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const Gap(5),
                      productLoad(),
                      const Gap(10),
                      productLoad(),
                      const Gap(10),
                      productLoad(),
                    ],
                  );
                },
              );
            }

            final List<dynamic> productData =
                productSnapshot.data!.docs.map((doc) => MenuProduct.fromDocument(doc)).toList();

            productData.sort((a, b) => a.nameProduct.compareTo(b.nameProduct));

            final Map<String, List<MenuProduct>> categorizedProducts = {};
            for (var product in productData) {
              if (!categorizedProducts.containsKey(product.categoryProduct)) {
                categorizedProducts[product.categoryProduct] = [];
              }
              categorizedProducts[product.categoryProduct]!.add(product);
            }

            return FutureBuilder<List<String>>(
              future: fetchCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found'));
                }

                final categories = snapshot.data!;
                categories.sort((a, b) => a.compareTo(b));

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: categories.length,
                          (context, index) {
                            final category = categories[index];
                            final products = categorizedProducts[category] ?? [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$category (${products.length})',
                                      style: Theme.of(context).textTheme.titleMedium,
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: products.length,
                                  padding: const EdgeInsets.only(bottom: 15),
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return TileAddMenu(
                                      showInfo: () {
                                        showInfoProductCard(
                                          product.imageProduct,
                                          product.nameProduct,
                                          product.priceProduct,
                                          product.categoryProduct,
                                          product.descProduct,
                                        );
                                        debugPrint('Tap product Card: ${product.nameProduct}');
                                      },
                                      imageProduct: product.imageProduct,
                                      nameProduct: product.nameProduct,
                                      priceProduct: product.priceProduct,
                                      categoryProduct: product.categoryProduct,
                                      stockProduct: product.stockProduct,
                                      descProduct: product.descProduct,
                                      delete: () {
                                        deleteProduct(product.productId);
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(currentTenant!.uid)
          .collection('products')
          .doc(productId)
          .delete();
      debugPrint('Product deleted Successfully');

      snackBarCustom(
        context,
        Theme.of(context).primaryColor,
        'Product Deleted, Successfully',
        Colors.white,
      );
    } catch (e) {
      debugPrint("Failed to delete Product: $e");
    }
  }

  Widget productLoad() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade100,
                direction: ShimmerDirection.ltr,
                enabled: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
          const Gap(10),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const Gap(5),
                      Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(7.5),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Container(
                    height: 17,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const Gap(3),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 15,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const Gap(2),
                      Container(
                        height: 15,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void showInfoProductCard(
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
      barrierColor: Theme.of(context).colorScheme.tertiary,
      scrollControlDisabledMaxHeightRatio: descProduct.isEmpty ? 1 / 1.3 : 1 / 1.5,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            verticalDirection: VerticalDirection.down,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    style: ButtonStyle(
                      shadowColor: WidgetStatePropertyAll(Theme.of(context).shadowColor),
                      elevation: const WidgetStatePropertyAll(1),
                      backgroundColor:
                          WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Center(
                            child: Icon(
                              Icons.drag_handle_rounded,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const Gap(10),
                          Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: descProduct.isEmpty ? 1 / 1 : 3 / 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(17),
                                  child: Container(
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
                                      imageUrl: imageProduct,
                                      filterQuality: FilterQuality.low,
                                      fit: BoxFit.cover,
                                      useOldImageOnUrlChange: true,
                                      fadeInCurve: Curves.easeIn,
                                      fadeOutCurve: Curves.easeOut,
                                      fadeInDuration: const Duration(milliseconds: 500),
                                      fadeOutDuration: const Duration(milliseconds: 750),
                                      errorWidget: (context, url, error) {
                                        return Center(
                                          child: Text(
                                            'Image $error',
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.outline,
                                    border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Rp $priceProduct',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nameProduct,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22,
                                    height: 1,
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  categoryProduct,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17,
                                    height: 1,
                                  ),
                                ),
                                const Gap(5),
                                Visibility(
                                  visible: descProduct.isNotEmpty,
                                  child: Text(
                                    descProduct,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          elevation: const WidgetStatePropertyAll(3),
                          fixedSize: const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                          shadowColor: const WidgetStatePropertyAll(Colors.black),
                          backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 17),
                          ),
                        ),
                        child: const Text(
                          'Edit',
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
              ),
            ],
          ),
        );
      },
    );
  }
}
