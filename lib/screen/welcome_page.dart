import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'admin/auth/auth_page.dart';
import 'client/auth/auth_page.dart';
import 'tenant/auth/auth_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Gap(35),
                  Card(
                    margin: const EdgeInsets.all(0),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(100), right: Radius.circular(50)),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.25),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    elevation: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logos.png',
                            height: 30,
                            filterQuality: FilterQuality.low,
                          ),
                          const Gap(10),
                          Text(
                            'CourtFinder',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(75),
                  Image.asset(
                    'assets/images/navig-pana.png',
                    height: 350,
                    filterQuality: FilterQuality.low,
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).canvasColor.withOpacity(0),
                        Theme.of(context).canvasColor.withOpacity(0.25),
                        Theme.of(context).canvasColor.withOpacity(0.5),
                        Theme.of(context).canvasColor,
                        Theme.of(context).canvasColor,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Open Food Court World.",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          "Easily Your Choose Anything with The Food Court",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.secondary,
                            height: 1.15,
                          ),
                        ),
                        const Gap(40),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AuthPageAdmin(),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      fixedSize: const WidgetStatePropertyAll(
                                          Size.fromWidth(double.infinity)),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      elevation: const WidgetStatePropertyAll(3),
                                      shadowColor:
                                          WidgetStatePropertyAll(Theme.of(context).shadowColor),
                                      backgroundColor:
                                          WidgetStatePropertyAll(Theme.of(context).primaryColor),
                                      padding: const WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(vertical: 20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Manager',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(5),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AuthPageTenant(),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      fixedSize: const WidgetStatePropertyAll(
                                          Size.fromWidth(double.maxFinite)),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      elevation: const WidgetStatePropertyAll(3),
                                      shadowColor:
                                          WidgetStatePropertyAll(Theme.of(context).shadowColor),
                                      backgroundColor:
                                          WidgetStatePropertyAll(Theme.of(context).primaryColor),
                                      padding: const WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(vertical: 20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Tenant',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AuthPageClient(),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                elevation: const WidgetStatePropertyAll(3),
                                shadowColor: WidgetStatePropertyAll(Theme.of(context).shadowColor),
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(vertical: 20),
                                ),
                                fixedSize:
                                    const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                                backgroundColor:
                                    WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      width: 0.75,
                                      color: Theme.of(context).colorScheme.tertiary,
                                    ),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Customer',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
