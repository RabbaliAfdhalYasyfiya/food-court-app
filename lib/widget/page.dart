import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';

import '../screen/client/pages/location/tenant_court/tenant_court_page.dart';
import '../services/models/model_review.dart';
import '../services/models/model_tenant.dart';
import 'load.dart';
import 'snackbar.dart';
import 'tile.dart';

class PageReview extends StatefulWidget {
  const PageReview({
    super.key,
    required this.currentUser,
    required this.adminId,
    required this.placeName,
  });

  final User currentUser;
  final String adminId;
  final String placeName;

  @override
  State<PageReview> createState() => _PageReviewState();
}

class _PageReviewState extends State<PageReview> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.adminId)
          .collection('reviews')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return reviewNull();
        }
        if (snapshot.hasError) {
          debugPrint('${snapshot.error}');
          return Center(
            child: Text('An error occurred: ${snapshot.error}'),
          );
        }

        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return ListView.separated(
        //     separatorBuilder: (context, index) => const SizedBox(height: 7),
        //     scrollDirection: Axis.vertical,
        //     padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        //     shrinkWrap: true,
        //     physics: const NeverScrollableScrollPhysics(),
        //     itemCount: 3,
        //     itemBuilder: (context, index) => reviewLoad(),
        //   );
        // }

        if (snapshot.hasData) {
          final reviewData =
              snapshot.data!.docs.map((doc) => ReviewAdmin.fromSnapshot(doc)).toList();
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: reviewData.length,
                  itemBuilder: (context, index) {
                    final reviewAdmin = reviewData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TileReview(
                        imageUser: reviewAdmin.imageUser,
                        nameUser: reviewAdmin.username,
                        komenUser: reviewAdmin.comment,
                        userId: reviewAdmin.clientId,
                        currentUserId: widget.currentUser.uid,
                        ratingUser: reviewAdmin.rating,
                        imageReview: reviewAdmin.imageReview,
                        delete: () {
                          deleteReview(
                            reviewAdmin.adminId,
                            reviewAdmin.username,
                            reviewAdmin.reviewId,
                            context,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const Gap(10),
              SmoothPageIndicator(
                controller: _controller,
                count: reviewData.length,
                axisDirection: Axis.horizontal,
                textDirection: TextDirection.ltr,
                effect: ScrollingDotsEffect(
                  dotHeight: 5,
                  dotWidth: 5,
                  spacing: 2.5,
                  fixedCenter: true,
                  activeDotScale: 0,
                  dotColor: Colors.grey.shade400,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 7),
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => reviewLoad(),
        );
      },
    );
  }

  Widget reviewLoad() {
    return Container(
      width: 350,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 1,
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 0,
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade100,
              direction: ShimmerDirection.ltr,
              enabled: true,
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
          const Gap(10),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                            ),
                            const Gap(2.5),
                            Container(
                              height: 16,
                              width: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.grey.shade200,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.75,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  flex: 4,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    direction: ShimmerDirection.ltr,
                    enabled: true,
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const Gap(7),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    direction: ShimmerDirection.ltr,
                    enabled: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey.shade200,
                          ),
                        ),
                        const Gap(2.5),
                        Container(
                          height: 16,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteReview(
    String adminId,
    String username,
    String reviewId,
    BuildContext context,
  ) async {
    showLoading(context);
    try {
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .collection('reviews')
          .doc(reviewId)
          .delete();

      debugPrint('Your $username review deleted, Successfully');
      snackBarCustom(
        context,
        Theme.of(context).primaryColor,
        'Your $username review deleted, Successfully',
        Colors.white,
      );
    } catch (e) {
      debugPrint("Failed to delete Product: $e");
    }
    Navigator.pop(context);
  }

  Widget reviewNull() {
    return const SizedBox(
      height: 150,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            Text(
              'Start the conversation.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageTenant extends StatelessWidget {
  const PageTenant({
    super.key,
    required this.adminId,
  });

  final String adminId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vendors')
          .where('admin_id', isEqualTo: adminId)
          .snapshots(),
      builder: (context, vendorSnapshot) {
        if (!vendorSnapshot.hasData || vendorSnapshot.data!.docs.isEmpty) {
          return tenantNull();
        }

        if (vendorSnapshot.hasError) {
          debugPrint('${vendorSnapshot.error}');
          return Center(
            child: Text('An error occurred: ${vendorSnapshot.error}'),
          );
        }

        if (vendorSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final vendorFuture = Future.wait(
          vendorSnapshot.data!.docs.map(
            (docs) async {
              final vendor = Tenant.fromDocument(docs);
              await vendor.fetchProduct();
              return vendor;
            },
          ),
        );

        return FutureBuilder(
          future: vendorFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return tenantNull();
            }

            if (vendorSnapshot.hasError) {
              debugPrint('${snapshot.error}');
              return Center(
                child: Text('An error occurred: ${snapshot.error}'),
              );
            }

            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return GridView.builder(
            //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 2,
            //       crossAxisSpacing: 7,
            //       mainAxisSpacing: 7,
            //     ),
            //     itemCount: 2,
            //     itemBuilder: (context, index) => tenantLoad(),
            //   );
            // }

            if (snapshot.hasData) {
              final vendorData = snapshot.data!;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 7,
                  mainAxisSpacing: 7,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                itemCount: vendorData.length,
                itemBuilder: (context, index) {
                  final vendors = vendorData[index];
                  return TileTenant(
                    nameFoodCourt: vendors.vendorName,
                    image: vendors.imagePlace,
                    isOpen: vendors.isOpen,
                    lengthProduct: vendors.product.length,
                    ontap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => TenantCourtPage(
                            tenant: vendors,
                            products: vendors.product,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 7,
                mainAxisSpacing: 7,
              ),
              itemCount: 2,
              itemBuilder: (context, index) => tenantLoad(),
            );
          },
        );
      },
    );
  }

  Widget tenantLoad() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 1,
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade100,
              direction: ShimmerDirection.ltr,
              enabled: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade200,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(7.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    direction: ShimmerDirection.ltr,
                    enabled: true,
                    child: Container(
                      height: 19,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  const Gap(5),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    direction: ShimmerDirection.ltr,
                    enabled: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 17,
                          width: 75,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey.shade200,
                          ),
                        ),
                        Container(
                          height: 17,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget tenantNull() {
    return const SizedBox(
      height: 150,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'The Tenant',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            Text(
              'Has not yet entered.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
