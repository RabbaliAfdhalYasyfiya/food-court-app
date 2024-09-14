import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widget/snackbar.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final addressPlaceController = TextEditingController();
  final adminIdController = TextEditingController();
  final codeAdminController = TextEditingController();
  final codeUniqueController = TextEditingController();
  final emailAdminController = TextEditingController();
  final emailClientController = TextEditingController();
  final emailVendorController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordAdminController = TextEditingController();
  final passwordClientController = TextEditingController();
  final passwordVendorController = TextEditingController();
  final phoneNumberAdminController = TextEditingController();
  final phoneNumberClientController = TextEditingController();
  final phoneNumberVendorController = TextEditingController();
  final placeNameController = TextEditingController();
  final userNameController = TextEditingController();
  final vendorNameController = TextEditingController();

  final String imagePlace =
      'https://i.pinimg.com/736x/e3/be/0a/e3be0a7d8b36490242fde2a63f7d0d9a.jpg';
  final String imageUser =
      'https://i.pinimg.com/564x/2f/15/f2/2f15f2e8c688b3120d3d26467b06330c.jpg';

  Future<User?> signUpEmailAndPasswordVendor(
    BuildContext context,
    String adminID,
    String adminEmail,
    String adminPass,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: emailVendorController.text,
        password: passwordVendorController.text,
      );

      String roleVendor = 'isVendor';

      bool isActive = true;

      bool isClose = false;

      await FirebaseFirestore.instance.collection('vendors').doc(credential.user!.uid).set({
        'admin_id': adminID,
        'vendor_id': credential.user!.uid,
        'vendor_name': vendorNameController.text,
        'email_address': emailVendorController.text,
        'phone_number': phoneNumberVendorController.text,
        'password': passwordVendorController.text,
        'image_place': imagePlace,
        'role_account': roleVendor,
        'is_close': isClose,
        'is_active': isActive,
      });

      await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPass,
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'Email address is already in use',
          Colors.white,
        );
      } else {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'An error occurred: ${e.code}',
          Colors.white,
        );
      }
    }
    return null;
  }

  Future<User?> signInEmailAndPasswordVendor(
    BuildContext context,
  ) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: emailVendorController.text,
        password: passwordVendorController.text,
      );

      User? user = credential.user;

      if (user != null) {
        DocumentSnapshot vendorDoc =
            await FirebaseFirestore.instance.collection('vendors').doc(user.uid).get();

        if (vendorDoc.exists && vendorDoc.get('role_account') == 'isVendor') {
          return user;
        } else {
          snackBarCustom(
            context,
            Colors.redAccent.shade400,
            'Access denied: You do not have Tenant privileges',
            Colors.white,
          );
          await _auth.signOut();
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' && e.code == 'wrong-password') {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'Invalid email or password',
          Colors.white,
        );
      } else {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'An error occurred: ${e.code}',
          Colors.white,
        );
      }
    }
    return null;
  }

  Future<User?> signUpEmailAndPasswordClient(
    BuildContext context,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: emailClientController.text,
        password: passwordClientController.text,
      );

      //await credential.user!.sendEmailVerification();

      String roleClient = 'isClient';

      await FirebaseFirestore.instance.collection('clients').doc(credential.user!.uid).set(
        {
          'client_id': credential.user!.uid,
          'firstname': firstNameController.text,
          'lastname': lastNameController.text,
          'username': userNameController.text,
          'email_address': emailClientController.text,
          'phone_number': phoneNumberClientController.text,
          'password': passwordClientController.text,
          'image': imageUser,
          'role_account': roleClient,
        },
      );

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'Email address is already in use',
          Colors.white,
        );
      } else {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'An error occurred: ${e.code}',
          Colors.white,
        );
      }
    }

    return null;
  }

  Future<User?> signInEmailAndPasswordClient(
    BuildContext context,
  ) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: emailClientController.text,
        password: passwordClientController.text,
      );

      User? user = credential.user;

      if (user != null) {
        DocumentSnapshot clientDoc =
            await FirebaseFirestore.instance.collection('clients').doc(user.uid).get();

        if (clientDoc.exists && clientDoc.get('role_account') == 'isClient') {
          return user;
        } else {
          snackBarCustom(
            context,
            Colors.redAccent.shade400,
            'Access denied: You do not have Customer privileges',
            Colors.white,
          );
          await _auth.signOut();
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-email') {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'Invalid email or password',
          Colors.white,
        );
      } else if (e.code == 'too-may-requests') {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'Sorry, too many requests. Please wait a moment before trying again',
          Colors.white,
        );
      }
    }

    return null;
  }

  Future<User?> signUpEmailAndPasswordAdmin(
    BuildContext context,
    double lat,
    double lng,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: emailAdminController.text,
        password: passwordAdminController.text,
      );

      bool isClose = false;

      String roleAdmin = 'isAdmin';

      String imageIcon = 'assets/mapicons/restaurants.png';

      await FirebaseFirestore.instance.collection('admins').doc(credential.user!.uid).set({
        'admin_id': credential.user!.uid,
        'is_close': isClose,
        'code_unique': codeUniqueController.text,
        'place_name': placeNameController.text,
        'email_address': emailAdminController.text,
        'phone_number': phoneNumberAdminController.text,
        'password': passwordAdminController.text,
        'address_place': addressPlaceController.text,
        'image_place': imagePlace,
        'latitude': lat,
        'longitude': lng,
        'image_icon': imageIcon,
        'role_account': roleAdmin,
      });

      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error creating admin account: ${e.code}");
      if (e.code == 'email-already-in-use') {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'Email address is already in use',
          Colors.white,
        );
      } else {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'An error occurred: ${e.code}',
          Colors.white,
        );
      }

      return null;
    }
  }

  Future<User?> signInEmailAndPasswordAdmin(
    BuildContext context,
  ) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: emailAdminController.text,
        password: passwordAdminController.text,
      );

      User? user = credential.user;

      if (user != null) {
        DocumentSnapshot adminDoc =
            await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();

        if (adminDoc.exists && adminDoc.get('role_account') == 'isAdmin') {
          return user;
        } else {
          snackBarCustom(
            context,
            Colors.redAccent.shade400,
            'Access denied: You do not have Manager privileges',
            Colors.white,
          );
          await _auth.signOut();
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' && e.code == 'wrong-password') {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'Invalid email or password',
          Colors.white,
        );
      } else {
        snackBarCustom(
          context,
          Colors.redAccent.shade400,
          'An error occurred: ${e.code}',
          Colors.white,
        );
      }
    }

    return null;
  }
}
