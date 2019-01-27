import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/mapWithPlaces.dart';
import 'package:location/location.dart' as LocationManager;

///This API Key will be used for both the interactive maps as well as the static maps.

const API_KEY = "***REMOVED***";
var mapsPlaces = GoogleMapsPlaces(apiKey: API_KEY);
var mapWidgetKey = new GlobalKey<MapWidgetState>();
var mainKey = new GlobalKey<ScaffoldState>();

String userLocationTitle = "Find places nearby";

final customTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  accentColor: Colors.greenAccent,
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

Future<LatLng> getActualUserLocation() async {
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

getLatLngLocationOfPlace(PlacesSearchResult place) {
  return LatLng(place.geometry.location.lat, place.geometry.location.lng);
}

void main() {
  runApp(MaterialApp(theme: customTheme, home: App()));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Widget actualWidget = MapsWithPlacesWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: mainKey,
        appBar: AppBar(
          title: Text(userLocationTitle),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("Lorem Ipsum"),
                accountEmail: Text("It dolore"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => actualWidget = MapsWithPlacesWidget());
                },
                title: Text("Nearby places"),
                leading: Icon(Icons.near_me),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    actualWidget = PlacesAutocompleteWidget(logo:Icon(Icons.place),apiKey: API_KEY);
                  });
                },
                title: Text("Other places"),
                leading: Icon(Icons.priority_high),
              ),
            ],
          ),
        ),
        body: actualWidget);
  }
}
