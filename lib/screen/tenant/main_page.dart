import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../widget/load.dart';
import '../../widget/snackbar.dart';
import 'pages/activity_product/activity_page.dart';
import 'pages/order_product/order_product.dart';
import 'pages/list_product/product_page.dart';
import 'pages/profile/tenant_page.dart';
import '../../widget/bottom_sheet.dart';
import 'auth/auth_page.dart';

class MainPageTenant extends StatefulWidget {
  const MainPageTenant({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainPageTenant> createState() => _MainPageTenantState();
}

class _MainPageTenantState extends State<MainPageTenant> {
  final List<Widget> body = [
    const OrderProduct(),
    const ActivityPage(),
    const ProductPage(),
    const TenantPofilePage(),
  ];

  int currentIndex = 0;
  bool onTap = false;
  final List<String> title = [
    'Order',
    'Activity',
    'Product',
    'Profile',
  ];

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  void closeAccount() {
    showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 1 / 3.5,
      isScrollControlled: false,
      enableDrag: false,
      useRootNavigator: false,
      showDragHandle: false,
      useSafeArea: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomSheetInfo(
          iconInfo: CupertinoIcons.question_circle,
          colorIcon: Theme.of(context).primaryColor,
          textInfo: 'Are you sure you want to go out ?',
          textButton: 'Yes',
          colorButton: Theme.of(context).primaryColor,
          onTap: enterClose,
        );
      },
    );
  }

  void enterClose() async {
    showLoading(context);

    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPageTenant(),
      ),
    );

    snackBarCustom(
      context,
      Theme.of(context).primaryColor,
      'Close, Successfully',
      Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          title[currentIndex],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              radius: 10,
              splashColor: Theme.of(context).primaryColor.withOpacity(0.15),
              overlayColor:
                  WidgetStatePropertyAll(Theme.of(context).primaryColor.withOpacity(0.15)),
              onTap: closeAccount,
              child: Row(
                children: [
                  Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          if (currentIndex == value) return;
          setState(() {
            currentIndex = value;
            onTap = !onTap;
          });
        },
        elevation: 7,
        shadowColor: Colors.black,
        overlayColor: WidgetStatePropertyAll(Theme.of(context).primaryColor.withOpacity(0.25)),
        indicatorColor: Theme.of(context).primaryColor.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(
              Iconsax.menu_board,
              color: Colors.black,
            ),
            selectedIcon: Icon(
              Iconsax.menu_board5,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Order',
          ),
          NavigationDestination(
            icon: const Icon(
              Iconsax.directbox_notif,
              color: Colors.black,
            ),
            selectedIcon: Icon(
              Iconsax.directbox_notif5,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: const Icon(
              Iconsax.note_21,
              color: Colors.black,
            ),
            selectedIcon: Icon(
              Iconsax.note_15,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Product',
          ),
          NavigationDestination(
            icon: const Icon(
              Iconsax.personalcard,
              color: Colors.black,
            ),
            selectedIcon: Icon(
              Iconsax.personalcard5,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text(
            'Press again to Exit',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: Colors.black45, width: 1),
          ),
          padding: EdgeInsets.symmetric(vertical: 10),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          hitTestBehavior: HitTestBehavior.translucent,
          width: 160,
        ),
        child: IndexedStack(
          index: currentIndex,
          children: body,
        ),
      ),
    );
  }
}
