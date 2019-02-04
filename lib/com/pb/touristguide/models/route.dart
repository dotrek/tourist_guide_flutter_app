import 'package:google_maps_flutter/google_maps_flutter.dart';

class Route {
  final LatLng origin;
  final LatLng destination;
  final LatLng waypoints;
  Route(this.origin, this.destination, this.waypoints);
  Route.fromJson(Map<String, dynamic> json)
  : origin = json['origin'], destination=json['destination'], waypoints=json['waypoints'];
}