import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'pages/favorite/favorite_page.dart';
import 'pages/location/location_page.dart';
import 'pages/profile/profile_page.dart';
import '../../widget/bottom_sheet.dart';
import '../../widget/snackbar.dart';
import '../../widget/load.dart';
import 'auth/auth_page.dart';

class MainPageClient extends StatefulWidget {
  const MainPageClient({
    super.key,
    this.badge = false,
  });

  final bool badge;

  @override
  State<MainPageClient> createState() => _MainPageClientState();
}

class _MainPageClientState extends State<MainPageClient> {
  final List<Widget> body = [
    const LocationPage(),
    const FavoritePage(),
    //const PaymentPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    showBadge = widget.badge;
    super.initState();
  }

  int currentIndex = 0;
  bool onTap = false;
  late bool showBadge;

  final List<String> title = [
    'Location',
    'Favorite',
    //'Payment',
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
      barrierColor: Theme.of(context).colorScheme.tertiary,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomSheetInfo(
          iconInfo: CupertinoIcons.question_circle,
          colorIcon: Theme.of(context).primaryColor,
          textInfo: 'Are you sure you want to go out ?',
          textButton: 'Yes',
          colorButton: Theme.of(context).primaryColor,
          onTap: () {
            enterClose();
          },
        );
      },
    );
  }

  void enterClose() async {
    showLoading(context);

    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPageClient(),
      ),
      (Route<dynamic> route) => false,
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
            if (value == 1) {
              showBadge = false;
            }
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              Iconsax.map_1,
              color: Theme.of(context).navigationBarTheme.shadowColor,
            ),
            selectedIcon: Icon(
              Iconsax.map5,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Location',
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                Icon(
                  Iconsax.heart,
                  color: Theme.of(context).navigationBarTheme.shadowColor,
                ),
                if (showBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            selectedIcon: Icon(
              Iconsax.heart5,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Favorite',
          ),
          // NavigationDestination(
          //   icon: const Icon(
          //     Iconsax.empty_wallet
          //   ),
          //   selectedIcon: Icon(
          //     Iconsax.empty_wallet5,
          //     color: Theme.of(context).primaryColor,
          //   ),
          //   label: 'Payment',
          // ),
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
        snackBar: const SnackBar(
          content: Text(
            'Press again to Exit',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
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
