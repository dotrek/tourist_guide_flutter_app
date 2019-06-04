import 'package:duration/duration.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
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
  @override
  void initState() {
    super.initState();
    _updateMap();
  }

  _updateMap() {
    //Add markers
    widget.trip.placesList.forEach((sp) => widget.mapWidget.markers.add(Marker(
        markerId: MarkerId(sp.placeId),
        position: MapUtil.getLatLngLocationOfPlace(sp.geometry),
        infoWindow: InfoWindow(title: sp.name))));
    //add polyline
    List<LatLng> stepsList =
        widget.trip.routeSteps.map((step) => step.endLoc).toList();
    stepsList.insert(0, widget.trip.routeSteps.first.startLoc);
    widget.mapWidget.polylines
        .add(Polyline(polylineId: PolylineId(""), points: stepsList));
  }

  @override
  Widget build(BuildContext context) {
    Widget containerBody = Column(
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
              Text("Distance: ${widget.trip.distance} metres"),
              Text(
                  "Duration: ${printDuration(Duration(seconds: widget.trip.durationInSeconds))}"),
            ],
          ),
        ),
      ],
    );
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
                    trip: widget.trip,
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

      mapWidgetKey.currentState.setState(() => _updateMap());
    });
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
