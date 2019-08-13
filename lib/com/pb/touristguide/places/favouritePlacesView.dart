import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firestoreDatabase.dart';

class FavouritePlacesView extends StatefulWidget {
  @override
  _FavouritePlacesViewState createState() => _FavouritePlacesViewState();
}

class _FavouritePlacesViewState extends State<FavouritePlacesView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Database.getFavouritePlaces(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return Container(child: Text(snapshot.toString()));
          } else {
            return Center(
              child: Container(
                child: Text("Currently you have no favourite places"),
              ),
            );
          }
        });
  }
}
