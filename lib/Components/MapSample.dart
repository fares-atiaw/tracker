import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();

  Completer<GoogleMapController> _controller = Completer();
  late double firstlatitude;
  late double firstlongitude;
  late double secondlatitude;
  late double secondlongitude;

  MapSample(
      {required this.firstlatitude,
      required this.firstlongitude,
      required this.secondlatitude,
      required this.secondlongitude});
}

class MapSampleState extends State<MapSample> {
  late CameraPosition _kGooglePlex = CameraPosition(
    //The first place place by coordinates
    //target: LatLng(5.0, 31.2367317),
    target: LatLng(widget.firstlatitude, widget.firstlongitude),
    zoom: 14.4746,
  );
  late CameraPosition _RouteCenter = CameraPosition(
      //A place by coordinates
      bearing: 192.8334901395799, // camera side1
      //target: LatLng(30.035749,31.1990501),
      target: LatLng(widget.secondlatitude, widget.secondlongitude),
      tilt: 59.440717697143555, // camera side2
      zoom: 19.151926040649414);
  late var userMarker = Marker(
      markerId: MarkerId('user'),
      position: LatLng(widget.firstlatitude, widget.firstlongitude));
  late var centerMarker = Marker(
      markerId: MarkerId('center'),
      position: LatLng(widget.secondlatitude, widget.secondlongitude));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          widget._controller.complete(controller);
        },
        markers: {userMarker, centerMarker},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToRoute,
        label: const Text('To Route Academy!'),
        icon: const Icon(Icons.route),
      ),
    );
  }

  Future<void> _goToRoute() async {
    final GoogleMapController controller = await widget._controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_RouteCenter));
  }
}
