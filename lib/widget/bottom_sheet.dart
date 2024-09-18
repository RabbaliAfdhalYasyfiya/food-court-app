import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../services/map_service.dart';
import '../utils/utils.dart';
import 'button.dart';
import 'form.dart';

class BottomSheetPhoto extends StatelessWidget {
  const BottomSheetPhoto({
    super.key,
    required this.camera,
    required this.gallery,
    required this.delete,
    required this.title,
  });

  final GestureTapCallback camera, gallery, delete;
  final String title;

  Widget _buildButton(
    BuildContext context,
    String label,
    IconData icon,
    Color colors,
    GestureTapCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ButtonStyle(
            shadowColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
            overlayColor: WidgetStatePropertyAll(
              Theme.of(context).primaryColor.withOpacity(0.25),
            ),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primaryContainer),
            fixedSize: const WidgetStatePropertyAll(Size.square(70)),
            maximumSize: const WidgetStatePropertyAll(Size.square(60)),
            minimumSize: const WidgetStatePropertyAll(Size.square(0)),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
              ),
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: colors,
              size: 30,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(
        bottom: 15,
        top: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Icon(
              Icons.drag_handle_rounded,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Gap(10),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          Divider(
            thickness: 0.25,
            color: Theme.of(context).dividerColor,
            endIndent: 15,
            indent: 15,
          ),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton(
                    context,
                    'Camera',
                    Iconsax.camera5,
                    Theme.of(context).primaryColor,
                    camera,
                  ),
                  const Gap(25),
                  _buildButton(
                    context,
                    'Gallery',
                    Iconsax.gallery5,
                    Theme.of(context).primaryColor,
                    gallery,
                  ),
                ],
              ),
              _buildButton(
                context,
                'Delete',
                Iconsax.tag_cross5,
                Colors.redAccent,
                delete,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BottomSheetLocation extends StatefulWidget {
  const BottomSheetLocation({
    super.key,
    required this.controller,
    required this.lat,
    required this.lng,
  });

  final TextEditingController controller;
  final TextEditingController lat;
  final TextEditingController lng;

  @override
  State<BottomSheetLocation> createState() => _BottomSheetLocationState();
}

class _BottomSheetLocationState extends State<BottomSheetLocation> {
  final apiKey = 'AIzaSyBQ0CWDFFQ9qOjVOjtRZnExng95RS0QkNQ';
  final addressLocController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  final Set<Marker> marker = <Marker>{};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-7.740697249517362, 110.35192056953613),
    tilt: 0,
    zoom: 14,
  );

  final Completer<GoogleMapController> _completer = Completer<GoogleMapController>();

  void getCurrentLocation() async {
    Position position = await MapService().determinePosition();

    GoogleMapController controller = await _completer.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
          tilt: 0,
        ),
      ),
    );
  }

  void getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemark =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      Placemark place = placemark[1];

      setState(() {
        addressLocController.text =
            '${place.name}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea} ${place.postalCode}';
      });
    } catch (e) {
      return Future.error(e);
    }
  }

  void getLocation(LatLng latLng) async {
    getAddressFromLatLng(latLng);

    GoogleMapController controller = await _completer.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latLng.latitude, latLng.longitude),
          zoom: 17,
          tilt: 0,
        ),
      ),
    );

    marker.clear();

    final Uint8List markerUser =
        await MapService().getBytesFromAsset('assets/mapicons/pick.png', 70);
    Marker markers = Marker(
      markerId: const MarkerId('Pick Address'),
      position: LatLng(latLng.latitude, latLng.longitude),
      icon: BitmapDescriptor.fromBytes(markerUser),
    );

    marker.add(markers);

    setState(() {});

    latController.text = latLng.latitude.toString();
    lngController.text = latLng.longitude.toString();
  }

  FocusNode fieldLocation = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        verticalDirection: VerticalDirection.down,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                style: ButtonStyle(
                  shadowColor: const WidgetStatePropertyAll(Colors.black),
                  elevation: const WidgetStatePropertyAll(1),
                  backgroundColor:
                      WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      Icons.drag_handle_rounded,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Gap(15),
                  FormFields(
                    prefixIcon: Iconsax.location_tick,
                    inputType: TextInputType.streetAddress,
                    controller: addressLocController,
                    hintText: addressLocController.text.isNotEmpty
                        ? addressLocController.text
                        : 'Pick Location',
                    tap: true,
                    maxLineBoolean: false,
                    textInputFormatter: FilteringTextInputFormatter.singleLineFormatter,
                    focusNode: fieldLocation,
                    onFieldSubmit: (val) {},
                  ),
                  const Gap(10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black26, width: 0.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            GoogleMap(
                              myLocationButtonEnabled: true,
                              initialCameraPosition: _kGooglePlex,
                              myLocationEnabled: false,
                              compassEnabled: false,
                              trafficEnabled: false,
                              buildingsEnabled: false,
                              fortyFiveDegreeImageryEnabled: false,
                              rotateGesturesEnabled: false,
                              zoomGesturesEnabled: true,
                              zoomControlsEnabled: true,
                              indoorViewEnabled: false,
                              markers: Set<Marker>.of(marker),
                              onMapCreated: (GoogleMapController controller) {
                                controller.setMapStyle(Utils.mapStyleLight);
                                _completer.complete(controller);
                              },
                              onTap: (LatLng latLng) async {
                                getLocation(latLng);
                                debugPrint('Latitude: ${latLng.latitude}');
                                debugPrint('Longitude: ${latLng.longitude}');
                              },
                            ),
                            Positioned(
                              left: 10,
                              top: 10,
                              child: IconButton(
                                style: ButtonStyle(
                                  iconSize: const WidgetStatePropertyAll(30),
                                  shadowColor: const WidgetStatePropertyAll(Colors.black),
                                  elevation: const WidgetStatePropertyAll(1),
                                  backgroundColor: WidgetStatePropertyAll(
                                      Theme.of(context).scaffoldBackgroundColor),
                                ),
                                onPressed: () async {
                                  getCurrentLocation();
                                },
                                icon: Icon(
                                  Icons.gps_fixed_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(15),
                  ElevatedButton(
                    onPressed: () {
                      widget.controller.text = addressLocController.text;
                      widget.lat.text = latController.text;
                      widget.lng.text = lngController.text;
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
                      shadowColor: const WidgetStatePropertyAll(Colors.black),
                      backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 17),
                      ),
                    ),
                    child: const Text(
                      'Saved Address',
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
        ],
      ),
    );
  }
}

class BottomSheetInfo extends StatelessWidget {
  const BottomSheetInfo({
    super.key,
    required this.iconInfo,
    required this.colorIcon,
    required this.textInfo,
    required this.textButton,
    required this.colorButton,
    required this.onTap,
  });

  final IconData iconInfo;
  final Color colorIcon;
  final String textInfo;
  final String textButton;
  final Color colorButton;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Center(
                child: Icon(
                  Icons.drag_handle_rounded,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Icon(
                        iconInfo,
                        color: colorIcon,
                        size: 45,
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      flex: 2,
                      child: Text(
                        textInfo,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(15),
          Row(
            children: [
              Expanded(
                child: ButtonDelete(
                  text: textButton,
                  color: colorButton,
                  borderColor: colorButton,
                  textColor: Colors.white,
                  smallText: false,
                  onTap: onTap,
                ),
              ),
              const Gap(10),
              Expanded(
                child: ButtonDelete(
                  text: 'Cancel',
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).primaryColor,
                  smallText: false,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class BottomMenuInfo extends StatelessWidget {
  const BottomMenuInfo({
    super.key,
    required this.productId,
    required this.imageProduct,
    required this.nameProduct,
    required this.priceProduct,
    required this.categoryProduct,
    required this.descProduct,
    required this.onPressed,
  });

  final String productId;
  final String imageProduct;
  final String nameProduct;
  final String priceProduct;
  final String categoryProduct;
  final String descProduct;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        verticalDirection: VerticalDirection.down,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                style: ButtonStyle(
                  shadowColor: WidgetStatePropertyAll(Theme.of(context).shadowColor),
                  elevation: const WidgetStatePropertyAll(1),
                  backgroundColor:
                      WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Icon(
                      Icons.drag_handle_rounded,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: descProduct.isNotEmpty ? 4 : 6,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(17),
                              child: CachedNetworkImage(
                                imageUrl: imageProduct,
                                filterQuality: FilterQuality.low,
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.grey.shade400,
                                        strokeCap: StrokeCap.round,
                                      ),
                                    ),
                                  );
                                },
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
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.low,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        nameProduct,
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                    const Gap(5),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        border: Border.all(width: 1, color: Colors.grey.shade200),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Rp $priceProduct',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                Text(
                                  categoryProduct,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    height: 1,
                                  ),
                                ),
                                const Gap(5),
                                Visibility(
                                  visible: descProduct.isNotEmpty,
                                  child: Text(
                                    descProduct,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),
                  ElevatedButton.icon(
                    onPressed: onPressed,
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      elevation: const WidgetStatePropertyAll(3),
                      fixedSize: const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                      shadowColor: const WidgetStatePropertyAll(Colors.black),
                      backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 17),
                      ),
                    ),
                    icon: const Icon(
                      CupertinoIcons.heart,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Favorite',
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
        ],
      ),
    );
  }
}

class BottomEditCount extends StatefulWidget {
  const BottomEditCount({
    super.key,
    required this.imageProduct,
    required this.nameProduct,
    required this.quantity,
    required this.valuePrice,
    required this.index,
    required this.deleteProduct,
    required this.onSaveChanges,
  });

  final String imageProduct;
  final String nameProduct;
  final int quantity;
  final double valuePrice;
  final int index;
  final Function(int) deleteProduct;
  final Function(int, double) onSaveChanges;

  @override
  State<BottomEditCount> createState() => _BottomEditCountState();
}

class _BottomEditCountState extends State<BottomEditCount> {
  late int currentQuantity;
  late double unitPrice;
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    currentQuantity = widget.quantity;
    unitPrice = widget.valuePrice / widget.quantity;
    totalPrice = unitPrice * currentQuantity;
  }

  void decCount() {
    setState(() {
      if (currentQuantity > 0) {
        currentQuantity--;
        totalPrice = unitPrice * currentQuantity;
      }
    });
  }

  void incCount() {
    setState(() {
      currentQuantity++;
      totalPrice = unitPrice * currentQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        verticalDirection: VerticalDirection.down,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Visibility(
                //   visible: currentQuantity != 0,
                //   child: TextButton.icon(
                //     style: const ButtonStyle(
                //       shadowColor: WidgetStatePropertyAll(Colors.black),
                //       elevation: WidgetStatePropertyAll(0),
                //       backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
                //       visualDensity: VisualDensity.standard,
                //       shape: WidgetStatePropertyAll(
                //         RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                //       ),
                //     ),
                //     onPressed: () {
                //       Navigator.pop(context);
                //       widget.deleteProduct(widget.index);
                //     },
                //     label: const Text(
                //       'Delete',
                //       style: TextStyle(
                //         color: Colors.white,
                //       ),
                //     ),
                //     icon: const Icon(
                //       Iconsax.trash,
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
                const Gap(10),
                IconButton(
                  style: const ButtonStyle(
                    shadowColor: WidgetStatePropertyAll(Colors.black),
                    elevation: WidgetStatePropertyAll(1),
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    CupertinoIcons.xmark,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(
                      Icons.drag_handle_rounded,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Gap(15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: Container(
                                  height: double.infinity,
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
                                  child: CachedNetworkImage(
                                    imageUrl: widget.imageProduct,
                                    filterQuality: FilterQuality.low,
                                    fit: BoxFit.cover,
                                    useOldImageOnUrlChange: true,
                                    fadeInCurve: Curves.easeIn,
                                    fadeOutCurve: Curves.easeOut,
                                    fadeInDuration: const Duration(milliseconds: 500),
                                    fadeOutDuration: const Duration(milliseconds: 750),
                                  )
                                  //Image.network(e.imageProduct),
                                  ),
                            ),
                          ),
                          title: Text(
                            widget.nameProduct,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              height: 1.15,
                            ),
                          ),
                          visualDensity: VisualDensity.standard,
                          trailing: Text(
                            'Rp ${totalPrice == 0 ? '-' : NumberFormat('#,##0.000', 'id_ID').format(totalPrice).replaceAll(',', '.')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text('${currentQuantity}x'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                decCount();
                              },
                              icon: const Icon(CupertinoIcons.minus),
                              color: Colors.white,
                              style: ButtonStyle(
                                shape: const WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(10),
                                      left: Radius.circular(15),
                                    ),
                                  ),
                                ),
                                backgroundColor: WidgetStatePropertyAll(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade200,
                              ),
                              child: Center(
                                child: Text(
                                  '$currentQuantity',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                incCount();
                              },
                              icon: const Icon(CupertinoIcons.add),
                              color: Colors.white,
                              style: ButtonStyle(
                                shape: const WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(10),
                                      right: Radius.circular(15),
                                    ),
                                  ),
                                ),
                                backgroundColor: WidgetStatePropertyAll(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(25),
                  ElevatedButton(
                    onPressed: () {
                      if (currentQuantity == 0) {
                        Navigator.pop(context);
                        widget.deleteProduct(widget.index);
                      } else {
                        widget.onSaveChanges(currentQuantity, totalPrice);
                        Navigator.pop(context);
                      }
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      fixedSize: const WidgetStatePropertyAll(Size.fromWidth(double.maxFinite)),
                      elevation: const WidgetStatePropertyAll(1),
                      backgroundColor: WidgetStatePropertyAll(
                        currentQuantity == 0 ? Colors.redAccent : Theme.of(context).primaryColor,
                      ),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    child: Text(
                      currentQuantity == 0 ? 'Delete' : 'Save Changes',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
