import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firebaseData.dart';

class TripDialog extends StatelessWidget {
  List<RouteStep> _routeSteps;
  List<LatLng> _pointsList;
  int _distance;
  Duration _parsedDuration;
  MapWidget _mapWidget;

  final List<PlacesSearchResult> selectedPlaces;

  TripDialog({Key key, this.selectedPlaces}) : super(key: key);

  Future getMapWithNecessaryFields() async {
    _pointsList =
        selectedPlaces.map((p) => MapUtil.getLatLngLocationOfPlace(p)).toList();
    _routeSteps = await MapUtil.getRoute(_pointsList);
    _mapWidget = MapWidget(
      onMapCreated: (GoogleMapController controller) =>
          dialogOnMapCreatedFunction(controller, _routeSteps, _pointsList),
    );
    selectedPlaces.forEach((sp) => _mapWidget.markers.add(Marker(
          markerId: MarkerId(sp.placeId),
          position: MapUtil.getLatLngLocationOfPlace(sp),
        )));
    _distance = 0;
    var duration = 0;
    _routeSteps.forEach(
      (step) {
        _distance += step.distance;
        duration += step.durationInSeconds;
      },
    );
    _parsedDuration = Duration(seconds: duration);
  }

  @override
  Widget build(BuildContext context) {
    //TODO change tripDialog to normal widget and use navigator to open it
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: Text(
        "Create trip",
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              debugPrint('onCreate tapped');
              Database.push(Trip(
                      _routeSteps,
                      selectedPlaces
                          .map((p) => PlaceInfo(
                              p.geometry,
                              p.name,
                              p.placeId,
                              p.rating,
                              p.types,
                              p.vicinity,
                              p.formattedAddress))
                          .toList())
                  .toJson());
              Navigator.of(context).pop();
            },
            child: Text("Create")),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ],
      content: Container(
        child: FutureBuilder(
            future: getMapWithNecessaryFields(),
            builder: (context, async) {
              if (async.connectionState == ConnectionState.done) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 200,
                      child: _mapWidget,
                    ),
                    Text("Distance: $_distance metres"),
                    Text("Duration: ${printDuration(_parsedDuration)}"),
                    Flexible(
                      child: ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        shrinkWrap: true,
                        itemCount: selectedPlaces.length,
                        itemBuilder: (context, index) {
                          var place = selectedPlaces[index];
                          return RouteSpotInfo(
                            place: place,
                            index: index,
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else
                return Container(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Colors.lightBlue),
                            strokeWidth: 10.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
            }),
      ),
    );
  }

  void dialogOnMapCreatedFunction(GoogleMapController controller,
      List<RouteStep> routeSteps, List<LatLng> pointsList) {
    var placesLatLngList = selectedPlaces
        .map((searchResult) => MapUtil.getLatLngLocationOfPlace(searchResult))
        .toList();
    var bounds = LatLngBounds(
        southwest: MapUtil.getSouthwestPoint(placesLatLngList),
        northeast: MapUtil.getNorthEastPoint(placesLatLngList));
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 32.0));
  }
}

class RouteSpotInfo extends StatelessWidget {
  final PlacesSearchResult place;
  final int index;

  const RouteSpotInfo({Key key, this.place, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text("${index + 1}"),
        trailing: Text(
          place.name,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
