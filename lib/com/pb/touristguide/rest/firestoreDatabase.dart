import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';

class Database {
  static Firestore firestore = Firestore.instance;

  static pushTrip(Trip trip) {
    firestore.collection('trips').document().setData(trip.toJson());
  }

  static Stream<QuerySnapshot> getTrips() {
    return firestore.collection("trips").snapshots();
  }
}
