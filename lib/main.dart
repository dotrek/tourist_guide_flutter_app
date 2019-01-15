import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/mapWithPlaces.dart';
import 'package:location/location.dart' as LocationManager;

///This API Key will be used for both the interactive maps as well as the static maps.

const API_KEY = "***REMOVED***";
var mapsPlaces = GoogleMapsPlaces(apiKey: API_KEY);

final customTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  accentColor: Colors.redAccent,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.00)),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 12.50,
      horizontal: 10.00,
    ),
  ),
);

Future<LatLng> getUserLocation() async {
  final location = LocationManager.Location();
  var currentUserLocation;
  try {
    currentUserLocation = await location.getLocation();
    return LatLng(
        currentUserLocation["latitude"], currentUserLocation["longitude"]);
  } on Exception {
    return null;
  }
}

void main() {
  runApp(MaterialApp(
    theme: customTheme,
    home: Scaffold(
        appBar: AppBar(
          title: const Text('Tourist Guide'),
        ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("Lorem Ipsum"),
                accountEmail: Text("It dolore"),
              )
            ],
          ),
        ),
        body: MapsWithPlacesView()),
  ));
}
