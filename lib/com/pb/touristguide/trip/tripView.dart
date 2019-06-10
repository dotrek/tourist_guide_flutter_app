import 'dart:async';

import 'package:duration/duration.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeDetail.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firestoreDatabase.dart';

enum TripViewMode { CREATE, UPDATE }

class TripView extends StatefulWidget {
  final Trip trip;
  MapWidget mapWidget;
  final TripViewMode tripViewMode;

  TripView({Key key, this.trip, this.tripViewMode}) : super(key: key);

  @override
  _TripViewState createState() => _TripViewState();
}

class _TripViewState extends State<TripView> {
  Completer<GoogleMapController> _mapController = Completer();
  GoogleMap _map;
  Set<Marker> markers = Set();
  Set<Polyline> polylines = Set();

  LatLngBounds _getBounds(List<PlaceInfo> places) {
    var placesLatLngList = places
        .map((place) => MapUtil.getLatLngLocationOfPlace(place.geometry))
        .toList();
    return LatLngBounds(
        southwest: MapUtil.getSouthwestPoint(placesLatLngList),
        northeast: MapUtil.getNorthEastPoint(placesLatLngList));
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() => _mapController.complete(controller));
    controller.moveCamera(
        CameraUpdate.newLatLngBounds(_getBounds(widget.trip.placesList), 32.0));
    _updateMap();
  }

  _addMarker(PlaceInfo place) {
    markers.add(
      Marker(
        markerId: MarkerId(place.placeId),
        infoWindow: InfoWindow(
            title: place.name,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlaceDetailWidget(
                          placeId: place.placeId,
                        )))),
        position: MapUtil.getLatLngLocationOfPlace(place.geometry),
      ),
    );
  }

  _updateMap() {
    //Add markers
    markers.clear();
    polylines.clear();
    widget.trip.placesList.forEach((sp) => _addMarker(sp));
    //add polyline
    List<LatLng> stepsList =
        widget.trip.routeSteps.map((step) => step.endLoc).toList();
    stepsList.insert(0, widget.trip.routeSteps.first.startLoc);
    polylines.add(Polyline(polylineId: PolylineId(""), points: stepsList));
  }

  @override
  Widget build(BuildContext context) {
    _map = GoogleMap(
      onMapCreated: _onMapCreated,
      myLocationEnabled: true,
      compassEnabled: true,
      initialCameraPosition: CameraPosition(
          target: MapUtil.getLatLngLocationOfPlace(
              widget.trip.placesList.first.geometry)),
      myLocationButtonEnabled: false,
      markers: markers,
      polylines: polylines,
    );
    Widget containerBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 200,
          child: _map,
        ),
        Column(
          children: <Widget>[
            Text("Distance: ${widget.trip.distance} metres"),
            Text(
                "Duration: ${printDuration(Duration(seconds: widget.trip.durationInSeconds))}"),
          ],
        )
      ],
    );
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          widget.tripViewMode == TripViewMode.UPDATE
              ? IconButton(
                  icon: Icon(Icons.done),
                  color: Colors.black,
                  onPressed: () {
                    widget.trip.isDone = true;
                    Database.updateTrip(widget.trip);
                    Navigator.of(context).pop();
                  })
              : Container(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.tripViewMode == TripViewMode.CREATE
          ? FloatingActionButton.extended(
              onPressed: () {
                debugPrint('onCreate tapped');
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return _TripNameDialog(
                        trip: widget.trip,
                      );
                    });
              },
              icon: Icon(Icons.add),
              label: Text("Create trip"))
          : Container(),
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

  Future onListReorder(int oldIndex, int newIndex) async {
    debugPrint("onListReorder called");
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = widget.trip.placesList.removeAt(oldIndex);
    widget.trip.placesList.insert(newIndex, item);
    updateTrip().then((value) => setState(() {
          _updateMap();
          if (widget.tripViewMode == TripViewMode.UPDATE) {
            Database.updateTrip(widget.trip);
          }
        }));
  }

  Future updateTrip() async {
    var _routeSteps = await MapUtil.getRoute(widget.trip.placesList
        .map((p) => MapUtil.getLatLngLocationOfPlace(p.geometry))
        .toList());
    var _distance = 0;
    var _durationInSeconds = 0;
    _routeSteps.forEach(
      (step) {
        _distance += step.distance;
        _durationInSeconds += step.durationInSeconds;
      },
    );
    widget.trip.routeSteps = _routeSteps;
    widget.trip.distance = _distance;
    widget.trip.durationInSeconds = _durationInSeconds;
  }
}

class _TripNameDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  static final _formKey = GlobalKey<FormFieldState>();

  final Trip trip;

  _TripNameDialog({Key key, this.trip}) : super(key: key);

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
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                trip.tripName = _formKey.currentState.value;
                Database.pushTrip(trip).then((pushed) {
                  _navigateToMainAndShowSnackbar(context);
                });
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
