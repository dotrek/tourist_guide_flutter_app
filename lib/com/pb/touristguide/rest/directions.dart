import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';
import 'package:tourist_guide/main.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsRequest {
  static String _defaultUrl =
      "https://maps.googleapis.com/maps/api/directions/json?";

  static Future<http.Response> getRoute(List<LatLng> pointsList) async {
    String origin = getLatLngString(pointsList.first);
    String destination = getLatLngString(pointsList.last);
    String restOfWaypoints = "";
    pointsList.forEach((f) {
      if (f != pointsList.first && f != pointsList.last) {
        restOfWaypoints += getLatLngString(f) + "|";
      }
    });
    if (restOfWaypoints.endsWith("|")) {
      restOfWaypoints = restOfWaypoints.substring(0, restOfWaypoints.length);
    }
    debugPrint("RestOfWaypoints = $restOfWaypoints");
    var response;
    if (restOfWaypoints.isEmpty) {
      response = await _fetchPost(origin, destination);
    } else {
      response =
          await _fetchPostWithWaypoints(origin, destination, restOfWaypoints);
    }
    return response;
  }

  static Future<http.Response> _fetchPostWithWaypoints(
      String origin, String destination, String restOfWaypoints) async {
    return http.get(_defaultUrl +
        "origin=$origin&destination=$destination&waypoints=$restOfWaypoints&mode=walking&key=$API_KEY");
  }

  static Future<http.Response> _fetchPost(
      String origin, String destination) async {
    return http.get(_defaultUrl +
        "origin=$origin&destination=$destination&mode=walking&key=$API_KEY");
  }

  static String getLatLngString(LatLng place) {
    return "${place.latitude},${place.longitude}";
  }

  static void openGoogleMapsApplication(Trip trip) async {
    String url = "https://www.google.com/maps/dir/?api=1&";
    List<LatLng> placeLocation = trip.placesList
        .map((place) => MapUtil.getLatLngLocationOfPlace(place.geometry))
        .toList();
    LatLng userLocation = await MapUtil.getActualUserLocation();
    String origin = getLatLngString(userLocation);
    String destination = getLatLngString(placeLocation.last);
    placeLocation.removeLast();
    String waypointsString = "";
    placeLocation.forEach((f) {
      if (f != placeLocation.last) {
        waypointsString += getLatLngString(f) + "|";
      }
    });
    if (waypointsString.endsWith("|")) {
      waypointsString = waypointsString.substring(0, waypointsString.length);
    }
    url = url + "origin=$origin&destination=$destination&waypoints=$waypointsString&travelmode=walking&dir_action=navigate";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint("Could not open google maps application");
    }
  }
}
