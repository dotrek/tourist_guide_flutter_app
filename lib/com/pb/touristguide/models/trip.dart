import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';

class Trip {
  String key;
  String tripName;
  List<PlaceInfo> placesList;
  int distance;
  int durationInSeconds;
  bool isDone;
  String owner;

  Trip(this.owner, this.distance, this.durationInSeconds,
      this.placesList, this.isDone) {
    this.key = PlaceUtil.generateKey();
  }

  Map<String, dynamic> toJson() => {
        "tripName": tripName,
        "distance": distance,
        "durationInSeconds": durationInSeconds,
//        "placesList": placesList.map((p) => p.toJson()).toList(),
        "isDone": isDone,
        "owner": owner
      };

  Trip.fromSnapshot(DocumentSnapshot snapshot) {
    key = snapshot.documentID;
    tripName = snapshot.data['tripName'];
    distance = snapshot.data['distance'];
    durationInSeconds = snapshot.data['durationInSeconds'];

    isDone = snapshot.data['isDone'];
    owner = snapshot.data['owner'];
  }
}
