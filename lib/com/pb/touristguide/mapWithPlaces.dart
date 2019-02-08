import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placesList.dart';

class MapsWithPlacesWidget extends StatefulWidget {
  @override
  State createState() => MapsWithPlacesWidgetState();
}

class MapsWithPlacesWidgetState extends State<MapsWithPlacesWidget> {
  GoogleMapController controller;
  List<PlacesSearchResult> placesList = List();
  double radius = 1000;

  @override
  void initState() {
    controller= mapWidgetKey.currentState?.mapController;
    getNearbyPlacesAndAppendMarkers(radius);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionExtentRatio: 0.5,
      delegate: SlidableBehindDelegate(),
      key: ValueKey(1),
      direction: Axis.vertical,
      secondaryActions: <Widget>[
        SlideAction(
            child: PlacesListView(
          places: placesList,
        ))
      ],
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Container(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(radius.toInt().toString(),
                    style: Theme.of(context).textTheme.display1),
              ),
              Slider(
                activeColor: Colors.lightBlue,
                value: radius,
                onChanged: (newValue) {
                  deleteMarkersFromMapView();
                  setState(() {
                    radius = newValue;
                  });
                },
                onChangeEnd: (value) {
                  getNearbyPlacesAndAppendMarkers(value);
                },
                min: 100,
                max: 5000,
              ),
              MapWidget(key: mapWidgetKey),
            ],
          ),
        ),
      ),
    );
  }

  void getNearbyPlacesAndAppendMarkers(double radius) async {
    this.placesList.clear();
    var touristTypes = [
      "museum",
      "art_gallery",
      "city_hall",
      "park",
      "casino",
      "zoo",
      "church"
    ];
    debugPrint(touristTypes.join(", "));
    final location = await MapUtil.getActualUserLocation();
    var places = findPlaces(location, touristTypes);
    var pointsOfInterest = await places;
    pointsOfInterest.shuffle(Random.secure());
    placesList.addAll(pointsOfInterest);
    appendMarkersToMapView();
  }

  appendMarkersToMapView() {
    controller= mapWidgetKey.currentState?.mapController;
    debugPrint("Places found: ${placesList.length.toString()}");
    placesList.forEach((place) {
      final markerOptions = MarkerOptions(
          position: getLatLngLocationOfPlace(place),
          infoWindowText: InfoWindowText(place.name, place.types?.first));
      debugPrint(markerOptions.infoWindowText.title);
      controller.addMarker(markerOptions);
    });
  }

  void deleteMarkersFromMapView() {
    controller= mapWidgetKey.currentState?.mapController;
    controller.clearMarkers();
  }

  Future<List<PlacesSearchResult>> findPlaces(
      LatLng location, List<String> touristTypes) async {
    var result = List<PlacesSearchResult>();
    for (String type in touristTypes) {
      var places = await mapsPlaces.searchNearbyWithRadius(
          Location(location.latitude, location.longitude), radius,
          type: type);
      if (places.isOkay) {
        result.addAll(places.results);
      }
    }
    return result;
  }
}
