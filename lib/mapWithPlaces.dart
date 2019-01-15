import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/main.dart';
import 'package:tourist_guide/map.dart';
import 'package:tourist_guide/placesList.dart';
import 'package:swipedetector/swipedetector.dart';

class MapsWithPlacesView extends StatefulWidget {
  @override
  State createState() => MapsWithPlacesViewState();
}

class MapsWithPlacesViewState extends State<MapsWithPlacesView> {
  var listViewVisibility = false;
  List<PlacesSearchResult> placesList = List();
  var mapWidgetKey = new GlobalKey<MapWidgetState>();

  @override
  Widget build(BuildContext context) {
    getNearbyPlaces();
    return SwipeDetector(
      onSwipeUp: makeVisible,
      onSwipeDown: makeInvisible,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          child: Column(
            children: [
              MapWidget(key: mapWidgetKey),
              Visibility(
                visible: listViewVisibility,
                child: Expanded(
                  child: PlacesListView(
                    places: placesList,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void makeInvisible() {
    setState(() {
      listViewVisibility = false;
      deleteMarkersFromMapView();
    });
  }

  void makeVisible() {
    getNearbyPlaces();
    setState(() {
      listViewVisibility = true;
      appendMarkersToMapView();
    });
  }

  void getNearbyPlaces() async {
    final location = await getUserLocation();
    final aquariums = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), 2500,
        type: "aquarium");
    final zoo = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), 2500,
        type: "zoo");
    final mosques = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), 2500,
        type: "mosque");
    final museums = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), 2500,
        type: "museum");
    final churches = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), 2500,
        type: "church");
    if (aquariums.status == "OK") {
      this.placesList.addAll(aquariums.results);
    }
    if (zoo.status == "OK") {
      this.placesList.addAll(zoo.results);
    }
    if (mosques.status == "OK") {
      this.placesList.addAll(mosques.results);
    }
    if (museums.status == "OK") {
      this.placesList.addAll(museums.results);
    }
    if (churches.status == "OK") {
      this.placesList.addAll(churches.results);
    }
  }

  void appendMarkersToMapView() {
    GoogleMapController controller = mapWidgetKey.currentState?.mapController;
    debugPrint(placesList.length.toString());
    placesList.forEach((place) {
      final markerOptions = MarkerOptions(
          position:
              LatLng(place.geometry.location.lat, place.geometry.location.lng),
          infoWindowText: InfoWindowText(place.name, place.types?.first));
      controller.addMarker(markerOptions);
    });
  }

  void deleteMarkersFromMapView() {
    GoogleMapController controller = mapWidgetKey.currentState?.mapController;
    controller.clearMarkers();
  }
}
