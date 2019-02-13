import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';

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
                          var placeLatLng = LatLng(place.geometry.location.lat,
                              place.geometry.location.lng);
//                          var indexForView = _routeSteps.indexOf(
//                              _routeSteps.firstWhere(
//                                  (step) => step.endLoc == placeLatLng));
                          return RouteSpotInfo(
                            place: place,
                            index: index,
                          );
                        },
                      ),
                    ),
                    DialogButtons(
                      onCreate: () => debugPrint("Created"),
                    )
                  ],
                );
              } else
                return Container(
                  width: 200,
                  height: 200,
                  child: SizedBox.fromSize(
                    size: Size(100, 100),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.lightBlue),
                      strokeWidth: 10.0,
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
        0.0));
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
        trailing: Text(place.name),
      ),
    );
  }
}

class DialogButtons extends StatelessWidget {
  final VoidCallback onCreate;

  const DialogButtons({Key key, this.onCreate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => onCreate,
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
