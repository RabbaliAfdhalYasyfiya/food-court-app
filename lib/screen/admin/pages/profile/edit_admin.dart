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
import '../../../../widget/form.dart';

class EditProfileAdmin extends StatefulWidget {
  const EditProfileAdmin({
    super.key,
    required this.placeNameController,
    required this.emailController,
    required this.phoneNumberController,
  });

  final TextEditingController placeNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;

  @override
  State<EditProfileAdmin> createState() => _EditProfileAdminState();
}

class _EditProfileAdminState extends State<EditProfileAdmin> {
  final currentAdmin = FirebaseAuth.instance.currentUser!;
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

  //get from camera
  void getFromCamera() async {
    Uint8List imgCamera = await pickImage(ImageSource.camera);

    setState(() {
      _image = imgCamera;
    });
  }

  //get from gallery
  void getFromGallery() async {
    Uint8List imgGallery = await pickImage(ImageSource.gallery);

    setState(() {
      _image = imgGallery;
    });
  }

  //delete image
  void deleteImage() async {
    setState(() {
      _image = null;
    });
  }

  void updateProfile(
    String image,
    String placeName,
    String email,
    String phoneNumber,
  ) async {
    await FirebaseFirestore.instance.collection('admins').doc(currentAdmin.uid).update({
      'image_place': image,
      'place_name': placeName,
      'email': email,
      'phone_number': phoneNumber,
    });
  }

  bool loadSign = false;

  FocusNode fieldPlaceName = FocusNode();
  FocusNode fieldEmail = FocusNode();
  FocusNode fieldPhoneNum = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        titleSpacing: 2,
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('admins').doc(currentAdmin.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final adminData = snapshot.data!.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: _image != null
                                ? Image.memory(
                                    _image!,
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                  )
                                : Image.network(
                                    adminData['image_place'],
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          right: 20,
                          child: IconButton(
                            style: ButtonStyle(
                              visualDensity: VisualDensity.comfortable,
                              elevation: const WidgetStatePropertyAll(2),
                              padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 25)),
                              backgroundColor:
                                  WidgetStatePropertyAll(Theme.of(context).primaryColor),
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
                    const Gap(15),
                    FormFields(
                      prefixIcon: Iconsax.building,
                      inputType: TextInputType.text,
                      controller: widget.placeNameController,
                      hintText: 'Place Name',
                      tap: false,
                      maxLineBoolean: false,
                      textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                      focusNode: fieldPlaceName,
                      onFieldSubmit: (val) {
                        FocusScope.of(context).requestFocus(fieldEmail);
                      },
                    ),
                    const Gap(15),
                    FormFields(
                      prefixIcon: Iconsax.sms,
                      inputType: TextInputType.text,
                      controller: widget.emailController,
                      hintText: 'Email Address',
                      tap: false,
                      maxLineBoolean: false,
                      textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                      focusNode: fieldEmail,
                      onFieldSubmit: (val) {
                        FocusScope.of(context).requestFocus(fieldPhoneNum);
                      },
                    ),
                    const Gap(15),
                    FormFields(
                      prefixIcon: Iconsax.call_calling,
                      inputType: TextInputType.phone,
                      controller: widget.phoneNumberController,
                      hintText: 'Phone Number',
                      tap: false,
                      maxLineBoolean: false,
                      textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                      focusNode: fieldPhoneNum,
                      onFieldSubmit: (val) {
                        FocusScope.of(context).requestFocus();
                      },
                    ),
                    const Gap(50),
                    ElevatedButton(
                      onPressed: () {
                        enterUpdate();
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
              );
            } else {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
          },
        ),
      ),
    );
  }

  void enterUpdate() async {
    setState(() {
      loadSign = true;
    });

    updateProfile(
      await uploadImageToStorage("image_admins/${currentAdmin.uid}", _image!),
      widget.placeNameController.text,
      widget.emailController.text,
      widget.phoneNumberController.text,
    );

    Navigator.pop(context);

    setState(() {
      loadSign = false;
    });
  }
}
