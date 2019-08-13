import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourist_guide/com/pb/touristguide/models/favouritePlaceModel.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/models/route.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/main.dart';

class Database {
  static Firestore firestore = Firestore.instance;

  static Future updateTrip(Trip trip) {
    var documentKey = "${trip.owner}_${trip.tripName}";
    return firestore
        .collection('trips')
        .document(documentKey)
        .updateData(trip.toJson())
        .then((v) {
      trip.placesList.forEach((place) => firestore
          .collection('trips')
          .document(documentKey)
          .collection('places')
          .document("${trip.tripName}_${place.placeId}")
          .updateData(place.toJson()));
    });
  }

  static Future pushTrip(Trip trip) {
    var documentKey = "${trip.owner}_${trip.tripName}";
    return firestore
        .collection('trips')
        .document(documentKey)
        .setData(trip.toJson())
        .then((v) {
      trip.placesList.forEach((place) => firestore
          .collection('trips')
          .document(documentKey)
          .collection('places')
          .document("${trip.tripName}_${place.placeId}")
          .setData(place.toJson()));
    });
  }

  static Stream<QuerySnapshot> getTrips() {
    return firestore
        .collection("trips")
        .where("owner", isEqualTo: auth.getCurrentUser())
        .snapshots();
  }

  static Stream<QuerySnapshot> getFavouritePlaces() {
    var currentUser = auth.getCurrentUser();
    return firestore
        .collection("db")
        .document(currentUser)
        .collection("favourites")
        .snapshots();
  }

  static Future removeFavoritePlace(String placeId) {
    var currentUser = auth.getCurrentUser();
    return firestore
        .collection("db")
        .document(currentUser)
        .collection("favorites")
        .document(placeId)
        .delete();
  }

  static Future<DocumentSnapshot> checkIfFavorite(String placeId) {
    return firestore
        .collection("db")
        .document(auth.getCurrentUser())
        .collection("favorites")
        .document(placeId)
        .get();
  }

  static Future pushFavoritePlace(FavouritePlaceModel favouritePlaceModel) {
    String documentKey = favouritePlaceModel.placeId;
    return firestore.collection("db")
        .document(auth.getCurrentUser())
        .collection("favorites")
        .document(documentKey)
        .setData(favouritePlaceModel.toJson());
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
