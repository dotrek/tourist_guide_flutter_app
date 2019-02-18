import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';

class Trip {
  String key;
  List<RouteStep> routeSteps;
  List<PlaceInfo> placesList;

  Trip(this.routeSteps, this.placesList);

  Map<String, dynamic> toJson() =>
      {"routeSteps": routeSteps.map((r)=>r.toJson()).toList(), "placesList": placesList.map((p)=>p.toJson()).toList()};

  Trip.fromSnapshot(DataSnapshot snapshot){
    List list = List.from(snapshot.value['routeSteps']);
    List plist = List.from(snapshot.value['placesList']);
    list.forEach((r)=>debugPrint(r.toString()));
    plist.forEach((r)=>debugPrint(r.toString()));
    routeSteps=list.map((r)=>RouteStep.fromJson(r.cast<String, dynamic>())).toList();
    placesList=plist.map((p)=>PlaceInfo.fromJson(p.cast<String, dynamic>())).toList();
  }
}
