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

class TripView extends StatefulWidget {
  final List<PlacesSearchResult> selectedPlaces;

  TripView({Key key, this.selectedPlaces}) : super(key: key);

  @override
  _TripViewState createState() => _TripViewState();
}

class _TripViewState extends State<TripView> {
  List<RouteStep> _routeSteps;

  List<LatLng> _pointsList;

  int _distance = 0;

  int _durationInSeconds = 0;

  MapWidget _mapWidget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateMap();
  }

  void _updateMap() {
    _pointsList = widget.selectedPlaces
        .map((p) => MapUtil.getLatLngLocationOfPlace(p))
        .toList();
    MapUtil.getRoute(_pointsList).then((steps) {
      setState(() {
        _routeSteps = steps;
        _mapWidget = MapWidget(
          onMapCreated: (GoogleMapController controller) =>
              onMapCreatedFunction(controller),
        );
        //Add markers
        widget.selectedPlaces.forEach((sp) => _mapWidget.markers.add(Marker(
            markerId: MarkerId(sp.placeId),
            position: MapUtil.getLatLngLocationOfPlace(sp),
            infoWindow: InfoWindow(title: sp.name))));
        //add polyline
        List<LatLng> stepsList = steps.map((step) => step.endLoc).toList();
        stepsList.insert(0, steps.first.startLoc);
        _mapWidget.polylines
            .add(Polyline(polylineId: PolylineId(""), points: stepsList));
        //get distance and duration
        _distance = 0;
        _durationInSeconds=0;
        steps.forEach(
          (step) {
            _distance += step.distance;
            _durationInSeconds += step.durationInSeconds;
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget containerBody = Column(
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
      ],
    );
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
                    selectedPlaces: widget.selectedPlaces,
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
                  children: widget.selectedPlaces
                      .map((p) => RouteSpotInfo(
                            key: Key(
                                widget.selectedPlaces.indexOf(p).toString()),
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

  void onMapCreatedFunction(GoogleMapController controller) {
    var placesLatLngList = widget.selectedPlaces
        .map((searchResult) => MapUtil.getLatLngLocationOfPlace(searchResult))
        .toList();
    var bounds = LatLngBounds(
        southwest: MapUtil.getSouthwestPoint(placesLatLngList),
        northeast: MapUtil.getNorthEastPoint(placesLatLngList));
    controller.moveCamera(CameraUpdate.newLatLngBounds(bounds, 32.0));
  }

  void onListReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = widget.selectedPlaces.removeAt(oldIndex);
      widget.selectedPlaces.insert(newIndex, item);
      _updateMap();
    });
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
                                p.photos
                                    .map((photo) => photo.photoReference)
                                    .toList()))
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
