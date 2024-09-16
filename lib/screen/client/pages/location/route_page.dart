import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:food_court_app/services/models/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../services/map_service.dart';
import '../../../../utils/utils.dart';

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

  final List<Marker> _markers = <Marker>[];

  @override
  void initState() {
    getCurrent();
    getDestination();
    super.initState();
  }

  void getCurrent() async {
    final Uint8List markerUser =
        await MapService().getBytesFromAsset('assets/mapicons/users.png', 80);

    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        visible: true,
        icon: BitmapDescriptor.fromBytes(markerUser),
        position: LatLng(widget.currentLat, widget.currentLng),
        infoWindow: const InfoWindow(
          title: 'Current Location',
        ),
      ),
    );
  }

  void getDestination() async {
    final Uint8List markerAdmin =
        await MapService().getBytesFromAsset('assets/mapicons/food-court.png', 80);

    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        visible: true,
        icon: BitmapDescriptor.fromBytes(markerAdmin),
        position: LatLng(widget.markerAdmin.latitude, widget.markerAdmin.longitude),
        infoWindow: const InfoWindow(
          title: 'Current Location',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    'Current Location : ${widget.currentLat}, ${widget.currentLng}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Destination Location : ${widget.markerAdmin.latitude}, ${widget.markerAdmin.longitude}',
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.currentLat, widget.currentLng),
                  tilt: 60,
                  zoom: 14,
                ),
                markers: Set<Marker>.of(_markers),
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
                style: Utils.mapStyle,
                onMapCreated: (GoogleMapController controller) {
                  controller.getStyleError();
                  completer.complete(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
