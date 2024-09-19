import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';
import 'package:gap/gap.dart';

import '../../../widget/bottom_sheet.dart';
import '../../../widget/snackbar.dart';
import '../../../widget/form.dart';
import '../../../widget/load.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({
    super.key,
    required this.currentTenant,
  });

  final User currentTenant;

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final nameProductController = TextEditingController();
  final priceProductController = TextEditingController();
  final categoryProductController = TextEditingController();
  final stockProductController = TextEditingController();
  final descriptionProductController = TextEditingController();

  Uint8List? _image;

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? file = await imagePicker.pickImage(source: source);
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

  void getFromCamera() async {
    Uint8List imgCamera = await pickImage(ImageSource.camera);

    setState(() {
      _image = imgCamera;
    });
  }

  void getFromGallery() async {
    Uint8List imgGallery = await pickImage(ImageSource.gallery);

    setState(() {
      _image = imgGallery;
    });
  }

  void deleteImage() async {
    setState(() {
      _image = null;
    });
  }

  void addProduct(
    String imageProduct,
    String nameProduct,
    String priceProduct,
    String categoryProduct,
    int stockProduct,
    String descriptionProduct,
  ) async {
    var timesDate = FieldValue.serverTimestamp();

    DocumentReference productRef = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.currentTenant.uid)
        .collection('products')
        .add({
      'vendor_id': widget.currentTenant.uid,
      'image_product': imageProduct,
      'name_product': nameProduct,
      'price_product': priceProduct,
      'category_product': categoryProduct.isNotEmpty ? categoryProduct : '',
      'stock_product': stockProduct,
      'description_product': descriptionProduct.isNotEmpty ? descriptionProduct : '',
      'times_date': timesDate,
    });
    await productRef.update({
      'product_id': productRef.id,
    });
  }

  var uuid = const Uuid().v4();

  void enterAddProduct() async {
    showLoading(context);

    try {
      final imageUrl =
          await uploadImageToStorage("image_product/${widget.currentTenant.uid}/$uuid", _image!);

      addProduct(
        imageUrl,
        nameProductController.text,
        priceProductController.text,
        categoryProductController.text.isNotEmpty ? categoryProductController.text : '',
        int.parse(stockProductController.text),
        descriptionProductController.text.isNotEmpty ? descriptionProductController.text : '',
      );

      snackBarCustom(
        context,
        Colors.greenAccent.shade400,
        'Product Added Successfully',
        Colors.white,
      );
    } catch (error) {
      snackBarCustom(
        context,
        Colors.redAccent.shade400,
        'Failed to add product',
        Colors.white,
      );
    } finally {
      hideLoading(context);
    }
    Navigator.pop(context);
  }

  FocusNode fieldNameProduct = FocusNode();
  FocusNode fieldPriceProduct = FocusNode();
  FocusNode fieldStockProduct = FocusNode();
  FocusNode fieldCategoryProduct = FocusNode();
  FocusNode fieldDescProduct = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 2,
        title: const Text('Add Product'),
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            height: 200,
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
                                : Image.asset(
                                    'assets/images/empty_image.png',
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
                            visualDensity: VisualDensity.comfortable,
                            padding: const EdgeInsets.all(15),
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              elevation: const WidgetStatePropertyAll(2),
                              shape: const WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10))),
                              ),
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
                                  title: 'Image Product',
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
                    const Gap(10),
                    FormFields(
                      prefixIcon: Iconsax.edit_2,
                      inputType: TextInputType.name,
                      controller: nameProductController,
                      hintText: 'Name Product',
                      tap: false,
                      maxLineBoolean: false,
                      textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                      focusNode: fieldNameProduct,
                      onFieldSubmit: (val) {
                        FocusScope.of(context).requestFocus(fieldPriceProduct);
                      },
                    ),
                    const Gap(10),
                    FormFields(
                      prefixIcon: Iconsax.dollar_square,
                      inputType: TextInputType.number,
                      controller: priceProductController,
                      hintText: 'Price Product',
                      tap: false,
                      maxLineBoolean: false,
                      textInputFormatter: CurrencyTextInputFormatter.currency(
                        locale: 'id',
                        symbol: '',
                        decimalDigits: 0,
                      ),
                      focusNode: fieldPriceProduct,
                      onFieldSubmit: (val) {
                        FocusScope.of(context).requestFocus(fieldCategoryProduct);
                      },
                    ),
                    const Gap(10),
                    FormFields(
                      prefixIcon: Iconsax.element_plus,
                      inputType: TextInputType.name,
                      controller: categoryProductController,
                      hintText: 'Category Product',
                      tap: false,
                      maxLineBoolean: false,
                      textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                      focusNode: fieldCategoryProduct,
                      onFieldSubmit: (val) {
                        FocusScope.of(context).requestFocus(fieldStockProduct);
                      },
                    ),
                    const Gap(10),
                    FormFields(
                      prefixIcon: Iconsax.folder_add,
                      inputType: TextInputType.number,
                      controller: stockProductController,
                      hintText: 'Stock Product',
                      tap: false,
                      maxLineBoolean: false,
                      textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                      focusNode: fieldStockProduct,
                      onFieldSubmit: (val) {
                        FocusScope.of(context).requestFocus(fieldDescProduct);
                      },
                    ),
                    const Gap(10),
                    FormFields(
                      prefixIcon: Iconsax.messages,
                      inputType: TextInputType.multiline,
                      controller: descriptionProductController,
                      hintText: 'Description Product',
                      tap: false,
                      maxLineBoolean: true,
                      textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                      focusNode: fieldDescProduct,
                      onFieldSubmit: (val) {
                        FocusScope.of(context).requestFocus();
                      },
                    ),
                  ],
                ),
                const Gap(20),
                ElevatedButton(
                  onPressed: () {
                    enterAddProduct();
                  },
                  style: ButtonStyle(
                    fixedSize: const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    elevation: const WidgetStatePropertyAll(3),
                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                  child: const Text(
                    'Add Product',
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
    );
  }
}
