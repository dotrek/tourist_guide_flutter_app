import 'dart:async';

import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeDetail.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firestoreDatabase.dart';
import 'package:tourist_guide/com/pb/touristguide/trips/tripNameDialog.dart';

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
    setState(() {
      _mapController.complete(controller);
      _updateMap(controller);
    });
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
                    builder: (context) => PlaceDetailView(
                          placeId: place.placeId,
                        )))),
        position: MapUtil.getLatLngLocationOfPlace(place.geometry),
      ),
    );
  }

  Future<List<RouteStep>> _updateMap([GoogleMapController controller]) async {
    //Add markers
    markers.clear();
    polylines.clear();
    widget.trip.placesList.forEach((sp) => _addMarker(sp));
    //add polyline
    List<RouteStep> routeSteps = await MapUtil.getRoute(widget.trip.placesList
        .map((place) => MapUtil.getLatLngLocationOfPlace(place.geometry))
        .toList());
    List<LatLng> stepsList = routeSteps.map((step) => step.endLoc).toList();
    stepsList.insert(0, routeSteps.first.startLoc);
    polylines.add(Polyline(polylineId: PolylineId(""), width: 5, points: stepsList));
    if (controller != null) {
      setState(() {
        controller.moveCamera(CameraUpdate.newLatLngBounds(
            _getBounds(widget.trip.placesList), 32.0));
      });
    }
    return routeSteps;
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
                      return TripNameDialog(
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
    widget.trip.placesList = PlaceUtil.reorderList(widget.trip.placesList);
    List<RouteStep> steps = await _updateMap();
    _updateTrip(steps);
    setState(() {
      if (widget.tripViewMode == TripViewMode.UPDATE) {
        Database.updateTrip(widget.trip);
      }
    });
  }

  _updateTrip(List<RouteStep> routeSteps) {
    var _distance = 0;
    var _durationInSeconds = 0;
    routeSteps.forEach(
      (step) {
        _distance += step.distance;
        _durationInSeconds += step.durationInSeconds;
      },
    );
    widget.trip.distance = _distance;
    widget.trip.durationInSeconds = _durationInSeconds;
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
