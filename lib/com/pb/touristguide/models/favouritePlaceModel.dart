import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FavouritePlaceModel {
  String placeId;
  String owner;
  String name;

  FavouritePlaceModel(this.placeId, this.name, this.owner);

  Map<String, dynamic> toJson() => {"name": name, "owner": owner};

  FavouritePlaceModel.fromSnapshot(DocumentSnapshot snapshot) {
    placeId = snapshot.documentID;
    name = snapshot.data['name'];
    owner = snapshot.data['owner'];
  }
}
