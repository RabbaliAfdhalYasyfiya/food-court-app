import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';

import '../../../../services/models/model_product.dart';
import '../../../../widget/snackbar.dart';
import '../../../../widget/tile.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final currentVendor = FirebaseAuth.instance.currentUser;

  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(currentVendor!.uid)
          .collection('favorites')
          .doc(productId)
          .delete();
      debugPrint('Product deleted Successfully');
    } catch (e) {
      debugPrint("Failed to delete Product: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('clients')
              .doc(currentVendor!.uid)
              .collection('favorites')
              .snapshots(),
          builder: (context, AsyncSnapshot favSnapshot) {
            if (!favSnapshot.hasData || favSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Nodata-pana.png',
                      width: 250,
                    ),
                    const Gap(20),
                    const Text(
                      "Here, you don't have a Favorite yet",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (favSnapshot.hasError) {
              debugPrint('${favSnapshot.error}');
              return Center(
                child: Text('An error occurred: ${favSnapshot.error}'),
              );
            }

            if (favSnapshot.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                padding: const EdgeInsets.all(16),
                itemCount: 7,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return favLoad();
                },
              );
            }

            if (favSnapshot.hasData) {
              final favoriteData =
                  favSnapshot.data!.docs.map((doc) => FavProduct.fromDocument(doc)).toList();
              return ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                padding: const EdgeInsets.all(16),
                itemCount: favoriteData.length,
                itemBuilder: (context, index) {
                  final favorite = favoriteData[index];
                  return TileFavorite(
                    imageProduct: favorite.imageProduct,
                    nameProduct: favorite.nameProduct,
                    priceProduct: favorite.priceProduct,
                    categoryProduct: favorite.categoryProduct,
                    descProduct: favorite.descProduct,
                    delete: () {
                      deleteProduct(favorite.productId);
                      snackBarCustom(
                        context,
                        Theme.of(context).primaryColor,
                        '${favorite.nameProduct} removed Favorites, Successfully',
                        Colors.white,
                      );
                      
                    },
                  );
                },
              );
            }
            return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              padding: const EdgeInsets.all(16),
              itemCount: 7,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return favLoad();
              },
            );
          },
        ),
      ),
    );
  }

  Widget favLoad() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade100,
              direction: ShimmerDirection.ltr,
              enabled: true,
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
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
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                      ),
                      const Gap(2.5),
                      Container(
                        height: 18,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Container(
                    height: 16,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                const Gap(10),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                      ),
                      const Gap(2.5),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
