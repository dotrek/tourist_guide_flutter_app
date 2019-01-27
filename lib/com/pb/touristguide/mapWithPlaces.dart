import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placesList.dart';

class MapsWithPlacesWidget extends StatefulWidget {
  @override
  State createState() => MapsWithPlacesWidgetState();
}

class MapsWithPlacesWidgetState extends State<MapsWithPlacesWidget> {
  GoogleMapController controller = mapWidgetKey.currentState?.mapController;
  var listViewVisibility = false;
  List<PlacesSearchResult> placesList = List();
  double radius = 1000;

  @override
  void initState() {
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
    final location = await getActualUserLocation();
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
    if (zoo.isOkay) {
      this.placesList.addAll(zoo.results);
    }
    if (mosques.isOkay) {
      this.placesList.addAll(mosques.results);
    }
    if (museums.isOkay) {
      this.placesList.addAll(museums.results);
    }
    if (churches.isOkay) {
      this.placesList.addAll(churches.results);
    }
    if (aquariums.isOkay) {
      this.placesList.addAll(aquariums.results);
    }
    appendMarkersToMapView();
  }

  appendMarkersToMapView() {
    GoogleMapController controller = mapWidgetKey.currentState?.mapController;
    debugPrint(placesList.length.toString());
    placesList.forEach((place) {
      final markerOptions = MarkerOptions(
          position: getLatLngLocationOfPlace(place),
          infoWindowText: InfoWindowText(place.name, place.types?.first));
      controller.addMarker(markerOptions);
    });
  }

  void deleteMarkersFromMapView() {
    GoogleMapController controller = mapWidgetKey.currentState?.mapController;
    controller.clearMarkers();
  }
}
