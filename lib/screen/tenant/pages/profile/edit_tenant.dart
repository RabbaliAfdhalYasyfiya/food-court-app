import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../widget/bottom_sheet.dart';
import '../../../../widget/form.dart';

class EditTenant extends StatefulWidget {
  const EditTenant({
    super.key,
    required this.placeNameController,
    required this.emailController,
    required this.phoneNumberController,
  });

  final TextEditingController placeNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;

  @override
  State<EditTenant> createState() => _EditTenantState();
}

class _EditTenantState extends State<EditTenant> {
  final currentVendor = FirebaseAuth.instance.currentUser!;
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
    await FirebaseFirestore.instance.collection('vendors').doc(currentVendor.uid).update({
      'image_place': image,
      'vendor_name': placeName,
      'email_address': email,
      'phone_number': phoneNumber,
    });
  }

  bool loadSign = false;

  FocusNode fieldVendorName = FocusNode();
  FocusNode fieldEmail = FocusNode();
  FocusNode fieldPhoneNum = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
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
              Navigator.pop(context);
            },
          ),
          titleSpacing: 2,
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance.collection('vendors').doc(currentVendor.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final tenantData = snapshot.data!.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.grey.shade200,
                                          Colors.grey.shade100,
                                          Colors.grey.shade50,
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
                                        : Image.network(
                                            tenantData['image_place'],
                                            height: double.infinity,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            filterQuality: FilterQuality.low,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: IconButton.filled(
                                    visualDensity: VisualDensity.comfortable,
                                    padding: const EdgeInsets.all(15),
                                    style: const ButtonStyle(
                                      visualDensity: VisualDensity.compact,
                                      elevation: WidgetStatePropertyAll(2),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10))),
                                      ),
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
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(25),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FormFields(
                                  prefixIcon: Iconsax.edit_2,
                                  inputType: TextInputType.name,
                                  controller: widget.placeNameController,
                                  hintText: 'Vendor Name',
                                  tap: false,
                                  maxLineBoolean: false,
                                  textInputFormatter:
                                      FilteringTextInputFormatter.singleLineFormatter,
                                  focusNode: fieldVendorName,
                                  onFieldSubmit: (val) {
                                    FocusScope.of(context).requestFocus(fieldEmail);
                                  },
                                ),
                                const Gap(15),
                                FormFields(
                                  prefixIcon: Iconsax.sms,
                                  inputType: TextInputType.emailAddress,
                                  controller: widget.emailController,
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
                                  prefixIcon: Iconsax.call_calling,
                                  inputType: TextInputType.phone,
                                  controller: widget.phoneNumberController,
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
                        ElevatedButton(
                          onPressed: () {
                            enterUpdate();
                          },
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            fixedSize:
                                const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
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
      ),
    );
  }

  void enterUpdate() async {
    setState(() {
      loadSign = true;
    });

    updateProfile(
      await uploadImageToStorage("image_vendors/${currentVendor.uid}", _image!),
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
