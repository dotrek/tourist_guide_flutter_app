import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';

class MapWidget extends StatefulWidget {
  Set<Marker> markers = Set();

  @override
  State createState() => MapWidgetState();

  MapWidget({Key key}) : super(key: key);
}

class MapWidgetState extends State<MapWidget> {
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _mapCameraPosition = CameraPosition(target: LatLng(0.0, 0.0));

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        onMapCreated: (controller) => _defaultOnMapCreated(controller),
        myLocationEnabled: true,
        compassEnabled: true,
        initialCameraPosition: _mapCameraPosition,
        markers: widget.markers,
      ),
    );
  }

  void _defaultOnMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController.complete(controller);
      animateToUserLocation();
    });
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
        infoWindow: InfoWindow(title: psr.name),
        position: LatLng(psr.geometry.location.lat, psr.geometry.location.lng),
      ));
    });
  }

  void clearMarkers() {
    setState(() {
      widget.markers.clear();
    });
  }
}
