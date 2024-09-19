import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../../../services/models/model_product.dart';
import '../../../../widget/snackbar.dart';
import '../../../../widget/tile.dart';
import 'cart_order.dart';

class OrderProduct extends StatefulWidget {
  const OrderProduct({super.key});

  @override
  State<OrderProduct> createState() => _OrderProductState();
}

class _OrderProductState extends State<OrderProduct> with SingleTickerProviderStateMixin {
  final currentTenant = FirebaseAuth.instance.currentUser;

  final Map<String, List<bool>> _checkedProductsMap = {};
  final Map<String, List<int>> _countsMap = {};
  final Map<String, List<MenuProduct>> _productDataMap = {};

  late ScrollController _scrollController;
  late TabController _tabController;
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _categoriesFuture = fetchCategories();
    _categoriesFuture.then((categories) {
      _tabController = TabController(length: categories.length, vsync: this);
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          // Calculate the position to scroll to based on tab index
          double offset =
              (_tabController.index * 225); // Adjust the multiplier based on your tab width
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        setState(() {});
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void decCount(String categoryKey, int index) {
    setState(() {
      if (_countsMap[categoryKey]![index] > 0) _countsMap[categoryKey]![index]--;
    });
  }

  void incCount(String categoryKey, int index) {
    setState(() {
      _countsMap[categoryKey]![index]++;
    });
  }

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

  void processToCart() {
    List<MenuProduct> selectedProducts = [];
    List<int> selectedCounts = [];

    _checkedProductsMap.forEach((categoryKey, checkedProducts) {
      for (int i = 0; i < checkedProducts.length; i++) {
        debugPrint('Product: $checkedProducts, dengan Category: $categoryKey');
        if (checkedProducts[i] && _countsMap[categoryKey]![i] > 0) {
          selectedProducts.add(_productDataMap[categoryKey]![i]);
          selectedCounts.add(_countsMap[categoryKey]![i]);
        }
      }
    });

    if (selectedCounts.isEmpty) {
      debugPrint('Count Empty');
      snackBarCustom(
        context,
        Colors.redAccent.shade400,
        'Product Quantity needs to be filled in',
        Colors.white,
      );
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => CartOrder(
            currentTenant: currentTenant!,
            selectedProducts: selectedProducts,
            selectedQuantities: selectedCounts,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _categoriesFuture,
      builder: (context, categorySnapshot) {
        if (categorySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (categorySnapshot.hasError) {
          return Center(child: Text('Error: ${categorySnapshot.error}'));
        } else if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
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
                  'No categories found',
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

        final categories = categorySnapshot.data!;

        if (_tabController.length != categories.length) {
          _tabController = TabController(length: categories.length, vsync: this);
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 0,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSecondary,
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    child: TabBar(
                      physics: const NeverScrollableScrollPhysics(),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                      controller: _tabController,
                      isScrollable: false,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                      indicatorWeight: 4,
                      tabAlignment: TabAlignment.center,
                      unselectedLabelStyle: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w400,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: categories.map((category) => Tab(text: category)).toList(),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: TabBarView(
                    dragStartBehavior: DragStartBehavior.start,
                    controller: _tabController,
                    physics: const ScrollPhysics(),
                    children: categories.map(
                      (category) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('vendors')
                              .doc(currentTenant!.uid)
                              .collection('products')
                              .where('category_product', isEqualTo: category)
                              .snapshots(),
                          builder: (context, AsyncSnapshot productSnapshot) {
                            if (productSnapshot.hasError) {
                              debugPrint('${productSnapshot.error}');
                              return Center(
                                child: Text('An error occurred: ${productSnapshot.error}'),
                              );
                            }

                            if (productSnapshot.hasData) {
                              final productData = productSnapshot.data!.docs
                                  .map<MenuProduct>((doc) => MenuProduct.fromDocument(doc))
                                  .toList();

                              productData.sort((MenuProduct a, MenuProduct b) =>
                                  a.nameProduct.compareTo(b.nameProduct));

                              final categoryKey = category;

                              _productDataMap[categoryKey] = productData;

                              if (!_checkedProductsMap.containsKey(categoryKey)) {
                                _checkedProductsMap[categoryKey] =
                                    List<bool>.filled(productData.length, false);
                                _countsMap[categoryKey] = List<int>.filled(productData.length, 0);
                              }

                              final checkedProducts = _checkedProductsMap[categoryKey]!;
                              final counts = _countsMap[categoryKey]!;

                              return Column(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                        mainAxisExtent: 275,
                                      ),
                                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                                      shrinkWrap: true,
                                      itemCount: productData.length,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        final product = productData[index];

                                        return TileOrderProduct(
                                          index: index,
                                          count: counts[index],
                                          imageProduct: product.imageProduct,
                                          nameProduct: product.nameProduct,
                                          priceProduct: product.priceProduct,
                                          checkProduct: checkedProducts[index],
                                          tapped: () {
                                            setState(() {
                                              checkedProducts[index] = !checkedProducts[index];
                                              if (checkedProducts[index]) {
                                                incCount(categoryKey, index);
                                              } else {
                                                counts[index] = 0;
                                              }
                                            });
                                          },
                                          onChanged: (bool? value) {
                                            setState(() {
                                              checkedProducts[index] = value!;
                                              if (value) {
                                                incCount(categoryKey, index);
                                              } else {
                                                counts[index] = 0;
                                              }
                                            });
                                          },
                                          onDecCount: () => decCount(categoryKey, index),
                                          onIncCount: () => incCount(categoryKey, index),
                                        );
                                      },
                                    ),
                                  ),
                                  Visibility(
                                    visible: checkedProducts.contains(true),
                                    child: Expanded(
                                      flex: 0,
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: double.infinity,
                                          height: 100,
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          padding: const EdgeInsets.all(16),
                                          child: ElevatedButton.icon(
                                            icon: const Icon(
                                              Iconsax.shopping_cart,
                                              color: Colors.white,
                                            ),
                                            iconAlignment: IconAlignment.start,
                                            label: const Text(
                                              'Order Menu',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            onPressed: () {
                                              processToCart();
                                            },
                                            style: ButtonStyle(
                                              fixedSize: const WidgetStatePropertyAll(
                                                  Size.fromWidth(double.negativeInfinity)),
                                              shape: WidgetStatePropertyAll(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                              ),
                                              elevation: const WidgetStatePropertyAll(3),
                                              backgroundColor: WidgetStatePropertyAll(
                                                  Theme.of(context).primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/Nodata-pana.png',
                                    width: 250,
                                  ),
                                  const Gap(20),
                                  Text(
                                    'Here, no Products have arrived yet',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context).colorScheme.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ).toList()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget orderCard(
    int index,
    int count,
    String imageProduct,
    String nameProduct,
    String priceProduct,
    String descProduct,
    bool checkProduct,
    Function() tapped,
    ValueChanged<bool?> onChanged,
    VoidCallback onDecCount,
    VoidCallback onIncCount,
  ) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: tapped,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
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
                  ),
                ),
                const Gap(10),
                Column(
                  children: [
                    Text(
                      nameProduct,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 19,
                        height: 1,
                      ),
                    ),
                    const Gap(5),
                    Text(
                      'Rp $priceProduct',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(
                      thickness: 0.5,
                      height: 10,
                      endIndent: 10,
                      indent: 10,
                      color: Colors.black26,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: onDecCount,
                          icon: const Icon(CupertinoIcons.minus),
                          color: Colors.white,
                          style: ButtonStyle(
                            shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade200,
                            ),
                            child: Center(
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onIncCount,
                          icon: const Icon(CupertinoIcons.add),
                          color: Colors.white,
                          style: ButtonStyle(
                            shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(15),
                                  topLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 1,
            left: 1,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Checkbox.adaptive(
                value: checkProduct,
                visualDensity: VisualDensity.compact,
                activeColor: Theme.of(context).primaryColor,
                side: const BorderSide(color: Colors.black, width: 1.5),
                autofocus: true,
                splashRadius: 50,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
