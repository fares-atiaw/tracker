import 'dart:async';

import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    getUserLocation();

    location.changeSettings(distanceFilter: 1);
    locationListener = location.onLocationChanged.listen((currentLocation) {
      locationData = currentLocation;
      print(
          '${x++} ,,, ${locationData?.altitude} and ${locationData?.longitude}');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Location'),
      ),
    );
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
    // TODO: implement dispose
    super.dispose();
    locationListener?.cancel();
  }
}
