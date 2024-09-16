import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_court_app/widget/load.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';
import 'package:gap/gap.dart';

import '../../../../../widget/bottom_sheet.dart';
import '../../../../../widget/snackbar.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({
    super.key,
    required this.currentUser,
    required this.adminId,
    required this.placeName,
  });

  final User currentUser;
  final String adminId;
  final String placeName;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController commentController = TextEditingController();
  bool isRTLMode = false;
  bool loadSign = false;
  double rateReview = 0.0;
  var uuid = const Uuid();

  Uint8List? _image;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    }
    debugPrint('No Image Selected');
  }

  Future<String> uploadImageToStorage(String childname, Uint8List file) async {
    Reference ref = _storage.ref().child(childname);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  //get from camera
  void getFromCamera() async {
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
  void deleteImage() async {
    setState(() {
      _image = null;
    });
  }

  void enterAddImageReview(
    String imageUser,
    String username,
    String clientId,
  ) async {
    addReview(
      imageUser,
      username,
      clientId,
      await uploadImageToStorage('image_review/${widget.currentUser.uid}/${uuid.v4()}', _image!),
    );
  }

  void addReview(
    String image,
    String username,
    String clientId,
    String imageReview,
  ) async {
    DocumentReference reviewRef = await FirebaseFirestore.instance
        .collection('admins')
        .doc(widget.adminId)
        .collection('reviews')
        .add({
      'admin_id': widget.adminId,
      'client_id': clientId,
      'image': image,
      'username': username,
      'rating': rateReview,
      'comment': commentController.text,
      'image_review': imageReview,
    });

    await reviewRef.update({
      'review_id': reviewRef.id,
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
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
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('clients')
              .doc(widget.currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 80,
                              width: double.infinity,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Give your rating',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  const Gap(10),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RatingBar(
                                          textDirection:
                                              isRTLMode ? TextDirection.rtl : TextDirection.ltr,
                                          initialRating: rateReview,
                                          itemCount: 5,
                                          direction: Axis.horizontal,
                                          itemPadding: const EdgeInsets.only(right: 2.5),
                                          maxRating: 5,
                                          minRating: 1,
                                          itemSize: 30,
                                          glow: true,
                                          allowHalfRating: true,
                                          updateOnDrag: true,
                                          glowColor: Colors.amber.shade200,
                                          glowRadius: 5,
                                          ratingWidget: RatingWidget(
                                            full: const Icon(
                                              CupertinoIcons.star_fill,
                                              color: Colors.amber,
                                            ),
                                            half: const Icon(
                                              CupertinoIcons.star_lefthalf_fill,
                                              color: Colors.amber,
                                            ),
                                            empty: const Icon(
                                              CupertinoIcons.star_fill,
                                              color: Colors.white38,
                                            ),
                                          ),
                                          onRatingUpdate: (rate) {
                                            setState(() {
                                              rateReview = rate;
                                            });
                                          },
                                        ),
                                        const Gap(5),
                                        SizedBox(
                                          width: 95,
                                          child: Text(
                                            '${rateReview == rateReview.toInt() ? rateReview.toInt() : rateReview} out of 5',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Give more information to your friends about environment, the food in ${widget.placeName}...',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Gap(10),
                              TextFormField(
                                maxLines: 5,
                                expands: false,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                selectionControls: EmptyTextSelectionControls(),
                                enableInteractiveSelection: true,
                                canRequestFocus: true,
                                showCursor: false,
                                cursorColor: Colors.black,
                                obscureText: false,
                                keyboardType: TextInputType.multiline,
                                controller: commentController,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      width: 1,
                                      style: BorderStyle.solid,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      style: BorderStyle.solid,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  hintText: 'Comments',
                                  hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black38,
                                    fontSize: 15,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const Gap(10),
                              _image != null
                                  ? Container(
                                      height: 175,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Theme.of(context).colorScheme.outline),
                                        borderRadius: BorderRadius.circular(15),
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.memory(
                                              _image!,
                                              height: double.infinity,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.low,
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: deleteImage,
                                              child: const CircleAvatar(
                                                backgroundColor: Colors.white70,
                                                radius: 15,
                                                child: Icon(
                                                  Iconsax.minus,
                                                  size: 25,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
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
                                            title: 'Image Review',
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 175,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Theme.of(context).colorScheme.outline),
                                          borderRadius: BorderRadius.circular(15),
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                        ),
                                        child: const Icon(
                                          Iconsax.gallery_add5,
                                          color: Colors.black38,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                      child: ElevatedButton(
                        onPressed: () {
                          showLoading(context);
                          enterAddImageReview(
                            userData['image'],
                            userData['username'],
                            userData['client_id'],
                          );
                          snackBarCustom(
                            context,
                            Theme.of(context).primaryColor,
                            '${widget.placeName} add Review, Successfully',
                            Colors.white,
                          );

                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          elevation: const WidgetStatePropertyAll(3),
                          fixedSize: const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                          shadowColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                          backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 17),
                          ),
                        ),
                        child: const Text(
                          'Saved Review',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
