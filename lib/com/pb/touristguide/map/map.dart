import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';

class MapWidget extends StatefulWidget {
  @override
  State createState() => MapWidgetState();

  MapWidget({Key key}) : super(key: key);
}

class MapWidgetState extends State<MapWidget> {
  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Container(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            options: GoogleMapOptions(
              myLocationEnabled: true,
              compassEnabled: true,
              rotateGesturesEnabled: true,
            ),
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _animateToUserLocation();
    });
  }

  void _animateToUserLocation() async {
    final location = await getUserLocation();
    if (location != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: location, zoom: 12.0)),
      );
    }
  }
}
