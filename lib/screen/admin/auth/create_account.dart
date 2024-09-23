import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../../services/firebase_auth_service.dart';
import '../../../widget/bottom_sheet.dart';
import '../../../widget/button.dart';
import '../../../widget/snackbar.dart';
import '../../../widget/form.dart';
import '../../../widget/load.dart';
import '../main_page.dart';
import 'auth_page.dart';

class CreateAccountAdmin extends StatefulWidget {
  const CreateAccountAdmin({super.key});

  @override
  State<CreateAccountAdmin> createState() => _CreateAccountAdminState();
}

class _CreateAccountAdminState extends State<CreateAccountAdmin> {
  final latController = TextEditingController();
  final lngController = TextEditingController();

  bool obscure = false;
  late String uniqueCode;

  final _auth = FirebaseAuthService();

  @override
  void dispose() {
    uniqueCode = generateUniqueCode();
    super.dispose();
  }

  @override
  void initState() {
    uniqueCode = generateUniqueCode();
    _auth.codeUniqueController.text = uniqueCode;
    super.initState();
  }

  // Generate Code Unique
  String generateUniqueCode({int length = 12}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; // Karakter yang digunakan untuk kode unik
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  void enterAuth() async {
    showLoading(context);

    double lat = double.parse(latController.text);
    double lng = double.parse(lngController.text);

    User? userSignUp = await _auth.signUpEmailAndPasswordAdmin(
      context,
      lat,
      lng,
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
          builder: (context) => const MainPageAdmin(),
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

  FocusNode fieldNamePlace = FocusNode();
  FocusNode fieldEmail = FocusNode();
  FocusNode fieldPhoneNum = FocusNode();
  FocusNode fieldPass = FocusNode();
  FocusNode fieldLocation = FocusNode();

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
                  builder: (context) => const AuthPageAdmin(),
                ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                          FormFieldGenerateCode(
                            prefixIcon: Iconsax.code_1,
                            inputType: TextInputType.name,
                            controller: _auth.codeUniqueController,
                            hintText: 'Generate Code',
                            onTapGenerate: () {
                              setState(() {
                                uniqueCode = generateUniqueCode();
                                _auth.codeUniqueController.text = uniqueCode;
                              });
                            },
                          ),
                          const Gap(10),
                          FormFields(
                            prefixIcon: Iconsax.building,
                            inputType: TextInputType.text,
                            controller: _auth.placeNameController,
                            hintText: 'Name Place',
                            tap: false,
                            maxLineBoolean: false,
                            textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                            focusNode: fieldNamePlace,
                            onFieldSubmit: (val) {
                              FocusScope.of(context).requestFocus(fieldEmail);
                            },
                          ),
                          const Gap(10),
                          FormFields(
                            prefixIcon: Iconsax.sms,
                            inputType: TextInputType.emailAddress,
                            controller: _auth.emailAdminController,
                            hintText: 'Email Address',
                            tap: false,
                            maxLineBoolean: false,
                            textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                            focusNode: fieldEmail,
                            onFieldSubmit: (val) {
                              FocusScope.of(context).requestFocus(fieldPhoneNum);
                            },
                          ),
                          const Gap(10),
                          FormFields(
                            prefixIcon: Iconsax.call_calling,
                            inputType: TextInputType.phone,
                            controller: _auth.phoneNumberAdminController,
                            hintText: 'Phone Number',
                            tap: false,
                            maxLineBoolean: false,
                            textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                            focusNode: fieldPhoneNum,
                            onFieldSubmit: (val) {
                              FocusScope.of(context).requestFocus(fieldPass);
                            },
                          ),
                          const Gap(10),
                          FormFieldPassword(
                            prefixIcon: Iconsax.password_check,
                            inputType: TextInputType.visiblePassword,
                            controller: _auth.passwordAdminController,
                            hintText: 'Password',
                            obscure: obscure,
                            focusNode: fieldPass,
                            onTap: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                          ),
                          const Gap(10),
                          FormFieldGetLocation(
                            prefixIcon: Iconsax.location_add,
                            inputType: TextInputType.streetAddress,
                            controller: _auth.addressPlaceController,
                            hintText: 'Address Location',
                            onTapLocation: () {
                              showModalBottomSheet(
                                scrollControlDisabledMaxHeightRatio: 1 / 1.35,
                                context: context,
                                isScrollControlled: false,
                                enableDrag: false,
                                useRootNavigator: false,
                                showDragHandle: false,
                                useSafeArea: true,
                                isDismissible: false,
                                elevation: 0,
                                barrierColor: Theme.of(context).colorScheme.tertiary,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return BottomSheetLocation(
                                    controller: _auth.addressPlaceController,
                                    lat: latController,
                                    lng: lngController,
                                  );
                                },
                              );
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
                        if (_auth.placeNameController.text.isEmpty ||
                            _auth.emailAdminController.text.isEmpty ||
                            _auth.phoneNumberAdminController.text.isEmpty ||
                            _auth.addressPlaceController.text.isEmpty ||
                            _auth.passwordAdminController.text.isEmpty) {
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
