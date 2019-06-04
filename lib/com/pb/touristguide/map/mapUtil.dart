import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/directions.dart';

class MapUtil {
  static Future<List<RouteStep>> getRoute(List<LatLng> placesList) async {
    var routes = await DirectionsRequest.getRoute(placesList);
    Map<String, dynamic> routeJson = jsonDecode(routes.body);
    List responseRoutesList = routeJson['routes'][0]['legs'];
    List responseSteps = responseRoutesList.map((res) => res['steps']).toList();
    List responseStepsExpanded = responseSteps.expand((x) => x).toList();
    var routesList = responseStepsExpanded
        .map((stepsTile) => RouteStep.fromJson(stepsTile))
        .toList();
    return routesList;
  }

  static Future<LatLng> getActualUserLocation() async {
    final location = LocationManager.Location();
    var currentUserLocation;
    try {
      currentUserLocation = await location.getLocation();
      LatLng latLng = LatLng(currentUserLocation.latitude, currentUserLocation.longitude);
      return latLng;
    } on Exception {
      return null;
    }
  }

  static LatLng getLatLngLocationOfPlace(Geometry geometry) {
    return LatLng(geometry.location.lat, geometry.location.lng);
  }

  static double getAverageLatitude(List<LatLng> pointsList) {
    double maxLat = double.negativeInfinity, minLat = double.maxFinite;
    pointsList.forEach((point) {
      debugPrint("Latitude: ${point.latitude}");
      maxLat = max(maxLat, point.latitude);
      minLat = min(minLat, point.latitude);
    });
    debugPrint("Max latitude: $maxLat");
    debugPrint("Min latitude: $minLat");
    var average = (maxLat + minLat) / 2;
    debugPrint("Average: $average");
    return average;
  }

  static double getAverageLongitude(List<LatLng> pointsList) {
    double maxLon = double.negativeInfinity, minLon = double.maxFinite;
    pointsList.forEach((point) {
      debugPrint("Longitude: ${point.longitude}");
      maxLon = max(maxLon, point.longitude);
      minLon = min(minLon, point.longitude);
    });
    debugPrint("Max longitude: $maxLon");
    debugPrint("Min longitude: $minLon");
    var average = (maxLon + minLon) / 2;
    debugPrint("Delta: $average");
    return average;
  }

  static LatLng getSouthwestPoint(List<LatLng> pointsList) {
    double minLat = double.maxFinite;
    double minLon = double.maxFinite;
    pointsList.forEach((point) {
      minLat = min(minLat, point.latitude);
      minLon = min(minLon, point.longitude);
    });
    return LatLng(minLat, minLon);
  }

  static LatLng getNorthEastPoint(List<LatLng> pointsList) {
    double maxLat = double.negativeInfinity;
    double maxLon = double.negativeInfinity;
    pointsList.forEach((point) {
      maxLat = max(maxLat, point.latitude);
      maxLon = max(maxLon, point.longitude);
    });
    return LatLng(maxLat, maxLon);
  }

  static void appendMarkersToMapView(
      GoogleMapController controller, List<PlacesSearchResult> placesList) {
    placesList.forEach((place) {
//      final markerOptions = MarkerOptions(
//          position: getLatLngLocationOfPlace(place),
//          infoWindowText: InfoWindowText(place.name, place.types?.first));
//      debugPrint(markerOptions.infoWindowText.title);
//      controller.addMarker(markerOptions);
    });
  }
}
