import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      _animateToUserLocation();
    });
  }

  void _animateToUserLocation() async {
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

  void addMarker(String id, LatLng latLng) async {
    setState(() {
      widget.markers.add(Marker(markerId: MarkerId(id), position: latLng));
    });
  }
}
