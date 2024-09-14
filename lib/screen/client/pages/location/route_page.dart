import 'package:flutter/material.dart';
import 'package:food_court_app/services/models/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('Current Location : ${widget.currentLat}, ${widget.currentLng}'),
            Text(
                'Destination Location : ${widget.markerAdmin.latitude}, ${widget.markerAdmin.longitude}'),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.currentLat, widget.currentLng),
                  tilt: 60,
                  zoom: 14,
                ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
