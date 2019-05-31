import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeDetail.dart';

class MapWidget extends StatefulWidget {
  Set<Marker> markers = Set();
  Set<Polyline> polylines = Set();
  final LatLngBounds latLngBounds;

  @override
  State createState() => MapWidgetState();

  MapWidget({Key key, this.latLngBounds}) : super(key: key);
}

class MapWidgetState extends State<MapWidget> {
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _mapCameraPosition = CameraPosition(target: LatLng(0.0, 0.0));

  @override
  Widget build(BuildContext context) {
    var map = GoogleMap(
      onMapCreated: _defaultOnMapCreated,
      myLocationEnabled: true,
      compassEnabled: true,
      initialCameraPosition: _mapCameraPosition,
      markers: widget.markers,
      polylines: widget.polylines,
    );
    return Container(child: map);
  }

  void _defaultOnMapCreated(GoogleMapController controller) {
    setState(() => _mapController.complete(controller));
    widget.latLngBounds == null
        ? animateToUserLocation()
        : animateToBounds(widget.latLngBounds);
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
    else
      c.animateCamera(u);
  }

  void animateToBounds(LatLngBounds bounds) async {
    final GoogleMapController controller = await _mapController.future;
    check(CameraUpdate.newLatLngBounds(bounds, 32.0), controller);
  }

  void animateToUserLocation() async {
    final location = await MapUtil.getActualUserLocation();
    if (location != null) {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 13.0),
        ),
      );
    }
  }

  void animateToLocation(LatLng southwest, LatLng northeast) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southwest, northeast: northeast), 32.0));
  }

  void addMarker(PlacesSearchResult psr) {
    setState(() {
      widget.markers.add(Marker(
        markerId: MarkerId(psr.id),
        infoWindow: InfoWindow(title: psr.name, onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>PlaceDetailWidget(placeId: psr.placeId,)))),
        position: MapUtil.getLatLngLocationOfPlace(psr.geometry),
      ));
    });
  }

  void addPolyline(Polyline polyline) {
    setState(() {
      widget.polylines.add(polyline);
    });
  }

  void clearPolylines() {
    setState(() {
      widget.polylines.clear();
    });
  }

  void clearMarkers() {
    setState(() {
      widget.markers.clear();
    });
  }
}
