import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gap/gap.dart';

import 'admin/main_page.dart';
import 'tenant/main_page.dart';
import 'client/main_page.dart';
import 'welcome_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String version = '';

  void getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    getInfo();
    var userRef = FirebaseFirestore.instance;
    FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        if (user == null) {
          Future.delayed(const Duration(milliseconds: 2500)).then(
            (value) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const WelcomePage(),
              ),
            ),
          );
        } else {
          userRef.collection('clients').doc(user.uid).get().then(
            (clientSnapshot) {
              if (clientSnapshot.exists) {
                Future.delayed(const Duration(milliseconds: 2500)).then(
                  (value) => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainPageClient(),
                    ),
                  ),
                );
              }
            },
          );

          userRef.collection('admins').doc(user.uid).get().then(
            (adminSnapshot) {
              if (adminSnapshot.exists) {
                Future.delayed(const Duration(milliseconds: 2500)).then(
                  (value) => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainPageAdmin(),
                    ),
                  ),
                );
              }
            },
          );

          userRef.collection('vendors').doc(user.uid).get().then(
            (tenantSnapshot) {
              if (tenantSnapshot.exists) {
                Future.delayed(const Duration(milliseconds: 2500)).then(
                  (value) => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainPageTenant(),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: false,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: SizedBox(
              height: 350,
              width: 350,
              child: LottieBuilder.asset(
                'assets/map_animation.json',
                filterQuality: FilterQuality.low,
                alignment: Alignment.center,
                repeat: true,
                animate: true,
                backgroundLoading: true,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            child: Column(
              children: [
                const Text(
                  'CourtFinder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(7.5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                    border: Border.all(
                      color: Colors.white,
                      style: BorderStyle.solid,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'v $version',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
