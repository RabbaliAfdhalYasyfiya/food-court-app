import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../services/models/model_tenant.dart';
import '../../../../widget/tile.dart';
import '../create_account.dart';
import 'tenant_lapor_page.dart';

class VendorPage extends StatefulWidget {
  const VendorPage({super.key});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  final currentAdmin = FirebaseAuth.instance.currentUser!;
  bool loadList = false;

  Widget tenantLoad() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
      ),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.onPrimary,
            highlightColor: Theme.of(context).colorScheme.onSecondary,
            direction: ShimmerDirection.ltr,
            enabled: true,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const Gap(5),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.onPrimary,
                  highlightColor: Theme.of(context).colorScheme.onSecondary,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 23,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Container(
                        height: 23,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.onPrimary,
                  highlightColor: Theme.of(context).colorScheme.onSecondary,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Container(
                    height: 17,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('admins').doc(currentAdmin.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.add),
              );
            }
            var adminData = snapshot.data!;
            String adminId = adminData['admin_id'];
            String adminEmail = adminData['email_address'];
            String adminPass = adminData['password'];

            return FloatingActionButton(
              materialTapTargetSize: MaterialTapTargetSize.padded,
              onPressed: () {
                debugPrint(adminId);
                debugPrint(adminEmail);
                debugPrint(adminPass);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => CreateAccountVendor(
                      adminId: adminId,
                      adminEmail: adminEmail,
                      adminPass: adminPass,
                    ),
                  ),
                );
              },
              child: const Icon(
                Iconsax.shop_add,
                color: Colors.white,
                size: 30,
              ),
            );
          }),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vendors')
              .where('admin_id', isEqualTo: currentAdmin.uid)
              .snapshots(),
          builder: (context, vendorSnapshot) {
            if (!vendorSnapshot.hasData || vendorSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Nodata-pana.png',
                      width: 250,
                    ),
                    const Text(
                      'Here, no Vendors have arrived yet',
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

            if (vendorSnapshot.hasError) {
              debugPrint('${vendorSnapshot.error}');
              return Center(
                child: Text('An error occurred: ${vendorSnapshot.error}'),
              );
            }

            if (vendorSnapshot.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                padding: const EdgeInsets.all(16),
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return tenantLoad();
                },
              );
            }

            final vendorFuture = Future.wait(
              vendorSnapshot.data!.docs.map(
                (docs) async {
                  final vendor = Tenant.fromDocument(docs);
                  await vendor.fetchProduct();
                  return vendor;
                },
              ).toList(),
            );

            return FutureBuilder<List<Tenant>>(
              future: vendorFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                          'Here, no Vendors have arrived yet',
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

                if (snapshot.hasError) {
                  debugPrint('${vendorSnapshot.error}');
                  return Center(
                    child: Text('An error occurred: ${vendorSnapshot.error}'),
                  );
                }

                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     child: ListView.separated(
                //       separatorBuilder: (context, index) => const SizedBox(height: 10),
                //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                //       scrollDirection: Axis.vertical,
                //       physics: const NeverScrollableScrollPhysics(),
                //       itemCount: 7,
                //       itemBuilder: (context, index) {
                //         return vendorLoad();
                //       },
                //     ),
                //   );
                // }

                if (snapshot.hasData) {
                  final tenantData = snapshot.data!;
                  return ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    padding: const EdgeInsets.all(16),
                    scrollDirection: Axis.vertical,
                    itemCount: tenantData.length,
                    itemBuilder: (context, index) {
                      final tenants = tenantData[index];
                      return TileTenantManager(
                        imageTenant: tenants.imagePlace,
                        nameTenant: tenants.vendorName,
                        emailTenant: tenants.emailVendor,
                        phoneNumberTenant: tenants.phoneNumberVendor,
                        numberProduct: tenants.product.length,
                        isOpen: tenants.isOpen,
                        onTap: () {
                          debugPrint('VendorID: ${tenants.vendorId}');
                          debugPrint('Product: ${tenants.product.length}');
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => VendorLaporanPage(
                                products: tenants.product,
                                tenant: tenants,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      return tenantLoad();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
