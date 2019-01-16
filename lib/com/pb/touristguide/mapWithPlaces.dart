import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placesList.dart';

class MapsWithPlacesView extends StatefulWidget {
  @override
  State createState() => MapsWithPlacesViewState();
}

class MapsWithPlacesViewState extends State<MapsWithPlacesView> {
  var listViewVisibility = false;
  List<PlacesSearchResult> placesList = List();
  var mapWidgetKey = new GlobalKey<MapWidgetState>();
  double radius = 1000;

  @override
  void initState() {
    getNearbyPlacesAndAppendMarkers(radius);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
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
                width: 100.0,
                alignment: Alignment.center,
                child: Text('${radius.toInt()}',
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
                max: 10000,
              ),
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

  void getNearbyPlacesAndAppendMarkers(double radius) async {
    final location = await getUserLocation();
    final aquariums = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), radius,
        type: "aquarium");
    final zoo = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), radius,
        type: "zoo");
    final mosques = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), radius,
        type: "mosque");
    final museums = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), radius,
        type: "museum");
    final churches = await mapsPlaces.searchNearbyWithRadius(
        Location(location.latitude, location.longitude), radius,
        type: "church");
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
    if (aquariums.status == "OK") {
      this.placesList.addAll(aquariums.results);
    }
    appendMarkersToMapView();
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
