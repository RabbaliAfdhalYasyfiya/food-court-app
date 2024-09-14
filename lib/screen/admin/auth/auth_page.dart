import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../services/firebase_auth_service.dart';
import '../../../widget/snackbar.dart';
import '../../../widget/form.dart';
import '../../../widget/load.dart';
import '../../welcome_page.dart';
import '../main_page.dart';
import 'create_account.dart';

class AuthPageAdmin extends StatefulWidget {
  const AuthPageAdmin({super.key});

  @override
  State<AuthPageAdmin> createState() => _AuthPageAdminState();
}

class _AuthPageAdminState extends State<AuthPageAdmin> {
  final auth = FirebaseAuthService();
  bool obscure = false;
  bool checked = false;

  @override
  void dispose() {
    auth.emailAdminController.dispose();
    auth.passwordAdminController.dispose();
    super.dispose();
  }

  void enterAuth() async {
    showLoading(context);

    User? adminSignIn = await auth.signInEmailAndPasswordAdmin(context);

    if (adminSignIn != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPageAdmin(),
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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
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
          title: const Text(
            'Manager',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
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
                          'assets/images/instantInformation-pana.png',
                          width: 160,
                          filterQuality: FilterQuality.low,
                        ),
                        const Gap(10),
                        const Text(
                          "Let's! Enter to find out.",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(30),
                  FieldFormEmail(
                    hintText: 'Enter email address',
                    controller: auth.emailAdminController,
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
                    controller: auth.passwordAdminController,
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
                            side: const BorderSide(color: Colors.black54, width: 1),
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
                            child: const Text(
                              'Remember me',
                              style: TextStyle(
                                color: Colors.black54,
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
                      if (auth.emailAdminController.text.isEmpty &&
                          auth.passwordAdminController.text.isEmpty) {
                        snackBarCustom(
                          context,
                          Colors.redAccent.shade400,
                          'Email and Password is empty',
                          Colors.white,
                        );
                      } else if (auth.emailAdminController.text.isEmpty) {
                        snackBarCustom(
                          context,
                          Colors.redAccent.shade400,
                          'Email is empty',
                          Colors.white,
                        );
                      } else if (auth.passwordAdminController.text.isEmpty) {
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const CreateAccountAdmin(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      fixedSize: const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      elevation: const WidgetStatePropertyAll(1),
                      side: WidgetStatePropertyAll(
                        BorderSide(
                          width: 1.25,
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                      ),
                      backgroundColor: const WidgetStatePropertyAll(Colors.white),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Gap(25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
