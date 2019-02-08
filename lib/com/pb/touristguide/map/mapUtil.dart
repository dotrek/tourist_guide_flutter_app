import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/directions.dart';

class MapUtil {

  static Future createRoute(GoogleMapController controller,
      List<PlacesSearchResult> placesList) async {
    controller.clearMarkers();
    var pointsList = placesList
        .map((PlacesSearchResult psr) =>
            LatLng(psr.geometry.location.lat, psr.geometry.location.lng))
        .toList();
    pointsList
        .forEach((pos) => controller.addMarker(MarkerOptions(position: pos)));
    var userLocation = await getActualUserLocation();
    pointsList.insert(0, userLocation);
    var routes = await DirectionsRequest.getRoute(pointsList);
    Map<String, dynamic> routeJson = jsonDecode(routes.body);
    List responseRoutesList = routeJson['routes'][0]['legs'];
    List responseSteps = responseRoutesList.map((res) => res['steps']).toList();
    List responseStepsExpanded = responseSteps.expand((x) => x).toList();
    var routesList = responseStepsExpanded
        .map((stepsTile) => RouteStep.fromJson(stepsTile))
        .toList();
    var polylinePoints =
        routesList.map((routeStep) => routeStep.endLoc).toList();
    polylinePoints.insert(0, routesList[0].startLoc);
    controller.addPolyline(PolylineOptions(points: polylinePoints));
  }

  static Future<LatLng> getActualUserLocation() async {
    final location = LocationManager.Location();
    var currentUserLocation;
    try {
      currentUserLocation = await location.getLocation();
      return LatLng(
          currentUserLocation["latitude"], currentUserLocation["longitude"]);
    } on Exception {
      return null;
    }
  }
}
