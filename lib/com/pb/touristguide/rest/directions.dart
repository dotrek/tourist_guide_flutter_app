import 'dart:async';

import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:tourist_guide/com/pb/touristguide/main.dart';
import 'package:flutter/material.dart';

class DirectionsRequest {
  static String _defaultUrl =
      "https://maps.googleapis.com/maps/api/directions/json?";

  static void getRoute(List<PlacesSearchResult> pointsList) async {
    String origin = _getLatLngString(pointsList.first);
    String destination = _getLatLngString(pointsList.last);
    String restOfWaypoints = "";
    pointsList.forEach((f) {
      if (f != pointsList.first && f != pointsList.last) {
        restOfWaypoints += _getLatLngString(f) + "|";
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
  }

  static Future<http.Response> _fetchPostWithWaypoints(
      String origin, String destination, String restOfWaypoints) async {
    return http.get(_defaultUrl +
        "origin=$origin&destination=$destination&waypoints=$restOfWaypoints&key=$API_KEY");
  }

  static Future<http.Response> _fetchPost(
      String origin, String destination) async {
    return http.get(
        _defaultUrl + "origin=$origin&destination=$destination&key=$API_KEY");
  }

  static String _getLatLngString(PlacesSearchResult place) {
    return "${place.geometry.location.lat},${place.geometry.location.lng}";
  }
}
