import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Location location = Location();
  late PermissionStatus _permissionGranted;
  late bool _serviceEnabled;
  LocationData? locationData;
  StreamSubscription<LocationData>? locationListener;
  int x = 0;

  Completer<GoogleMapController> _controller = Completer();
  late CameraPosition _kGooglePlex = CameraPosition(
    //The first place place by coordinates
    target: LatLng(5.0, 31.2367317),
    //target: LatLng(firstlatitude, firstlongitude),
    zoom: 14.4746,
  );
  late CameraPosition _RouteCenter = CameraPosition(
      //A place by coordinates
      bearing: 192.8334901395799, // camera side1
      target: LatLng(30.035749, 31.1990501),
      // target: LatLng(secondlatitude, secondlongitude),
      tilt: 59.440717697143555, // camera side2
      zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    location.changeSettings(distanceFilter: 1);
    locationListener = location.onLocationChanged.listen((currentLocation) {
      locationData = currentLocation;
      print(
          '${x++} ,,, ${locationData?.altitude} and ${locationData?.longitude}');
    });
    double def_alt = 5.0;
    double def_lng = 31.2367317;

    var userMarker =
        Marker(markerId: MarkerId('user'), position: LatLng(5.0, 31.2367317));
    var centerMarker = Marker(
        markerId: MarkerId('center'), position: LatLng(30.035749, 31.1990501));

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Location'),
      ),
      // body: MapSample(
      //     firstlatitude: locationData?.altitude??def_alt,
      //     firstlongitude: locationData?.longitude??def_lng,
      //     secondlatitude: 30.035749,
      //     secondlongitude: 31.1990501),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
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
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_RouteCenter));
  }

  Future<bool> isPermissionGranted() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print(
            'The user denied to give the app his location, so noting to do/show');
      }
    }
    return _permissionGranted == PermissionStatus.granted;
  }

  Future<bool> isGPSEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print('The user denied to enable the GPS, so noting to do/show');
      }
    }
    return _serviceEnabled;
  }

  void getUserLocation() async {
    bool permission = await isPermissionGranted();
    bool service = await isGPSEnabled();
    if (permission && service) {
      locationData = await location.getLocation();
      print('${locationData?.altitude} and ${locationData?.longitude}');
    }
  }

  @override
  void dispose() {
    // When the screen popped out
    super.dispose();
    locationListener?.cancel();
  }
}
