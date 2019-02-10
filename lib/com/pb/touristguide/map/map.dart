import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';

class MapWidget extends StatefulWidget {
  final Function onMapCreated;

  @override
  State createState() => MapWidgetState();

  MapWidget({Key key, this.onMapCreated}) : super(key: key);
}

class MapWidgetState extends State<MapWidget> {
  GoogleMapController mapController;

  CameraPosition _mapCameraPosition = CameraPosition(target: LatLng(0.0, 0.0));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Container(
        child: GoogleMap(
          onMapCreated: widget.onMapCreated == null
              ? _defaultOnMapCreated
              : widget.onMapCreated,
          minMaxZoomPreference: MinMaxZoomPreference(9, 13),
          myLocationEnabled: true,
          compassEnabled: true,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          initialCameraPosition: _mapCameraPosition,
        ),
      ),
    );
  }

  void _defaultOnMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _animateToUserLocation();
    });
  }

  void _animateToUserLocation() async {
    final location = await MapUtil.getActualUserLocation();
    if (location != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: location, zoom: 13.0)),
      );
    }
  }
}
