import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/mapWithPlaces.dart';
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';
import 'package:duration/duration.dart';

class MainAppWidget extends StatefulWidget {
  Widget actualWidget;
  FirebaseUser user;

  MainAppWidget({Key key, this.actualWidget, this.user}) : super(key: key);

  @override
  _MainAppWidgetState createState() => _MainAppWidgetState();
}

class _MainAppWidgetState extends State<MainAppWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: mainKey,
        appBar: AppBar(
          backgroundColor: Colors.green.shade900,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title: ImageIcon(
            Image.asset(
              'assets/appLogo.png',
              fit: BoxFit.cover,
            ).image,
            size: 200.0,
          ),
          centerTitle: true,
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
                  setState(() => widget.actualWidget = MapsWithPlacesWidget());
                },
                title: Text("Nearby places"),
                leading: Icon(Icons.near_me),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    widget.actualWidget = PlacesAutocompleteWidget(
                        logo: Icon(Icons.place), apiKey: API_KEY);
                  });
                },
                title: Text("Other places"),
                leading: Icon(Icons.priority_high),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _handleCreateRouteButton(context),
          child: Column(
            children: [
              Center(child: Icon(Icons.call_missed_outgoing)),
              Center(
                  child: Text("Create trip",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12.0,
                      ))),
            ],
          ),
        ),
        body: widget.actualWidget);
  }

  _handleCreateRouteButton(BuildContext context) {
    return selectedPlaces.isEmpty
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "List is empty",
                  style: Theme.of(context).textTheme.body1,
                ),
                content: Text(
                  "Select any places you would like to add to new route",
                  style: Theme.of(context).textTheme.caption,
                ),
              );
            })
        : _showRouteInfoDialog(context);
  }

  Future _showRouteInfoDialog(BuildContext context) async {
    var pointsList = selectedPlaces
        .map((p) => LatLng(p.geometry.location.lat, p.geometry.location.lng))
        .toList();
    var userLocation = await MapUtil.getActualUserLocation();
    pointsList.insert(0, userLocation);
    var routeSteps = await MapUtil.getRoute(pointsList);
    var distance = 0;
    var duration = 0;
    routeSteps.forEach(
      (step) {
        distance += step.distance;
        duration += step.durationInSeconds;
      },
    );
    var parsedDuration = Duration(seconds: duration);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Create trip",textAlign: TextAlign.center,),
            actions: <Widget>[
              FlatButton(
                onPressed: () => debugPrint("Created a trip"),
                child: Text("Create"),
              ),
              FlatButton(
                onPressed: () {
                  debugPrint("Cancelled");
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
            ],
            content: ListView(
              children: <Widget>[
                Container(
                  height: 200,
                  child: MapWidget(
                    onMapCreated: (GoogleMapController controller) {
                      dialogOnMapCreatedFunction(
                          controller, routeSteps, pointsList);
                    },
                  ),
                ),
                Text("Distance: $distance"),
                Text("Duration: ${printDuration(parsedDuration)}"),
              ],
            ),
          );
        });
  }

  Future dialogOnMapCreatedFunction(GoogleMapController controller,
      List<RouteStep> routeSteps, List<LatLng> pointsList) async {
    pointsList
        .forEach((pos) => controller.addMarker(MarkerOptions(position: pos)));
    var userLocation = await MapUtil.getActualUserLocation();
    pointsList.insert(0, userLocation);
    var polylinePoints =
        routeSteps.map((routeStep) => routeStep.endLoc).toList();
    polylinePoints.insert(0, routeSteps.first.startLoc);
    controller.addPolyline(PolylineOptions(points: polylinePoints));
    var placesLatLngList = selectedPlaces
        .map((searchResult) => LatLng(searchResult.geometry.location.lat,
            searchResult.geometry.location.lng))
        .toList();
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: MapUtil.getSouthwestPoint(placesLatLngList),
            northeast: MapUtil.getNorthEastPoint(placesLatLngList)),
        0.0));
  }
}
