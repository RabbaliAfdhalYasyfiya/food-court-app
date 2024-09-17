import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../services/firebase_auth_service.dart';
import '../../../widget/snackbar.dart';
import '../../../widget/form.dart';
import '../../../widget/load.dart';
import '../../welcome_page.dart';
import '../main_page.dart';

class AuthPageTenant extends StatefulWidget {
  const AuthPageTenant({super.key});

  @override
  State<AuthPageTenant> createState() => _AuthPageTenantState();
}

class _AuthPageTenantState extends State<AuthPageTenant> {
  final auth = FirebaseAuthService();
  bool obscure = false;
  bool checked = false;

  @override
  void dispose() {
    auth.emailVendorController.dispose();
    auth.passwordVendorController.dispose();
    super.dispose();
  }

  void enterAuth() async {
    showLoading(context);

    User? adminSignIn = await auth.signInEmailAndPasswordVendor(context);

    if (adminSignIn != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPageTenant(),
        ),
      );

      snackBarCustom(
        context,
        Colors.greenAccent.shade400,
        'Enter, Successfully',
        Colors.white,
      );
    } else if (adminSignIn == null) {
      snackBarCustom(
        context,
        Colors.redAccent.shade400,
        'Some error happen',
        Colors.white,
      );

      hideLoading(context);
    }
  }

  FocusNode fieldEmail = FocusNode();
  FocusNode fieldPass = FocusNode();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
            ),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WelcomePage(),
                ),
              );
            },
          ),
          titleSpacing: 2,
          title: const Text('Tenant'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/marketplace-pana.png',
                          width: 160,
                          filterQuality: FilterQuality.low,
                        ),
                        const Gap(10),
                        Text(
                          "Let's! Enter to find out.",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(30),
                  FieldFormEmail(
                    hintText: 'Enter email address',
                    controller: auth.emailVendorController,
                    inputType: TextInputType.emailAddress,
                    focusNode: fieldEmail,
                    onFieldSubmit: (val) {
                      FocusScope.of(context).requestFocus(fieldPass);
                    },
                  ),
                  const Gap(10),
                  FieldFormPassword(
                    obscure: obscure,
                    hintText: 'Enter password',
                    controller: auth.passwordVendorController,
                    focusNode: fieldPass,
                    onTap: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox.adaptive(
                            value: checked,
                            visualDensity: VisualDensity.compact,
                            activeColor: Theme.of(context).primaryColor,
                            side:
                                BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
                            splashRadius: 50,
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            onChanged: (value) {
                              setState(() {
                                checked = value!;
                              });
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                checked = !checked;
                              });
                            },
                            child: Text(
                              'Remember me',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   CupertinoPageRoute(
                          //     builder: (context) => const ForgotPassClient(),
                          //   ),
                          // );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(30),
                  ElevatedButton(
                    onPressed: () {
                      if (auth.emailVendorController.text.isEmpty &&
                          auth.passwordVendorController.text.isEmpty) {
                        snackBarCustom(
                          context,
                          Colors.redAccent.shade400,
                          'Email and Password is empty',
                          Colors.white,
                        );
                      } else if (auth.emailVendorController.text.isEmpty) {
                        snackBarCustom(
                          context,
                          Colors.redAccent.shade400,
                          'Email is empty',
                          Colors.white,
                        );
                      } else if (auth.passwordVendorController.text.isEmpty) {
                        snackBarCustom(
                          context,
                          Colors.redAccent.shade400,
                          'Password is empty',
                          Colors.white,
                        );
                      } else if (!checked) {
                        snackBarCustom(
                          context,
                          Colors.redAccent.shade400,
                          'Please check Remember me',
                          Colors.white,
                        );
                      } else {
                        enterAuth();
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      elevation: const WidgetStatePropertyAll(3),
                      shadowColor: const WidgetStatePropertyAll(Colors.black),
                      backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    child: const Text(
                      'Enter',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Gap(10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
