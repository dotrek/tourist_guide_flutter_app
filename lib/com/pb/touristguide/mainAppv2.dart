import 'package:flutter/material.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapView.dart';
import 'package:tourist_guide/com/pb/touristguide/places/favouritePlacesView.dart';
import 'package:tourist_guide/com/pb/touristguide/trip/userTrips.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<Widget> views = [UserTrips(), MapView(), FavouritePlacesView()];
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
                  icon: Icon(Icons.person), title: Text("Favourite places")),
            ],
          ),
          body: views[currentIndex]),
    );
  }
}
