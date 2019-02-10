import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/MainAppWidget.dart';
import 'package:tourist_guide/com/pb/touristguide/auth/baseAuth.dart';
import 'package:tourist_guide/com/pb/touristguide/auth/signInWidget.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/mapWithPlaces.dart';

///This API Key will be used for both the interactive maps as well as the static maps.

const API_KEY = "***REMOVED***";
var mapsPlaces = GoogleMapsPlaces(apiKey: API_KEY);
var mapWidgetKey = new GlobalKey<MapWidgetState>();
var mainKey = new GlobalKey<ScaffoldState>();
var userLoginKey = new GlobalKey<SignInWidgetState>();
List<PlacesSearchResult> selectedPlaces = List<PlacesSearchResult>();
List<Route> routes = List<Route>();
bool floatingVisibility = false;
String userLocationTitle = "Find places nearby";

void main() {
  runApp(MaterialApp(
    theme: customTheme,
    home: MainAppWidget(actualWidget: MapsWithPlacesWidget(),),
  ));
}

class LogInWidgetContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SignInWidget(
          auth: Auth(),
          onSignedIn: () =>
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return MainAppWidget(actualWidget: MapsWithPlacesWidget(),);
              }))),
    );
  }
}

final customTheme = ThemeData(
  primarySwatch: Colors.green,
  brightness: Brightness.dark,
  accentColor: Colors.green.shade900,
  primaryColor: Colors.green,
  dialogTheme: DialogTheme(
    backgroundColor: Colors.green.shade800,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45.0)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 12.50,
      horizontal: 10.00,
    ),
  ),
);



getLatLngLocationOfPlace(PlacesSearchResult place) {
  return LatLng(place.geometry.location.lat, place.geometry.location.lng);
}
