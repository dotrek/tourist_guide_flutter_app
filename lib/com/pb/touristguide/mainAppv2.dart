import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapView.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placesList.dart';
import 'package:tourist_guide/com/pb/touristguide/trip/userTrips.dart';
import 'package:tourist_guide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<Widget> views = [UserTrips(), MapView(), UserTrips()];
  var currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => setState(() {
                  this.currentIndex = index;
                }),
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.polymer), title: Text("My Trips")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.map), title: Text("Map")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), title: Text("User info")),
            ],
          ),
          body: views[currentIndex]),
    );
  }
}
