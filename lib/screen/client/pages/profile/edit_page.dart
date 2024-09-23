import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../widget/bottom_sheet.dart';
import '../../../../widget/button.dart';
import '../../../../widget/form.dart';
import 'profile_page.dart';

class EditPage extends StatefulWidget {
  const EditPage({
    super.key,
    required this.firstnameEditController,
    required this.lastnameEditController,
    required this.usernameEditController,
    required this.emailEditController,
    required this.phonenumberEditController,
  });

  final TextEditingController firstnameEditController;
  final TextEditingController lastnameEditController;
  final TextEditingController usernameEditController;
  final TextEditingController emailEditController;
  final TextEditingController phonenumberEditController;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Uint8List? _image;

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    }
    debugPrint('No Image Selected');
  }

  // Function untuk mengupdate gambar profil
  Future<String> uploadImageToStorage(String childname, Uint8List file) async {
    Reference ref = _storage.ref().child(childname);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> updateProfile(
    String image,
    String firstName,
    String lastName,
    String userName,
    String email,
    String phoneNumber,
  ) async {
    await FirebaseFirestore.instance.collection('clients').doc(currentUser.uid).update({
      'image': image,
      'firstname': firstName,
      'lastname': lastName,
      'username': userName,
      'email': email,
      'phone_number': phoneNumber,
    });
  }

  //get from camera
  getFromCamera() async {
    Uint8List? imgCamera = await pickImage(ImageSource.camera);

    setState(() {
      _image = imgCamera;
    });
  }

  //get from gallery
  getFromGallery() async {
    Uint8List? imgGallery = await pickImage(ImageSource.gallery);

    setState(() {
      _image = imgGallery;
    });
  }

  //delete image
  deleteImage() async {
    setState(() {
      _image = null;
    });
  }

  FocusNode fieldFirstName = FocusNode();
  FocusNode fieldLastName = FocusNode();
  FocusNode fieldUsername = FocusNode();
  FocusNode fieldEmail = FocusNode();
  FocusNode fieldPhoneNum = FocusNode();

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
              Navigator.pop(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
          titleSpacing: 2,
          title: const Text('Edit Profile'),
        ),
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance.collection('clients').doc(currentUser.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                return loadSign
                    ? const Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                          strokeCap: StrokeCap.round,
                          strokeWidth: 5,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 125,
                                    width: 125,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Theme.of(context).colorScheme.onPrimary,
                                                  Theme.of(context).colorScheme.onSecondary,
                                                  Theme.of(context).colorScheme.onTertiary,
                                                ],
                                              ),
                                            ),
                                            child: _image != null
                                                ? Image.memory(
                                                    _image!,
                                                    height: double.infinity,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    filterQuality: FilterQuality.low,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: userData['image'],
                                                    filterQuality: FilterQuality.low,
                                                    fit: BoxFit.cover,
                                                    useOldImageOnUrlChange: true,
                                                    fadeInCurve: Curves.easeIn,
                                                    fadeOutCurve: Curves.easeOut,
                                                    fadeInDuration:
                                                        const Duration(milliseconds: 500),
                                                    fadeOutDuration:
                                                        const Duration(milliseconds: 750),
                                                    errorWidget: (context, url, error) {
                                                      return Center(
                                                        child: Text(
                                                          'Image $error',
                                                          style: const TextStyle(
                                                            color: Colors.redAccent,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: IconButton.filled(
                                            style: ButtonStyle(
                                              visualDensity: VisualDensity.comfortable,
                                              elevation: const WidgetStatePropertyAll(2),
                                              backgroundColor: WidgetStatePropertyAll(
                                                  Theme.of(context).primaryColor),
                                            ),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                context: context,
                                                builder: (context) => BottomSheetPhoto(
                                                  camera: () {
                                                    getFromCamera();
                                                    Navigator.pop(context);
                                                  },
                                                  gallery: () {
                                                    getFromGallery();
                                                    Navigator.pop(context);
                                                  },
                                                  delete: () {
                                                    deleteImage();
                                                    Navigator.pop(context);
                                                  },
                                                  title: 'Profile Photo',
                                                ),
                                              );
                                            },
                                            color: Theme.of(context).primaryColor,
                                            icon: const Icon(
                                              Iconsax.camera,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(50),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: FormFields(
                                              prefixIcon: Iconsax.user_edit,
                                              inputType: TextInputType.name,
                                              controller: widget.firstnameEditController,
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
                                              prefixIcon: Iconsax.user_edit,
                                              inputType: TextInputType.name,
                                              controller: widget.lastnameEditController,
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
                                      const Gap(15),
                                      FormFields(
                                        prefixIcon: Iconsax.user_edit,
                                        inputType: TextInputType.text,
                                        controller: widget.usernameEditController,
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
                                      const Gap(15),
                                      FormFields(
                                        prefixIcon: Iconsax.sms_edit,
                                        inputType: TextInputType.emailAddress,
                                        controller: widget.emailEditController,
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
                                      const Gap(15),
                                      FormFields(
                                        prefixIcon: Iconsax.call_add,
                                        inputType: TextInputType.phone,
                                        controller: widget.phonenumberEditController,
                                        hintText: 'Phone Number',
                                        tap: false,
                                        maxLineBoolean: false,
                                        textInputFormatter:
                                            FilteringTextInputFormatter.singleLineFormatter,
                                        focusNode: fieldPhoneNum,
                                        onFieldSubmit: (val) {
                                          FocusScope.of(context).requestFocus();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Gap(50),
                              ButtonPrimary(
                                onPressed: () {
                                  enterUpdate();
                                },
                                child: const Text(
                                  'Saved',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool loadSign = false;

  void enterUpdate() async {
    setState(() {
      loadSign = true;
    });

    updateProfile(
      await uploadImageToStorage("image_clients/${currentUser.uid}", _image!),
      widget.firstnameEditController.text,
      widget.lastnameEditController.text,
      widget.usernameEditController.text,
      widget.emailEditController.text,
      widget.phonenumberEditController.text,
    );

    Navigator.pop(context);

    setState(() {
      loadSign = false;
    });
  }
}
