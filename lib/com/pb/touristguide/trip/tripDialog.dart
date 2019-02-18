import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';
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

  Future getMapWithNecessaryFields() async {
    _pointsList = selectedPlaces
        .map((p) => LatLng(p.geometry.location.lat, p.geometry.location.lng))
        .toList();
    var userLocation = await MapUtil.getActualUserLocation();
    _pointsList.insert(0, userLocation);
    _routeSteps = await MapUtil.getRoute(_pointsList);
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
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: Text(
        "Create trip",
        textAlign: TextAlign.center,
      ),
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
                      child: MapWidget(
                        onMapCreated: (GoogleMapController controller) {
                          dialogOnMapCreatedFunction(
                              controller, _routeSteps, _pointsList);
                        },
                      ),
                    ),
                    Text("Distance: $_distance"),
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
                    DialogButtons(
                      routeSteps: _routeSteps,
                    )
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

  Future dialogOnMapCreatedFunction(GoogleMapController controller,
      List<RouteStep> routeSteps, List<LatLng> pointsList) async {
    selectedPlaces.forEach(
      (pos) => controller.addMarker(
            MarkerOptions(
                position: LatLng(
                    pos.geometry.location.lat, pos.geometry.location.lng),
                alpha: 0.5,
                infoWindowText: InfoWindowText(pos.name, pos.types.first)),
          ),
    );
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
        20.0));
  }
}

class RouteSpotInfo extends StatelessWidget {
  final PlacesSearchResult place;
  final int index;

  const RouteSpotInfo({Key key, this.place, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade500,
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

class DialogButtons extends StatelessWidget {
  final List<RouteStep> routeSteps;

  const DialogButtons({Key key, this.routeSteps}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () {
              debugPrint('onCreate tapped');
              Database.push(Trip(
                      routeSteps,
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
            child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.lightGreenAccent,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(32.0))),
                child: Center(child: Text("Create"))),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              debugPrint("Cancelled");
              Navigator.of(context).pop();
            },
            child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(32.0))),
                child: Center(child: Text("Cancel"))),
          ),
        ),
      ],
    );
  }
}
