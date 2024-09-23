import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../../services/firebase_auth_service.dart';
import '../../../widget/button.dart';
import '../../../widget/snackbar.dart';
import '../../../widget/form.dart';
import '../../../widget/load.dart';
import '../main_page.dart';
import 'auth_page.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final auth = FirebaseAuthService();
  bool loadSign = false;
  bool obscure = false;

  @override
  void dispose() {
    super.dispose();
  }

  void enterAuth() async {
    showLoading(context);

    User? userSignUp = await auth.signUpEmailAndPasswordClient(
      context,
    );

    if (userSignUp != null) {
      snackBarCustom(
        context,
        Colors.greenAccent.shade400,
        'Enter, Created Successfully',
        Colors.white,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPageClient(),
        ),
      );
    } else if (userSignUp == null) {
      snackBarCustom(
        context,
        Colors.redAccent.shade400,
        'Some error happen',
        Colors.white,
      );

      hideLoading(context);
    }
  }

  FocusNode fieldFirstName = FocusNode();
  FocusNode fieldLastName = FocusNode();
  FocusNode fieldUsername = FocusNode();
  FocusNode fieldEmail = FocusNode();
  FocusNode fieldPhoneNum = FocusNode();
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
              Navigator.pop(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthPageClient(),
                ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: loadSign
                ? const Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 5,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Let's create your account.",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                              height: 1,
                            ),
                          ),
                          const Gap(30),
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: FormFields(
                                        prefixIcon: Iconsax.user,
                                        inputType: TextInputType.name,
                                        controller: auth.firstNameController,
                                        hintText: 'First Name',
                                        tap: false,
                                        maxLineBoolean: false,
                                        textInputFormatter:
                                            FilteringTextInputFormatter.singleLineFormatter,
                                        focusNode: fieldFirstName,
                                        onFieldSubmit: (val) {
                                          FocusScope.of(context).requestFocus(fieldLastName);
                                        },
                                      ),
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: FormFields(
                                        prefixIcon: Iconsax.user,
                                        inputType: TextInputType.name,
                                        controller: auth.lastNameController,
                                        hintText: 'Last Name',
                                        tap: false,
                                        maxLineBoolean: false,
                                        textInputFormatter:
                                            FilteringTextInputFormatter.singleLineFormatter,
                                        focusNode: fieldLastName,
                                        onFieldSubmit: (val) {
                                          FocusScope.of(context).requestFocus(fieldUsername);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                FormFields(
                                  prefixIcon: Iconsax.user_edit,
                                  inputType: TextInputType.text,
                                  controller: auth.userNameController,
                                  hintText: 'Username',
                                  tap: false,
                                  maxLineBoolean: false,
                                  textInputFormatter:
                                      FilteringTextInputFormatter.singleLineFormatter,
                                  focusNode: fieldUsername,
                                  onFieldSubmit: (val) {
                                    FocusScope.of(context).requestFocus(fieldEmail);
                                  },
                                ),
                                const Gap(10),
                                FormFields(
                                  prefixIcon: Iconsax.sms,
                                  inputType: TextInputType.emailAddress,
                                  controller: auth.emailClientController,
                                  hintText: 'Email Address',
                                  tap: false,
                                  maxLineBoolean: false,
                                  textInputFormatter:
                                      FilteringTextInputFormatter.singleLineFormatter,
                                  focusNode: fieldEmail,
                                  onFieldSubmit: (val) {
                                    FocusScope.of(context).requestFocus(fieldPhoneNum);
                                  },
                                ),
                                const Gap(10),
                                FormFields(
                                  prefixIcon: Iconsax.call_calling,
                                  inputType: TextInputType.phone,
                                  controller: auth.phoneNumberClientController,
                                  hintText: 'Phone Number',
                                  tap: false,
                                  maxLineBoolean: false,
                                  textInputFormatter:
                                      FilteringTextInputFormatter.singleLineFormatter,
                                  focusNode: fieldPhoneNum,
                                  onFieldSubmit: (val) {
                                    FocusScope.of(context).requestFocus(fieldPass);
                                  },
                                ),
                                const Gap(10),
                                FormFieldPassword(
                                  prefixIcon: Iconsax.password_check,
                                  inputType: TextInputType.visiblePassword,
                                  controller: auth.passwordClientController,
                                  hintText: 'Password',
                                  obscure: obscure,
                                  focusNode: fieldPass,
                                  onTap: () {
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ButtonPrimary(
                            onPressed: () {
                              if (auth.firstNameController.text.isEmpty ||
                                  auth.lastNameController.text.isEmpty ||
                                  auth.userNameController.text.isEmpty ||
                                  auth.emailClientController.text.isEmpty ||
                                  auth.phoneNumberClientController.text.isEmpty ||
                                  auth.passwordClientController.text.isEmpty) {
                                snackBarCustom(
                                  context,
                                  Colors.redAccent.shade400,
                                  'Fill in the blank field',
                                  Colors.white,
                                );
                              } else {
                                enterAuth();
                              }
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Gap(25),
                          RichText(
                            textAlign: TextAlign.center,
                            textWidthBasis: TextWidthBasis.parent,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'By creating an account, you agree to our ',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.solid,
                                  ),
                                ),
                                TextSpan(
                                  text: ' and agree to ',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.solid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(50),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
