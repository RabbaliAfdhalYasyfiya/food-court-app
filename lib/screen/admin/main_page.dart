import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'pages/list_tenant/tenant_page.dart';
import '../../widget/bottom_sheet.dart';
import 'pages/profile/admin_page.dart';
import '../../widget/snackbar.dart';
import '../../widget/load.dart';
import 'auth/auth_page.dart';

class MainPageAdmin extends StatefulWidget {
  const MainPageAdmin({super.key});

  @override
  State<MainPageAdmin> createState() => _MainPageAdminState();
}

class _MainPageAdminState extends State<MainPageAdmin> {
  final List<Widget> body = [
    const VendorPage(),
    const AdminProfilePage(),
  ];

  int currentIndex = 0;
  bool loadSign = false;
  bool onTap = false;
  final List<String> title = [
    'Tenant',
    'Profile',
  ];

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
        builder: (context) => const AuthPageAdmin(),
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
        automaticallyImplyLeading: false,
        title: Text(title[currentIndex]),
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
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          if (currentIndex == value) return;
          setState(() {
            currentIndex = value;
            onTap = !onTap;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              Iconsax.shop,
              color: Theme.of(context).navigationBarTheme.shadowColor,
            ),
            selectedIcon: Icon(
              Iconsax.shop5,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Tenant',
          ),
          NavigationDestination(
            icon: Icon(
              Iconsax.personalcard,
              color: Theme.of(context).navigationBarTheme.shadowColor,
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
        snackBar: SnackBar(
          content: const Text(
            'Press again to Exit',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
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
