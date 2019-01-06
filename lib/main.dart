import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

///This API Key will be used for both the interactive maps as well as the static maps.

const API_KEY = "***REMOVED***";

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Google Maps demo')),
      body: MapsDemo(),
    ),
  ));
}

class MapsDemo extends StatefulWidget {
  @override
  State createState() => MapsDemoState();
}

class MapsDemoState extends State<MapsDemo> {
  GoogleMapController mapController;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          options: GoogleMapOptions(
            myLocationEnabled: true,
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
