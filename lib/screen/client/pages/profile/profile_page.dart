import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../../../widget/bottom_sheet.dart';
import '../../../../widget/button.dart';
import '../../../../widget/load.dart';
import '../../../../widget/snackbar.dart';
import '../../auth/auth_page.dart';
import 'edit_page.dart';
import 'privacy.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  File? imageFile;

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

  Future<void> enterDelete() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      try {
        showLoading(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthPageClient(),
          ),
        );

        await deleteUser();
        await deleteUserData(uid);

        snackBarCustom(
          context,
          Theme.of(context).primaryColor,
          'Delete Account, Successfully',
          Colors.white,
        );
      } catch (e) {
        debugPrint("Error during account deletion: $e");
        snackBarCustom(
          context,
          Colors.redAccent.shade200,
          'Failed to Delete Account, Please try again',
          Colors.white,
        );
      }
    }
  }

  Future<void> deleteUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.delete();
        debugPrint("User deleted from Firebase Authentication.");
      } catch (e) {
        debugPrint("Failed to delete user: $e");
      }
    }
  }

  Future<void> deleteUserData(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('clients').doc(uid).delete();
      debugPrint("User data deleted from Firestore.");
    } catch (e) {
      debugPrint("Failed to delete user data: $e");
    }
  }

  Widget profileLoad() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const Gap(10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          height: 23,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const Gap(10),
                        Container(
                          width: 150,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const Gap(10),
                        Container(
                          width: 175,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(25),
              Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Gap(20),
              Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Gap(30),
              Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final firstnameEditController = TextEditingController();
  final lastnameEditController = TextEditingController();
  final usernameEditController = TextEditingController();
  final emailEditController = TextEditingController();
  final phonenumberEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('clients').doc(currentUser.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return profileLoad();
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;

            firstnameEditController.text = userData['firstname'];
            lastnameEditController.text = userData['lastname'];
            usernameEditController.text = userData['username'];
            emailEditController.text = userData['email_address'];
            phonenumberEditController.text = userData['phone_number'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 70,
                              width: 70,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  width: 70,
                                  height: 70,
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
                                  child: imageFile != null
                                      ? Image.file(
                                          File(imageFile!.path),
                                          height: double.infinity,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.low,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: userData['image'],
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
                            const Gap(10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                currentUser.email != null
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            firstnameEditController.text,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Gap(5),
                                          Text(
                                            lastnameEditController.text,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        usernameEditController.text,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Iconsax.sms,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                    const Gap(5),
                                    Text(
                                      emailEditController.text,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                Row(
                                  children: [
                                    const Icon(
                                      Iconsax.call_calling,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                    const Gap(5),
                                    Text(
                                      phonenumberEditController.text,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Gap(5),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => EditPage(
                                  firstnameEditController: firstnameEditController,
                                  lastnameEditController: lastnameEditController,
                                  usernameEditController: usernameEditController,
                                  emailEditController: emailEditController,
                                  phonenumberEditController: phonenumberEditController,
                                ),
                              ),
                            );
                          },
                          color: Colors.white,
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
                            shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                          ),
                          icon: Icon(
                            Iconsax.edit,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  ButtonAccount(
                    icon: Iconsax.moon,
                    colorIcon: Theme.of(context).primaryColor,
                    colorButton: Theme.of(context).colorScheme.onTertiary,
                    label: 'Dark Mode',
                    color: Colors.black,
                    widget: Transform.scale(
                      scale: 0.9,
                      child: CupertinoSwitch(
                        value: false,
                        dragStartBehavior: DragStartBehavior.down,
                        activeColor: Theme.of(context).primaryColor,
                        applyTheme: true,
                        onChanged: (value) {},
                      ),
                    ),
                    onTap: () {},
                  ),
                  ButtonAccount(
                    icon: Iconsax.security_safe,
                    colorIcon: Theme.of(context).primaryColor,
                    colorButton: Theme.of(context).colorScheme.onTertiary,
                    label: 'Privacy & Security',
                    color: Colors.black,
                    widget: const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const Privacy(),
                        ),
                      );
                    },
                  ),
                  const Gap(20),
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
          },
        ),
      ),
    );
  }
}
