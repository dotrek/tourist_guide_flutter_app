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
import 'package:tourist_guide/main.dart';

class TripView extends StatelessWidget {
  List<RouteStep> _routeSteps;
  List<LatLng> _pointsList;
  int _distance;
  int _durationInSeconds;
  MapWidget _mapWidget;

  final List<PlacesSearchResult> selectedPlaces;

  TripView({Key key, this.selectedPlaces}) : super(key: key);

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
    _durationInSeconds = 0;
    _routeSteps.forEach(
      (step) {
        _distance += step.distance;
        _durationInSeconds += step.durationInSeconds;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget containerBody = FutureBuilder(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text("Distance: $_distance metres"),
                      Text(
                          "Duration: ${printDuration(Duration(seconds: _durationInSeconds))}"),
                    ],
                  ),
                ),
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
            return Center(
              child: Container(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.lightGreen),
                  strokeWidth: 10.0,
                ),
              ),
            );
        });
    return Scaffold(
      appBar: AppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            debugPrint('onCreate tapped');
            showDialog(
                context: context,
                builder: (ctx) {
                  return _TripNameDialog(
                    distance: _distance,
                    durationInSeconds: _durationInSeconds,
                    routeSteps: _routeSteps,
                    selectedPlaces: selectedPlaces,
                  );
                });
          },
          icon: Icon(Icons.add),
          label: Text("Create trip")),
      body: Container(
        child: containerBody,
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
    controller.moveCamera(CameraUpdate.newLatLngBounds(bounds, 32.0));
  }
}

class _TripNameDialog extends StatelessWidget {
  TextEditingController _controller = TextEditingController();
  static final _formKey = GlobalKey<FormFieldState>();

  final List<RouteStep> routeSteps;
  final List<PlacesSearchResult> selectedPlaces;
  final int distance;
  final int durationInSeconds;

  _TripNameDialog(
      {Key key,
      this.routeSteps,
      this.selectedPlaces,
      this.distance,
      this.durationInSeconds})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Type trip name"),
      content: TextFormField(
        key: _formKey,
        controller: _controller,
        validator: (value) {
          if (value.isEmpty) {
            return 'Trip name must not be empty';
          }
        },
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Database.push(Trip(
                        _controller.text,
                        distance,
                        durationInSeconds,
                        routeSteps,
                        selectedPlaces
                            .map((p) => PlaceInfo(
                                p.geometry,
                                p.name,
                                p.placeId,
                                p.rating,
                                p.types,
                                p.vicinity,
                                p.formattedAddress,
                                p.photos.map((photo) => photo.photoReference).toList()))
                            .toList(),
                        false)
                    .toJson());
                mainKey.currentState.showSnackBar(SnackBar(
                  content: Row(
                    children: <Widget>[
                      Icon(Icons.check),
                      Padding(padding: EdgeInsets.all(8.0)),
                      Text("Trip created!"),
                    ],
                  ),
                  backgroundColor: Colors.lightGreen,
                  duration: Duration(seconds: 1),
                ));
                Navigator.popUntil(context, ModalRoute.withName('/main'));
              }
            },
            child: Text("Confirm")),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ],
    );
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
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
