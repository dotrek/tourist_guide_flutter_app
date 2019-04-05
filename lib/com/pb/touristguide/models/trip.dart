import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';

class Trip {
  String key;
  String tripName;
  List<RouteStep> routeSteps;
  List<PlaceInfo> placesList;
  int distance;
  int durationInSeconds;
  bool isDone;

  Trip(this.tripName, this.distance, this.durationInSeconds, this.routeSteps,
      this.placesList, this.isDone);

  Map<String, dynamic> toJson() => {
        "tripName": tripName,
        "distance": distance,
        "durationInSeconds": durationInSeconds,
        "routeSteps": routeSteps.map((r) => r.toJson()).toList(),
        "placesList": placesList.map((p) => p.toJson()).toList(),
        "isDone": isDone
      };

  Trip.fromSnapshot(DataSnapshot snapshot) {
    tripName = snapshot.value['tripName'];
    distance = snapshot.value['distance'];
    durationInSeconds = snapshot.value['durationInSeconds'];
    List list = List.from(snapshot.value['routeSteps']);
    List plist = List.from(snapshot.value['placesList']);
    list.forEach((r) => debugPrint(r.toString()));
    plist.forEach((r) => debugPrint(r.toString()));
    routeSteps =
        list.map((r) => RouteStep.fromJson(r.cast<String, dynamic>())).toList();
    placesList = plist
        .map((p) => PlaceInfo.fromJson(p.cast<String, dynamic>()))
        .toList();
    isDone = snapshot.value['isDone'];
  }
}
