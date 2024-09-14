import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../services/map_service.dart';
import '../../../../services/models/model.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/button.dart';
import '../../../../widget/tabbar.dart';
import 'food_court/food_court_page.dart';

class RutePage extends StatefulWidget {
  final MarkerAdmin markerAdmin;
  const RutePage({
    super.key,
    required this.markerAdmin,
  });

  @override
  State<RutePage> createState() => _RutePageState();
}

class _RutePageState extends State<RutePage> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> completer = Completer<GoogleMapController>();

  static const CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(-7.740697249517362, 110.35192056953613),
    tilt: 60,
    zoom: 14,
  );

  late final TabController tabController;

  int currentIndex = 0;
  final List<Tab> tabs = [
    Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.motorcycle_rounded,
          ),
        ),
      ),
    ),
    Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.directions_walk_rounded,
          ),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(handleTabSelection);
    getLocationUser();
    handleTabSelection();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  String motorTimeText = '';
  String walkingTimeText = '';

  void handleTabSelection() async {
    setState(() {
      currentIndex = tabController.index;
      setLoading = true;
    });

    double convertDistanceToTime(double distance, double speed) {
      return distance / speed * 60;
    }

    double walkingSpeed = 3;
    double motorSpeed = 17.5;

    switch (currentIndex) {
      case 0:
        double motorTime = convertDistanceToTime(widget.markerAdmin.distance, motorSpeed);
        motorTimeText = motorTime.toStringAsFixed(0);
        break;
      case 1:
        double walkingTime = convertDistanceToTime(widget.markerAdmin.distance, walkingSpeed);
        walkingTimeText = walkingTime.toStringAsFixed(0);
        break;
      default:
        break;
    }

    setState(() {
      setLoading = false;
    });
  }

  bool setLoading = false;

  List<LatLng> polylineCoordinates = [];

  void getLocationUser() async {
    setState(() {
      setLoading = true;
    });

    Position position = await MapService().determinePosition();

    PolylinePoints polylinePoints = PolylinePoints();

    GoogleMapController controller = await completer.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
          tilt: 0,
        ),
      ),
    );

    _marker.clear();

    final Uint8List markerIcon =
        await MapService().getBytesFromAsset('assets/mapicons/navigate.png', 70);
    _marker.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        flat: true,
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        infoWindow: const InfoWindow(
          title: 'My Current Location',
        ),
      ),
    );

    final Uint8List markerPlaceIcon =
        await MapService().getBytesFromAsset('assets/mapicons/restaurants.png', 70);
    _marker.add(
      Marker(
        markerId: const MarkerId('placeLocation'),
        flat: false,
        position: LatLng(widget.markerAdmin.latitude, widget.markerAdmin.longitude),
        icon: BitmapDescriptor.fromBytes(markerPlaceIcon),
        infoWindow: InfoWindow(
          title: widget.markerAdmin.placeName,
          //snippet: '${widget.markers.rating} rating',
        ),
      ),
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: PolylineRequest(
        origin: PointLatLng(position.latitude, position.longitude),
        destination: PointLatLng(widget.markerAdmin.latitude, widget.markerAdmin.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    } else {
      debugPrint(result.errorMessage);
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    debugPrint(totalDistance.toString());

    setState(() {
      setLoading = false;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  List<LatLng>? routeCoords;

  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[], //line
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)], //dash
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)], //dot
    <PatternItem>[
      //dash-dot
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
  ];

  final Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  final Set<Marker> _marker = {};

  String apiKey = 'AIzaSyBQ0CWDFFQ9qOjVOjtRZnExng95RS0QkNQ';

  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height * 0.28;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            Navigator.pop(
              context,
              MaterialPageRoute(
                builder: (context) => FoodCourtPage(markerAdmin: widget.markerAdmin),
              ),
            );
          },
        ),
        titleSpacing: 2,
        title: const Text(
          'Rute',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          verticalDirection: VerticalDirection.up,
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: kGooglePlex,
                    myLocationEnabled: false,
                    compassEnabled: false,
                    trafficEnabled: false,
                    buildingsEnabled: false,
                    fortyFiveDegreeImageryEnabled: false,
                    rotateGesturesEnabled: false,
                    zoomGesturesEnabled: true,
                    indoorViewEnabled: true,
                    zoomControlsEnabled: false,
                    style: Utils.mapStyle,
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: polylineCoordinates,
                        color: Theme.of(context).primaryColor,
                      ),
                    },
                    //polylines: Set<Polyline>.of(polylines.values),
                    markers: Set<Marker>.of(_marker),
                    onMapCreated: (GoogleMapController gMController) {
                      gMController.getStyleError();
                      completer.complete(gMController);
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ButtonWithIcon(
                      text: 'Start',
                      icon: const Icon(
                        CupertinoIcons.location_circle_fill,
                        color: Colors.white,
                      ),
                      ontap: getLocationUser,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      onPressed: getLocationUser,
                      icon: Icon(
                        Icons.gps_fixed_rounded,
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                      style: const ButtonStyle(
                        elevation: WidgetStatePropertyAll(10),
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 0,
              child: ruteContain(sizeHeight, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget ruteContain(
    double sizeHeight,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black38),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white70,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Gap(15),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Image.asset(
                                'assets/mapicons/navigate.png',
                                height: 25,
                              ),
                            ),
                            const Gap(15),
                            !setLoading
                                ? Text(
                                    'Your Location',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : Container(
                                    height: 18,
                                    width: 125,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                          ],
                        ),
                        const Gap(5),
                        const Divider(
                          thickness: 1,
                          indent: 15,
                          endIndent: 15,
                          color: Colors.grey,
                        ),
                        const Gap(5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Gap(15),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Image.asset(
                                'assets/mapicons/restaurants.png',
                                height: 25,
                              ),
                            ),
                            const Gap(15),
                            Expanded(
                              child: !setLoading
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: SizedBox(
                                        height: 23,
                                        child: Text(
                                          widget.markerAdmin.addressPlace,
                                            style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Container(
                                        height: 18,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const Gap(15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(5),
          Row(
            children: [
              tabWithoutDivider(
                context,
                tabController,
                tabs,
              ),
              const Gap(15),
              Expanded(
                child: !setLoading
                    ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: currentIndex == 0 ? motorTimeText : walkingTimeText,
                              style: TextStyle(
                                fontSize: 17,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text: ' menit',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const Gap(2.5),
                          Container(
                            height: 18,
                            width: 45,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).primaryColor.withOpacity(0.25),
                ),
                child: !setLoading
                    ? Text(
                        '${widget.markerAdmin.distance.toStringAsFixed(2)} km'.replaceAll('.', ','),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
