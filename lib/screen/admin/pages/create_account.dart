import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../../services/firebase_auth_service.dart';
import '../../../widget/snackbar.dart';
import '../../../widget/form.dart';
import '../../../widget/load.dart';

class CreateAccountVendor extends StatefulWidget {
  const CreateAccountVendor({
    super.key,
    required this.adminId,
    required this.adminEmail,
    required this.adminPass,
  });

  final String adminEmail;
  final String adminId;
  final String adminPass;

  @override
  State<CreateAccountVendor> createState() => _CreateAccountVendorState();
}

class _CreateAccountVendorState extends State<CreateAccountVendor> {
  final _auth = FirebaseAuthService();
  bool obscure = false;

  void enterAuth() async {
    showLoading(context);

    User? userSignUp = await _auth.signUpEmailAndPasswordVendor(
      context,
      widget.adminId,
      widget.adminEmail,
      widget.adminPass,
    );

    if (userSignUp != null) {
      snackBarCustom(
        context,
        Colors.greenAccent.shade400,
        'Enter, Created Successfully',
        Colors.white,
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

    Navigator.pop(context);
  }

  FocusNode fieldNameVendor = FocusNode();
  FocusNode fieldEmail = FocusNode();
  FocusNode fieldPhoneNum = FocusNode();
  FocusNode fieldPass = FocusNode();

  @override
  Widget build(BuildContext context) {
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
              Navigator.pop(context);
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
                      "Let's create Tenant account.",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                        height: 1,
                      ),
                    ),
                    const Gap(30),
                    Column(
                      children: [
                        const Gap(10),
                        FormFields(
                          prefixIcon: Iconsax.shop,
                          inputType: TextInputType.name,
                          controller: _auth.vendorNameController,
                          hintText: 'Name Tenant',
                          tap: false,
                          maxLineBoolean: false,
                          textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                          focusNode: fieldNameVendor,
                          onFieldSubmit: (val) {
                            FocusScope.of(context).requestFocus(fieldEmail);
                          },
                        ),
                        const Gap(10),
                        FormFields(
                          prefixIcon: Iconsax.sms,
                          inputType: TextInputType.emailAddress,
                          controller: _auth.emailVendorController,
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
                          controller: _auth.phoneNumberVendorController,
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
                          controller: _auth.passwordVendorController,
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
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_auth.vendorNameController.text.isEmpty ||
                        _auth.emailVendorController.text.isEmpty ||
                        _auth.phoneNumberVendorController.text.isEmpty ||
                        _auth.passwordVendorController.text.isEmpty) {
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
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    fixedSize: const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                    elevation: const WidgetStatePropertyAll(1),
                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Gap(75),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
