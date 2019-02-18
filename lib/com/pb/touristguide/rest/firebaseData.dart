import 'package:firebase_database/firebase_database.dart';

class Database {
  static FirebaseDatabase database = FirebaseDatabase.instance;

  static push(Map<String, dynamic> objectToPush) {
    database.reference().push().set(objectToPush);
  }

}
