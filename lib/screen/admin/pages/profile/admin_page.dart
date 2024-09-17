import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_court_app/widget/load.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';

import '../../../../services/app_service.dart';
import '../../../../widget/bottom_sheet.dart';
import '../../../../widget/snackbar.dart';
import '../../../../widget/button.dart';
import '../../auth/auth_page.dart';
import 'edit_admin.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final currentAdmin = FirebaseAuth.instance.currentUser!;
  File? imageFile;
  User? user;

  Future<void> updateClose(bool isOpen) async {
    await FirebaseFirestore.instance.collection('admins').doc(currentAdmin.uid).update({
      'is_close': isOpen,
    });
  }

  void deleteAccount() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      scrollControlDisabledMaxHeightRatio: 1 / 3.5,
      isScrollControlled: false,
      enableDrag: false,
      useRootNavigator: false,
      showDragHandle: false,
      useSafeArea: true,
      isDismissible: false,
      builder: (context) {
        return BottomSheetInfo(
          iconInfo: CupertinoIcons.info_circle,
          colorIcon: Colors.redAccent,
          textInfo: 'Are you sure you want to Delete Account ?',
          textButton: 'Delete',
          colorButton: Colors.redAccent,
          onTap: enterDelete,
        );
      },
    );
  }

  void enterDelete() async {
    showLoading(context);

    await FirebaseAuth.instance.currentUser!.delete();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPageAdmin(),
      ),
    );

    await FirebaseFirestore.instance.collection('users').doc(currentAdmin.uid).delete();

    snackBarCustom(
      context,
      Theme.of(context).primaryColor,
      'Delete Account, Successfully',
      Colors.white,
    );
  }

  final placeNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressPlaceController = TextEditingController();

  Widget profileLoad() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            direction: ShimmerDirection.ltr,
            enabled: true,
            child: Container(
              width: double.infinity,
              height: 175,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Gap(5),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const Gap(5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(15),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: 50,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(15),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade200,
                        direction: ShimmerDirection.ltr,
                        enabled: true,
                        child: Container(
                          width: 250,
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 2,
                        height: 20,
                        color: Colors.white,
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade200,
                        direction: ShimmerDirection.ltr,
                        enabled: true,
                        child: Container(
                          width: 200,
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 2,
                        height: 20,
                        color: Colors.white,
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade200,
                        direction: ShimmerDirection.ltr,
                        enabled: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 18,
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const Gap(5),
                            Container(
                              width: 275,
                              height: 18,
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const Gap(5),
                            Container(
                              width: 175,
                              height: 18,
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(5),
          Divider(
            thickness: 0.5,
            endIndent: 10,
            indent: 10,
            color: Colors.grey.shade300,
          ),
          const Gap(10),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            direction: ShimmerDirection.ltr,
            enabled: true,
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Gap(10),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            direction: ShimmerDirection.ltr,
            enabled: true,
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(
      builder: (context, activeProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('admins').doc(currentAdmin.uid).snapshots(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return profileLoad();
                // }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.hasData) {
                  final adminData = snapshot.data!.data() as Map<String, dynamic>;

                  placeNameController.text = adminData['place_name'];
                  emailController.text = adminData['email_address'];
                  phoneNumberController.text = adminData['phone_number'];
                  addressPlaceController.text = adminData['address_place'];

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            height: 175,
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
                            child: imageFile != null
                                ? Image.file(
                                    File(imageFile!.path),
                                    height: 175,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: adminData['image_place'],
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
                        const Gap(5),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      placeNameController.text,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ),
                                  const Gap(5),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => EditProfileAdmin(
                                            placeNameController: placeNameController,
                                            emailController: emailController,
                                            phoneNumberController: phoneNumberController,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
                                      backgroundColor:
                                          WidgetStatePropertyAll(Theme.of(context).primaryColor),
                                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15))),
                                    ),
                                    icon: const Icon(
                                      Iconsax.edit,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(15),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Iconsax.sms,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: 22,
                                          ),
                                          const Gap(10),
                                          Text(
                                            emailController.text,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      thickness: 2,
                                      height: 20,
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Iconsax.call_calling,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: 22,
                                          ),
                                          const Gap(10),
                                          Text(
                                            phoneNumberController.text,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      thickness: 2,
                                      height: 20,
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.5),
                                            child: Icon(
                                              Iconsax.location,
                                              color: Theme.of(context).colorScheme.primary,
                                              size: 22,
                                            ),
                                          ),
                                          const Gap(10),
                                          Expanded(
                                            child: Text(
                                              addressPlaceController.text,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.labelSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          thickness: 0.5,
                          endIndent: 10,
                          indent: 10,
                          color: Colors.black54,
                        ),
                        const Gap(10),
                        ButtonAccount(
                          icon: Iconsax.lamp_on,
                          colorIcon: Theme.of(context).primaryColor,
                          colorButton: Theme.of(context).colorScheme.onTertiary,
                          label: 'Active',
                          color: Colors.black,
                          widget: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                activeProvider.getIsOpen ? 'Open' : 'Close',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black45,
                                ),
                              ),
                              const Gap(5),
                              Transform.scale(
                                scale: 0.9,
                                child: CupertinoSwitch(
                                  value: activeProvider.getIsOpen,
                                  dragStartBehavior: DragStartBehavior.down,
                                  activeColor: Theme.of(context).primaryColor,
                                  applyTheme: true,
                                  onChanged: (value) {
                                    activeProvider.setIsOpenActive = value;
                                    updateClose(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              activeProvider.setIsOpenActive = !activeProvider.isOpen;
                              updateClose(activeProvider.isOpen);
                            });
                          },
                        ),
                        ButtonAccount(
                          icon: Iconsax.trash,
                          colorIcon: Colors.white,
                          colorButton: Colors.redAccent.shade200,
                          label: 'Delete Account',
                          color: Colors.white,
                          widget: const Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: Colors.white,
                          ),
                          onTap: deleteAccount,
                        ),
                      ],
                    ),
                  );
                }

                return profileLoad();
              },
            ),
          ),
        );
      },
    );
  }
}
