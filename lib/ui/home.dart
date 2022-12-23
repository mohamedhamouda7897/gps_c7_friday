import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'Home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> markers = {};
  int markerId = 0;
  var defLat = 30.035863;
  var defLong = 31.1965055;
  static const CameraPosition _kLake = CameraPosition(
      bearing: 150.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 40.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
    Marker UserMarker = Marker(
      markerId: MarkerId('user_location'),
      position: LatLng(
          locationData?.latitude ?? defLat, locationData?.longitude ?? defLong),
    );
    markers.add(UserMarker);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: GoogleMap(
        onTap: (LatLng) {},
        onLongPress: (latlon) {
          Marker UserMarker =
              Marker(markerId: MarkerId('marker$markerId'), position: latlon);
          markers.add(UserMarker);
          markerId++;
        },
        mapType: MapType.hybrid,
        initialCameraPosition:
            CurrentLocationMap == null ? _kLake : CurrentLocationMap!,
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.gps_fixed),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(CurrentLocationMap!));
  }

  Location location = Location();

  late PermissionStatus permissionStatus;

  LocationData? locationData;
  StreamSubscription<LocationData>? streamSubscription;
  bool? serviceEnable;
  CameraPosition? CurrentLocationMap;

  void getCurrentLocation() async {
    bool service = await isServiceEnabled();
    if (service == false) return;
    bool permission = await isPermissionGranted();
    if (permission == false) return;

    locationData = await location.getLocation();
    print(
        "My Location ${locationData?.latitude} long:${locationData?.longitude}");

    streamSubscription = location.onLocationChanged.listen((event) {
      locationData = event;
      print(
          "My Location ${locationData?.latitude} long:${locationData?.longitude}");
      CurrentLocationMap = CameraPosition(
        target: LatLng(locationData!.latitude!, locationData!.longitude!),
        zoom: 14.4746,
      );
      updateUserMarker();
    });

//AIzaSyAFCgUZgnOz5NnRSwu5TsGh71wAlUVX55c
  }

  void updateUserMarker() async {
    print('route4');
    Marker UserMarker = Marker(
      markerId: MarkerId('user_location'),
      position: LatLng(
          locationData?.latitude ?? defLat, locationData?.longitude ?? defLong),
    );
    markers.add(UserMarker);
    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(CurrentLocationMap!));

    print('route');
    setState(() {});
  }

  Future<bool> isServiceEnabled() async {
    serviceEnable = await location.serviceEnabled(); // true
    if (serviceEnable == false) {
      serviceEnable = await location.requestService(); // false
      return serviceEnable!;
    } else {
      return serviceEnable!;
    }
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    } else {
      return permissionStatus == PermissionStatus.granted;
    }
  }
}
