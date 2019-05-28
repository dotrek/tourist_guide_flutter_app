import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourist_guide/com/pb/touristguide/auth/baseAuth.dart';
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
  String owner;

  Trip(this.tripName, this.distance, this.durationInSeconds, this.routeSteps,
      this.placesList, this.isDone);

  Map<String, dynamic> toJson() => {
        "tripName": tripName,
        "distance": distance,
        "durationInSeconds": durationInSeconds,
        "routeSteps": routeSteps.map((r) => r.toJson()).toList(),
        "placesList": placesList.map((p) => p.toJson()).toList(),
        "isDone": isDone,
        "owner": Auth().getCurrentUser()
      };

  Trip.fromSnapshot(DocumentSnapshot snapshot) {
    tripName = snapshot.data['tripName'];
    distance = snapshot.data['distance'];
    durationInSeconds = snapshot.data['durationInSeconds'];

    isDone = snapshot.data['isDone'];
    owner = snapshot.data['owner'];
  }

  Future getPlacesListFromDocumentSnapshot(DocumentSnapshot document) async {
    //    List list = List.from(document.data['routeSteps']);
//    list.forEach((r) => debugPrint(r.toString()));
//    routeSteps =
//        list.map((r) => RouteStep.fromJson(r.cast<String, dynamic>())).toList();
    List plist = List.from(document.data['placesList']);
    for (DocumentReference docRef in plist) {
      DocumentSnapshot snapshot = await docRef.get();
      placesList.add(PlaceInfo.fromJson(snapshot.data));
    }
  }
}
