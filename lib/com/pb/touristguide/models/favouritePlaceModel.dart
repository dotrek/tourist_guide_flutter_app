import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritePlaceModel {
  String placeId;
  String owner;
  String name;
  String address;

  FavoritePlaceModel(this.placeId, this.name, this.address, this.owner);

  Map<String, dynamic> toJson() =>
      {"name": name, "owner": owner, "address": address};

  FavoritePlaceModel.fromSnapshot(DocumentSnapshot snapshot) {
    placeId = snapshot.documentID;
    name = snapshot.data['name'];
    owner = snapshot.data['owner'];
    address = snapshot.data['address'];
  }
}
