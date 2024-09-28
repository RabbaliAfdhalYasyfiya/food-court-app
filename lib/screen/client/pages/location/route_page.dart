import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../services/models/model.dart';
import '../../../../services/map_service.dart';
import '../../../../utils/utils.dart';

enum TransportMode { walking, driving }

class RoutePage extends StatefulWidget {
  const RoutePage({
    super.key,
    required this.markerAdmin,
    required this.currentLat,
    required this.currentLng,
  });

  final MarkerAdmin markerAdmin;
  final double currentLat;
  final double currentLng;

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final Completer<GoogleMapController> completer = Completer<GoogleMapController>();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polyline = <Polyline>{};
  TransportMode selectedMode = TransportMode.driving;
  String distance = '';
  String walkingDuration = "";
  String drivingDuration = "";
  List<LatLng> routePoints = []; // Simpan titik-titik dari polyline

  String? currentLoc;
  String? destinationLoc;

  Timer? movementTimer; // Timer untuk simulasi pergerakan

  @override
  void initState() {
    getCurrent();
    getDestination();
    drawPolyline();
    simulateMovement();
    drivingDuration = "0"; // Default in minutes
    walkingDuration = "0"; // Default in minutes
    distance = "0";
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      double threshold = 0.05; // Threshold untuk mendeteksi pergerakan
      if ((event.x.abs() > threshold || event.y.abs() > threshold || event.z.abs() > threshold)) {
        // Jika ada pergerakan, mulai simulasi
        simulateMovement();
      } else {
        // Jika tidak ada pergerakan, berhenti
        _stopMovement();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void getCurrent() async {
    final Uint8List markerUser =
        await MapService().getBytesFromAsset('assets/mapicons/navigate.png', 80);

    List<Placemark> placemark =
        await placemarkFromCoordinates(widget.currentLat, widget.currentLng);
    Placemark place = placemark[3];

    currentLoc = [
      place.name,
      place.subLocality ?? '',
      place.locality ?? '',
      place.subAdministrativeArea,
      place.administrativeArea,
      place.postalCode
    ]
        .where((element) => element != null && element.isNotEmpty)
        .join(', ')
        .replaceAll('Jalan', 'Jl.')
        .replaceAll('Kecamatan', 'Kec.')
        .replaceAll('Kelurahan', 'Kel.')
        .replaceAll('Kabupaten', 'Kab.');

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          visible: true,
          flat: true,
          icon: BitmapDescriptor.fromBytes(markerUser),
          position: LatLng(widget.currentLat, widget.currentLng),
          infoWindow: const InfoWindow(
            title: 'Current Location',
          ),
        ),
      );
    });
  }

  void getDestination() async {
    final Uint8List markerAdmin =
        await MapService().getBytesFromAsset('assets/mapicons/food-court.png', 80);

    destinationLoc = [widget.markerAdmin.addressPlace]
        .where((element) => element.isNotEmpty)
        .join(', ')
        .replaceAll('Jalan', 'Jl.')
        .replaceAll('Kecamatan', 'Kec.')
        .replaceAll('Kelurahan', 'Kel.')
        .replaceAll('Kabupaten', 'Kab.');

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('destinationLocation'),
          visible: true,
          icon: BitmapDescriptor.fromBytes(markerAdmin),
          position: LatLng(widget.markerAdmin.latitude, widget.markerAdmin.longitude),
          infoWindow: InfoWindow(
            title: widget.markerAdmin.placeName,
          ),
        ),
      );
    });
  }

  void drawPolyline() async {
    const String baseUrl = "http://router.project-osrm.org/route/v1";
    final String mode = selectedMode == TransportMode.walking ? 'walking' : 'driving';
    final String url = "$baseUrl/$mode/"
        "${widget.currentLng},${widget.currentLat};"
        "${widget.markerAdmin.longitude},${widget.markerAdmin.latitude}?overview=full";

    debugPrint("Requesting route with mode: $mode, URL: $url");

    try {
      // Fetch the response
      final http.Response response = await http.get(Uri.parse(url));
      debugPrint("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Check if the response contains routes
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          setState(() {
            _processPolyline(data['routes'][0]['geometry']);
            _updateDistanceAndDuration(
                data['routes'][0]['distance'], data['routes'][0]['duration']);
          });
        } else {
          debugPrint("No routes found in the response.");
        }
      } else {
        debugPrint("Failed request with status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("An error occurred while drawing the polyline: $e");
    }
  }

// Helper function to process polyline and update state
  void _processPolyline(String encodedPolyline) {
    final PolylinePoints polylinePoints = PolylinePoints();
    final List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPolyline);

    setState(() {
      debugPrint("Route Points: $routePoints");
      routePoints = decodedPoints.map((point) => LatLng(point.latitude, point.longitude)).toList();
      _polyline.clear(); // Clear any existing polylines
      _polyline.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Theme.of(context).primaryColor,
          width: selectedMode == TransportMode.walking ? 10 : 7,
          geodesic: true,
          points: routePoints,
          patterns: selectedMode == TransportMode.walking
              ? [PatternItem.dot, PatternItem.gap(15)] // Dashed for walking
              : [],
        ),
      );
    });
  }

// Helper function to update distance and duration
  void _updateDistanceAndDuration(double distanceMeters, double durationSeconds) {
    // Convert meters to kilometers
    double distanceKm = distanceMeters / 1000;

    double walkingSpeed = 5; // km/h
    double drivingSpeed = 60; // km/h

    String walkingDurationStr = (distanceKm / walkingSpeed * 60).toStringAsFixed(0);
    String drivingDurationStr = (distanceKm / drivingSpeed * 60).toStringAsFixed(0);

    setState(() {
      distance = distanceKm.toStringAsFixed(1); // Update distance in kilometers

      // Update the appropriate duration based on the selected transport mode
      if (selectedMode == TransportMode.walking) {
        walkingDuration = walkingDurationStr; // Set walking duration
      } else {
        drivingDuration = drivingDurationStr; // Set driving duration
      }
    });

    debugPrint(
        "Distance: $distance km, Duration (walking): $walkingDuration min, Duration (driving): $drivingDuration min");
  }

  LatLng calculateMidpoint(LatLng start, LatLng end) {
    double midLat = (start.latitude + end.latitude) / 2;
    double midLng = (start.longitude + end.longitude) / 2;
    return LatLng(midLat, midLng);
  }


  void simulateMovement() async {
    if (routePoints.isEmpty) return; // Pastikan ada rute untuk diikuti

    int currentIndex = 0; // Indeks awal dalam rute
    LatLng currentPosition = routePoints[currentIndex];

    final Uint8List markerUser =
        await MapService().getBytesFromAsset('assets/mapicons/navigate.png', 80);

    // Pastikan jika ada timer yang sedang berjalan, kita hentikan dulu
    movementTimer?.cancel();

    // Simulasi pergerakan pada setiap interval
    movementTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (currentIndex >= routePoints.length - 1) {
        timer.cancel(); // Berhenti jika mencapai akhir rute
        return;
      }

      // Pindah ke titik berikutnya dalam rute
      currentPosition = routePoints[++currentIndex];

      setState(() {
        _markers.removeWhere((m) => m.markerId.value == 'currentLocation');
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentPosition,
            icon: BitmapDescriptor.fromBytes(markerUser),
            infoWindow: const InfoWindow(title: 'Current Location'),
          ),
        );
      });
    });
  }

  void _stopMovement() {
    // Hentikan timer pergerakan jika ada
    if (movementTimer != null && movementTimer!.isActive) {
      movementTimer?.cancel();
      debugPrint('Movement stopped');
    }
  }

  void onModeSelected(TransportMode mode) {
    setState(() {
      selectedMode = mode;
      drawPolyline(); // Redraw polyline with selected mode
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    LatLng currentLocation = LatLng(widget.currentLat, widget.currentLng);
    LatLng destinationLocation = LatLng(widget.markerAdmin.latitude, widget.markerAdmin.longitude);
    LatLng midpoint = calculateMidpoint(currentLocation, destinationLocation);

    return Scaffold(
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
        title: const Text('Route'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(
                                  'assets/mapicons/navigate.png',
                                  filterQuality: FilterQuality.low,
                                  fit: BoxFit.cover,
                                  scale: 3,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Your Location',
                                maxLines: 1,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 2,
                        height: 5,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(
                                  'assets/mapicons/food-court.png',
                                  filterQuality: FilterQuality.low,
                                  fit: BoxFit.cover,
                                  scale: 3.5,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '$destinationLoc',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: midpoint,
                            tilt: 15,
                            zoom: 15,
                          ),
                          markers: _markers,
                          polylines: _polyline,
                          myLocationEnabled: false,
                          trafficEnabled: false,
                          compassEnabled: false,
                          mapToolbarEnabled: false,
                          buildingsEnabled: true,
                          fortyFiveDegreeImageryEnabled: true,
                          rotateGesturesEnabled: false,
                          zoomGesturesEnabled: true,
                          minMaxZoomPreference: MinMaxZoomPreference.unbounded,
                          indoorViewEnabled: true,
                          zoomControlsEnabled: false,
                          style: isDarkTheme ? Utils.mapStyleDark : Utils.mapStyleLight,
                          onMapCreated: (GoogleMapController controller) {
                            controller.getStyleError();
                            completer.complete(controller);
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 10,
                      child: Card(
                        margin: EdgeInsets.zero,
                        shadowColor: Theme.of(context).shadowColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          visualDensity: VisualDensity.standard,
                          onPressed: () async {
                            final GoogleMapController controller = await completer.future;

                            // Posisi baru untuk mengarahkan kamera, bisa mengganti `midpoint` dengan lokasi pengguna
                            LatLng newPosition = midpoint;

                            // Perbarui posisi kamera ke lokasi baru
                            controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: newPosition, // Titik tujuan baru
                                  tilt: 15,
                                  zoom: 15,
                                ),
                              ),
                            );
                            setState(() {});
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
                            padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        label: Text(
                          '$drivingDuration mnt',
                          style: TextStyle(
                            color: selectedMode == TransportMode.driving
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            onModeSelected(TransportMode.driving);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedMode == TransportMode.driving
                              ? Theme.of(context).primaryColor
                              : Theme.of(context)
                                  .scaffoldBackgroundColor, // Change color if selected
                          side: BorderSide(
                            width: 1,
                            color: selectedMode == TransportMode.driving
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        icon: Icon(
                          Icons.drive_eta_rounded,
                          color: selectedMode == TransportMode.driving
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const Gap(10),
                      ElevatedButton.icon(
                        label: Text(
                          '$walkingDuration mnt',
                          style: TextStyle(
                            color: selectedMode == TransportMode.walking
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            onModeSelected(TransportMode.walking);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedMode == TransportMode.walking
                              ? Theme.of(context).primaryColor
                              : Theme.of(context)
                                  .scaffoldBackgroundColor, // Change color if selected
                          side: BorderSide(
                            width: 1,
                            color: selectedMode == TransportMode.walking
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        icon: Icon(
                          Icons.directions_walk_outlined,
                          color: selectedMode == TransportMode.walking
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$distance km',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}
