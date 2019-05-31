import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/main.dart';

class Database {
  static Firestore firestore = Firestore.instance;

  static Future pushTrip(Trip trip) {
    var documentKey = "${trip.owner}_${trip.key}";
    return firestore
        .collection('trips')
        .document(documentKey)
        .setData(trip.toJson())
        .then((v) => trip.placesList.forEach((place) => firestore
            .collection('trips')
            .document(documentKey)
            .collection('places')
            .document("${trip.tripName}_${place.placeId}")
            .setData(place.toJson())));
  }

  static Stream<QuerySnapshot> getTrips() {
    return firestore
        .collection("trips").where("owner", isEqualTo: auth.getCurrentUser())
        .snapshots();
  }

  static Future<List<PlaceInfo>> getPlacesListFromDocSnapshot(
      DocumentSnapshot snapshot) async {
    var placesDocuments =
        await snapshot.reference.collection("places").getDocuments();
    return placesDocuments.documents
        .map((document) => PlaceInfo.fromJson(document.data))
        .toList();
  }
}
