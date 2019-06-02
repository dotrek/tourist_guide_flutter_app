import 'package:duration/duration.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firestoreDatabase.dart';
import 'package:tourist_guide/main.dart';

class TripView extends StatefulWidget {
  final Trip trip;
  MapWidget mapWidget;

  TripView({Key key, this.trip}) : super(key: key) {
    mapWidget = MapWidget(
      latLngBounds: getBounds(trip.placesList),
    );
  }

  @override
  _TripViewState createState() => _TripViewState();

  LatLngBounds getBounds(List<PlaceInfo> places) {
    var placesLatLngList = places
        .map((place) => MapUtil.getLatLngLocationOfPlace(place.geometry))
        .toList();
    return LatLngBounds(
        southwest: MapUtil.getSouthwestPoint(placesLatLngList),
        northeast: MapUtil.getNorthEastPoint(placesLatLngList));
  }
}

class _TripViewState extends State<TripView> {
  List<RouteStep> _routeSteps;

  List<LatLng> _pointsList;

  int _distance = 0;

  int _durationInSeconds = 0;

  @override
  void initState() {
    super.initState();
  }

  Future _updateMap() async {
    _pointsList = widget.trip.placesList
        .map((p) => MapUtil.getLatLngLocationOfPlace(p.geometry))
        .toList();
    _routeSteps = await MapUtil.getRoute(_pointsList);
    //Add markers
    widget.trip.placesList.forEach((sp) => widget.mapWidget.markers.add(Marker(
        markerId: MarkerId(sp.placeId),
        position: MapUtil.getLatLngLocationOfPlace(sp.geometry),
        infoWindow: InfoWindow(title: sp.name))));
    //add polyline
    List<LatLng> stepsList = _routeSteps.map((step) => step.endLoc).toList();
    stepsList.insert(0, _routeSteps.first.startLoc);
    widget.mapWidget.polylines
        .add(Polyline(polylineId: PolylineId(""), points: stepsList));
    //get distance and duration
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
        future: _updateMap(),
        builder: (context, async) {
          if (async.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 200,
                  child: widget.mapWidget,
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
              ],
            );
          } else
            return Center(
              child: Container(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    widget.mapWidget,
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.lightGreen),
                      strokeWidth: 10.0,
                    ),
                  ],
                ),
              ),
            );
        });
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.done),
              color: Colors.black,
              onPressed: () => widget.trip.isDone = true)
        ],
      ),
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
                    places: widget.trip.placesList,
                  );
                });
          },
          icon: Icon(Icons.add),
          label: Text("Create trip")),
      body: Container(
        child: Column(
          children: <Widget>[
            containerBody,
            Expanded(
              child: ReorderableListView(
                  children: widget.trip.placesList
                      .map((p) => RouteSpotInfo(
                            key: Key(
                                widget.trip.placesList.indexOf(p).toString()),
                            place: p,
                          ))
                      .toList(),
                  onReorder: onListReorder),
            )
          ],
        ),
      ),
    );
  }

  void onListReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = widget.trip.placesList.removeAt(oldIndex);
      widget.trip.placesList.insert(newIndex, item);
      widget.mapWidget.markers.clear();
      widget.mapWidget.polylines.clear();
      _updateMap();
    });
  }
}

class _TripNameDialog extends StatelessWidget {
  TextEditingController _controller = TextEditingController();
  static final _formKey = GlobalKey<FormFieldState>();

  final List<RouteStep> routeSteps;
  final List<PlaceInfo> places;
  final int distance;
  final int durationInSeconds;

  _TripNameDialog(
      {Key key,
      this.routeSteps,
      this.places,
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
        // ignore: missing_return
        validator: (value) {
          if (value.isEmpty) {
            return 'Trip name must not be empty';
          }
        },
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {
              var user = auth.getCurrentUser();
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Database.pushTrip(Trip(_controller.text, user, distance,
                        durationInSeconds, routeSteps, places, false))
                    .then((pushed) {});
                _navigateToMainAndShowSnackbar(context);
              }
            },
            child: Text("Confirm")),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ],
    );
  }

  _navigateToMainAndShowSnackbar(BuildContext context) async {
    Navigator.of(context).popUntil(ModalRoute.withName('/main'));
    Flushbar(
      title: "Trip succesfully created",
      message: "You can check all of your trips on 'My Trips' card",
      backgroundColor: Colors.lightGreen,
      duration: Duration(seconds: 3),
    ).show(context);
  }
}

class RouteSpotInfo extends StatelessWidget {
  final PlaceInfo place;

  const RouteSpotInfo({Key key, this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            place.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
