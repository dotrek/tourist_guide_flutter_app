import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/auth/baseAuth.dart';
import 'package:tourist_guide/com/pb/touristguide/auth/signInWidget.dart';
import 'package:tourist_guide/com/pb/touristguide/mainAppv2.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';

///This API Key will be used for both the interactive maps as well as the static maps.

var API_KEY = _getApiKey();

Future<String> _getApiKey() async {
  RemoteConfig remoteConfig = await RemoteConfig.instance;
  await remoteConfig.fetch(expiration: Duration(hours: 1));
  await remoteConfig.activateFetched();

  return remoteConfig.getValue('maps_key').asString();
}
var mapsPlaces = API_KEY.then((key) => GoogleMapsPlaces(apiKey: key));
var mapWidgetKey = new GlobalKey<MapWidgetState>();
var tripViewMapWidgetKey = new GlobalKey<MapWidgetState>();
var auth = Auth();
List<Route> routes = List<Route>();
bool floatingVisibility = false;
String userLocationTitle = "Find places nearby";

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false,
    routes: <String, WidgetBuilder>{
      '/main': (context) => MainApp(),
    },
    theme: customTheme,
    home: LogInWidgetContainer(),
  ));
}

class LogInWidgetContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SignInWidget(
          auth: auth,
          onSignedIn: () => Navigator.of(context).popAndPushNamed("/main")),
//      child: MainApp(),
    );
  }
}

final customTheme = ThemeData(
  brightness: Brightness.light,
  accentColor: Colors.lightGreen,
  primaryColor: Colors.lightGreen,
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
