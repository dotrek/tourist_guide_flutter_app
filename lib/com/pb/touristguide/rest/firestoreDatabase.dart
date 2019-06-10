import 'package:cloud_firestore/cloud_firestore.dart';
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
          //TO CHANGE
      trip.placesList.forEach((place) => firestore
          .collection('trips')
          .document(documentKey)
          .collection('places')
          .document("${trip.tripName}_${place.placeId}")
          .updateData(place.toJson()));
      trip.routeSteps.forEach((routeStep) => firestore
          .collection('trips')
          .document(documentKey)
          .collection('routeSteps')
          .document(
              "${trip.tripName}_${routeStep.startLoc}->${routeStep.endLoc}")
          .updateData(routeStep.toJson()));
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
      trip.routeSteps.forEach((routeStep) => firestore
          .collection('trips')
          .document(documentKey)
          .collection('routeSteps')
          .document(
              "${trip.tripName}_${routeStep.startLoc}->${routeStep.endLoc}")
          .setData(routeStep.toJson()));
    });
  }

  static Stream<QuerySnapshot> getTrips() {
    return firestore
        .collection("trips")
        .where("owner", isEqualTo: auth.getCurrentUser())
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

  static Future<List<RouteStep>> getRouteStepsFromDocumentSnapshot(
      DocumentSnapshot snapshot) async {
    var routeStepsDocuments =
        await snapshot.reference.collection("routeSteps").getDocuments();
    return routeStepsDocuments.documents
        .map((document) => RouteStep.fromJson(document.data))
        .toList();
  }
}
