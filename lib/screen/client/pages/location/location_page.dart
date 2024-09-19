import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';

import '../../../../services/models/model_product.dart';
import '../../../../services/models/model_weather.dart';
import '../../../../services/weather_service.dart';
import '../../../../services/models/model.dart';
import '../../../../services/map_service.dart';
import '../../../../widget/center_sheet.dart';
import '../../../../widget/tile.dart';
import '../../../../utils/utils.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({
    super.key,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final Completer<GoogleMapController> completer = Completer<GoogleMapController>();
  final CustomInfoWindowController customInfoWindowAdminsController = CustomInfoWindowController();

  final User currentUser = FirebaseAuth.instance.currentUser!;
  final ScrollController scrollController = ScrollController();
  final WeatherService weatherService = WeatherService();

  Weather? _weather;
  File? _imageFile;

  bool cardTapped = false;
  bool pressNear = false;
  bool radiusSlider = false;
  bool setLoading = false;

  double radiusValue = 2000.0;
  double radiusValueInKilometers = 0.0;

  double latitudeCurrent = 0.0;
  double longitudeCurrent = 0.0;

  String? addressLocation;
  String? subLocation;
  String? specAddressLocation;

  final Set<Circle> _circle = <Circle>{};
  final List<Marker> _markers = <Marker>[];

  late Future<List<MarkerAdmin>> futureMarkerAdminData;

  @override
  void initState() {
    super.initState();
    getLocationUser();
    futureMarkerAdminData = Future.value([]);
  }

  void moveToMarker(int index, List<MarkerAdmin> markerAdminList) {
    double itemWidth = 180.0 + 5.0;
    double viewportWidth = scrollController.position.viewportDimension;
    double totalWidth = itemWidth * markerAdminList.length;
    double targetPosition = index * itemWidth - (viewportWidth / 2) + (itemWidth / 2);

    if (targetPosition < 0) targetPosition = 0;
    if (targetPosition > totalWidth - viewportWidth) {
      targetPosition = totalWidth - viewportWidth;
    }

    scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void getLocationUser() async {
    setState(() {
      setLoading = true;
    });

    final Position position = await MapService().determinePosition(); //get position device

    debugPrint('Attempting to get current position...');
    debugPrint('Position obtained: $position');

    GoogleMapController controller = await completer.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          tilt: 85,
          zoom: 14,
        ),
      ),
    );

    final Uint8List markerUser =
        await MapService().getBytesFromAsset('assets/mapicons/users.png', 80);

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        visible: true,
        icon: BitmapDescriptor.fromBytes(markerUser),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(
          title: 'Current Location',
        ),
      ),
    );

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[3];

      setState(() {
        addressLocation = '${place.name}';
        subLocation = '${place.subLocality}';
        specAddressLocation = [
          place.subLocality ?? '',
          place.locality ?? '',
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode
        ]
            .where((element) => element != null && element.isNotEmpty)
            .join(', ')
            .replaceAll('Kecamatan', 'Kec.')
            .replaceAll('Kelurahan', 'Kel.')
            .replaceAll('Kabupaten', 'Kab.');
      });

      debugPrint('Address Location : $addressLocation');
      debugPrint('Specific Location : $specAddressLocation');
    } catch (e) {
      return Future.error(e);
    }

    setState(() {
      _markers;
      _circle;
      setLoading = false;
      latitudeCurrent = position.latitude;
      longitudeCurrent = position.longitude;
      getNearPlace(position);
      getWeatherData(position);

      futureMarkerAdminData = fetchMarkerAdminData(position);
    });
  }

  void getNearPlace(Position position) async {
    setState(() {
      pressNear = true;
      radiusSlider = false;
      setLoading = true;
    });

    try {
      _circle.clear();
      _circle.add(
        Circle(
          radius: radiusValue,
          circleId: const CircleId('circleId'),
          center: LatLng(position.latitude, position.longitude),
          fillColor: Theme.of(context).primaryColor.withOpacity(0.25),
          strokeColor: Theme.of(context).primaryColor.withOpacity(0.5),
          strokeWidth: 1,
          visible: true,
        ),
      );

      List<MarkerAdmin> markerAdminList = await fetchMarkerAdminDataFromFirestore();

      for (int i = 0; i < markerAdminList.length; i++) {
        final markerAdmin = markerAdminList[i];

        final Uint8List markerIcon =
            await MapService().getBytesFromAsset('assets/mapicons/food-court.png', 70);

        LatLng markerPosition = LatLng(markerAdmin.latitude, markerAdmin.longitude);

        if (isMarkerAdminInCircle(markerPosition, position)) {
          _markers.add(
            Marker(
              markerId: MarkerId(markerAdminList[i].codeUnique),
              position: LatLng(markerAdminList[i].latitude, markerAdminList[i].longitude),
              icon: BitmapDescriptor.fromBytes(markerIcon),
              visible: true,
              infoWindow: InfoWindow(
                title: markerAdminList[i].placeName,
              ),
              onTap: () {
                moveToMarker(i, markerAdminList);
              },
            ),
          );
        }
      }

      setState(() {
        pressNear = false;
        radiusSlider = true;
        setLoading = false;
        _markers;
        markerAdminList;
      });
    } catch (e) {
      if (e is TimeoutException) {
        infoFoodCourt('TimeoutException: ${e.message}');
        debugPrint('TimeoutException: ${e.message}');
      } else {
        debugPrint('Error: $e');
      }
    }
  }

  void getWeatherData(Position position) async {
    try {
      final weather = await weatherService.getWeather(position.latitude, position.longitude);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  bool isMarkerAdminInCircle(LatLng markerPosition, Position position) {
    for (Circle circle in _circle) {
      double distanceBetweenPoints = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        markerPosition.latitude,
        markerPosition.longitude,
      );
      if (distanceBetweenPoints <= circle.radius) {
        return true;
      } else if (distanceBetweenPoints >= circle.radius) {
        return false;
      } else {
        return false;
      }
    }
    return true;
  }

  Future<List<MarkerAdmin>> fetchMarkerAdminData(Position position) async {
    List<MarkerAdmin> markerAdminList = await fetchMarkerAdminDataFromFirestore();

    List<MarkerAdmin> filterMarkerAdminList = markerAdminList.where((markerAdmin) {
      LatLng markerPosition = LatLng(markerAdmin.latitude, markerAdmin.longitude);
      return isMarkerAdminInCircle(markerPosition, position);
    }).toList();
    return filterMarkerAdminList;
  }

  void infoFoodCourt(String? message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      scrollControlDisabledMaxHeightRatio: 1 / 3.5,
      isScrollControlled: false,
      enableDrag: false,
      useRootNavigator: false,
      showDragHandle: false,
      useSafeArea: true,
      isDismissible: false,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 0,
                          child: Icon(
                            CupertinoIcons.info_circle,
                            color: Colors.redAccent,
                            size: 45,
                          ),
                        ),
                        const Gap(15),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              const Text(
                                'There are no currently Available Locations',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                message!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
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
            ],
          ),
        );
      },
    );
  }

  Widget currentLocation(
    BuildContext context,
    String imageUser,
    String nameUser,
  ) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      child: Container(
        width: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                height: 60,
                width: 60,
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
                child: _imageFile != null
                    ? Image.file(
                        File(_imageFile!.path),
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUser,
                        filterQuality: FilterQuality.low,
                        fit: BoxFit.cover,
                        useOldImageOnUrlChange: true,
                        fadeInCurve: Curves.easeIn,
                        fadeOutCurve: Curves.easeOut,
                        fadeInDuration: const Duration(milliseconds: 500),
                        fadeOutDuration: const Duration(milliseconds: 750),
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
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    nameUser,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2.5),
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Icon(
                          Iconsax.location5,
                          size: 17,
                          color: Colors.redAccent.shade400,
                        ),
                      ),
                      const Gap(5),
                      Expanded(
                        child: setLoading
                            ? Shimmer.fromColors(
                                baseColor: Theme.of(context).colorScheme.onPrimary,
                                highlightColor: Theme.of(context).colorScheme.onSecondary,
                                direction: ShimmerDirection.ltr,
                                enabled: true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 15,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                                      ),
                                    ),
                                    const Gap(5),
                                    Container(
                                      height: 15,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Text(
                                '$specAddressLocation',
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getWeatherIcon(String? mainCondition, int timezone) {
    if (mainCondition == null) return 'assets/weathers/cloudy.svg';

    // Dapatkan waktu saat ini di UTC
    DateTime nowUtc = DateTime.now().toUtc();

    // Tambahkan offset timezone ke UTC untuk mendapatkan waktu lokal
    DateTime localTime = nowUtc.add(Duration(seconds: timezone));

    // Cek apakah waktu adalah siang atau malam
    bool isDaytime = localTime.hour >= 6 && localTime.hour < 18;

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return isDaytime
            ? 'assets/weathers/day/mostly_cloudy.svg'
            : 'assets/weathers/night/mostly_cloudy.svg';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return isDaytime
            ? 'assets/weathers/day/haze_fog_dust_smoke.svg'
            : 'assets/weathers/night/haze_fog_dust_smoke.svg';
      case 'rain':
      case 'shower rain':
        return isDaytime
            ? 'assets/weathers/day/scattered_showers.svg'
            : 'assets/weathers/night/scattered_showers.svg';
      case 'drizzle':
        return isDaytime ? 'assets/weathers/day/drizzle.svg' : 'assets/weathers/night/drizzle.svg';
      case 'thunderstorm':
        return isDaytime
            ? 'assets/weathers/day/isolated_scattered_thunderstorms.svg'
            : 'assets/weathers/night/isolated_scattered_thunderstorms.svg';
      case 'clear':
        return isDaytime ? 'assets/weathers/day/clear.svg' : 'assets/weathers/night/clear.svg';
      case 'wind':
        return isDaytime
            ? 'assets/weathers/day/windy_breezy.svg'
            : 'assets/weathers/night/windy_breezy.svg';
      default:
        return isDaytime
            ? 'assets/weathers/day/partly_cloudy.svg'
            : 'assets/weathers/night/partly_cloudy.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    double radiusValueInKilometers = radiusValue / 1000.0;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 0,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clients')
                    .doc(currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return currentLoad(context);
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final userData = snapshot.data!;
                  return currentLocation(
                    context,
                    userData['image'],
                    userData['username'],
                  );
                },
              ),
            ),
            const Gap(10),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.outline, width: 0.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(latitudeCurrent, longitudeCurrent),
                                  tilt: 60,
                                  zoom: 14,
                                ),
                                myLocationEnabled: false,
                                trafficEnabled: false,
                                compassEnabled: false,
                                mapToolbarEnabled: false,
                                buildingsEnabled: true,
                                circles: _circle,
                                fortyFiveDegreeImageryEnabled: true,
                                rotateGesturesEnabled: false,
                                zoomGesturesEnabled: true,
                                minMaxZoomPreference: MinMaxZoomPreference.unbounded,
                                indoorViewEnabled: true,
                                zoomControlsEnabled: false,
                                style: Utils.mapStyleDark,
                                markers: Set<Marker>.of(_markers),
                                onTap: (argument) {
                                  customInfoWindowAdminsController.hideInfoWindow!();
                                },
                                onMapCreated: (GoogleMapController controller) {
                                  controller.getStyleError();
                                  completer.complete(controller);
                                  customInfoWindowAdminsController.googleMapController = controller;
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100)),
                                        child: IconButton(
                                          visualDensity: VisualDensity.standard,
                                          onPressed: () {
                                            setState(() {
                                              getLocationUser();
                                            });
                                          },
                                          icon: Icon(
                                            Icons.gps_fixed_rounded,
                                            size: 30,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          style: ButtonStyle(
                                            elevation: const WidgetStatePropertyAll(10),
                                            backgroundColor: WidgetStatePropertyAll(
                                              Theme.of(context).scaffoldBackgroundColor,
                                            ),
                                            padding:
                                                const WidgetStatePropertyAll(EdgeInsets.all(10)),
                                          ),
                                        ),
                                      ),
                                      const Gap(10),
                                      Expanded(
                                        flex: 4,
                                        child: Card(
                                          child: Container(
                                            height: 40,
                                            width: double.infinity,
                                            padding: const EdgeInsets.only(left: 15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(25),
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: radiusValueInKilometers
                                                            .toStringAsFixed(2),
                                                        style: TextStyle(
                                                          color: Theme.of(context).primaryColor,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: ' km',
                                                        style:
                                                            Theme.of(context).textTheme.bodySmall,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Slider.adaptive(
                                                    max: 3000.0,
                                                    min: 1500.0,
                                                    autofocus: true,
                                                    overlayColor: WidgetStatePropertyAll(
                                                        Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.25)),
                                                    inactiveColor:
                                                        Theme.of(context).colorScheme.outline,
                                                    activeColor: Theme.of(context).primaryColor,
                                                    value: radiusValue,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        radiusValue = newValue;
                                                        getLocationUser();
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(10),
                                  GestureDetector(
                                    onTap: () {
                                      debugPrint('Weather :');
                                      debugPrint('timezone : ${_weather?.timezone}');
                                      debugPrint('condition : ${_weather?.mainCondition}');
                                      debugPrint('wind speed : ${_weather?.windSpeed}');
                                      showWeatherInfo();
                                    },
                                    child: Card(
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.symmetric(horizontal: 7.5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(25),
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              getWeatherIcon(_weather?.mainCondition ?? '',
                                                  _weather?.timezone ?? 0),
                                              width: 20,
                                              height: 20,
                                            ),
                                            const Gap(2.5),
                                            Text(
                                              '${_weather?.feelsLike.round() ?? '0'}°',
                                              style: Theme.of(context).textTheme.titleSmall,
                                            ),
                                          ],
                                        ),
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
                  ),
                  const Gap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Text(
                      'Nearby Food Court',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Gap(5),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: FutureBuilder<List<MarkerAdmin>>(
                        future: futureMarkerAdminData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ListView.separated(
                              separatorBuilder: (context, index) => const SizedBox(width: 5),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return adminLoad(context);
                              },
                            );
                          }
                          if (snapshot.hasError) {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(child: Text('Error: ${snapshot.error}')),
                            );
                          }

                          List<MarkerAdmin> markerAdminList = snapshot.data as List<MarkerAdmin>;

                          return markerAdminList.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Theme.of(context).canvasColor,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Not Found.',
                                        style: Theme.of(context).textTheme.labelMedium,
                                      ),
                                      Text(
                                        'Nearby Food Court',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  controller: scrollController,
                                  separatorBuilder: (context, index) => const SizedBox(width: 5),
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: markerAdminList.length,
                                  itemBuilder: (context, index) {
                                    MarkerAdmin markerAdmin = markerAdminList[index];
                                    return TileFoodCourt(
                                      markerAdmin: markerAdmin,
                                      currentLat: latitudeCurrent,
                                      currentLng: longitudeCurrent,
                                    );
                                  },
                                );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showWeatherInfo() {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      useRootNavigator: true,
      traversalEdgeBehavior: TraversalEdgeBehavior.parentScope,
      barrierColor: Theme.of(context).colorScheme.tertiary,
      builder: (context) {
        return WeatherInfo(
          addressLocation: subLocation ?? addressLocation,
          weather: _weather,
          getWeatherIcon: getWeatherIcon,
        );
      },
    );
  }

  Widget currentLoad(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        width: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: [
            Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.onPrimary,
              highlightColor: Theme.of(context).colorScheme.onSecondary,
              direction: ShimmerDirection.ltr,
              enabled: true,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).primaryColor.withOpacity(0.5),
                    highlightColor: Theme.of(context).primaryColor.withOpacity(0.25),
                    direction: ShimmerDirection.ltr,
                    enabled: true,
                    child: Container(
                      height: 17,
                      width: 125,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.25),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  ),
                  const Gap(5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2.5),
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: const Icon(
                          Iconsax.location5,
                          size: 17,
                          color: Colors.redAccent,
                        ),
                      ),
                      const Gap(5),
                      Expanded(
                        child: Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.onPrimary,
                          highlightColor: Theme.of(context).colorScheme.onSecondary,
                          direction: ShimmerDirection.ltr,
                          enabled: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 15,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                              const Gap(5),
                              Container(
                                height: 15,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget adminLoad(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 180,
        height: double.infinity,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.onPrimary,
                highlightColor: Theme.of(context).colorScheme.onSecondary,
                direction: ShimmerDirection.ltr,
                enabled: true,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const Gap(5),
            Expanded(
              flex: 2,
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.onPrimary,
                highlightColor: Theme.of(context).colorScheme.onSecondary,
                direction: ShimmerDirection.ltr,
                enabled: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const Gap(4),
                    Container(
                      width: 80,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  highlightColor: Theme.of(context).primaryColor.withOpacity(0.25),
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Container(
                    width: 65,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.onPrimary,
                  highlightColor: Theme.of(context).colorScheme.onSecondary,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Container(
                    width: 50,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
