import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../widget/form.dart';
import '../../../widget/snackbar.dart';

final formKey = GlobalKey<FormState>();

class ForgotPassClient extends StatefulWidget {
  const ForgotPassClient({super.key});

  @override
  State<ForgotPassClient> createState() => _ForgotPassClientState();
}

class _ForgotPassClientState extends State<ForgotPassClient> {
  final emailClientController = TextEditingController();

  @override
  void dispose() {
    emailClientController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailClientController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Error is : $e');

      snackBarCustom(
        context,
        Colors.redAccent.shade400,
        e.message.toString(),
        Colors.white,
      );
    }
  }

  FocusNode fieldEmail = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 2,
          title: const Text(
            'Forget Password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(50),
                  const Text(
                    'Enter your Email Address and we will send you a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Gap(20),
                  FieldFormEmail(
                    hintText: 'Enter email address',
                    controller: emailClientController,
                    inputType: TextInputType.emailAddress,
                    focusNode: fieldEmail,
                    onFieldSubmit: (val) {
                      FocusScope.of(context).requestFocus();
                    },
                  ),
                  const Gap(20),
                  ElevatedButton(
                    onPressed: () {
                      if (emailClientController.text.isEmpty) {
                        snackBarCustom(
                          context,
                          Colors.redAccent.shade400,
                          'Email is empty',
                          Colors.white,
                        );
                      } else {
                        passwordReset();
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: const WidgetStatePropertyAll(
                        Size.fromWidth(double.maxFinite),
                      ),
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
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
