import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourist_guide/com/pb/touristguide/models/favouritePlaceModel.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeDetail.dart';
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
            List<DocumentSnapshot> documents = snapshot.data.documents;
            return Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: documents.length,
                padding: EdgeInsets.only(top: 10.0),
                itemBuilder: (BuildContext context, int index) {
                  var favoritePlace =
                      FavoritePlaceModel.fromSnapshot(documents[index]);
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.place,
                        color: Colors.lightGreen,
                      ),
                      title: Text(
                        favoritePlace.name,
                        textAlign: TextAlign.center,
                      ),
                      subtitle: favoritePlace.address != null
                          ? Text(
                              favoritePlace.address,
                              textAlign: TextAlign.center,
                            )
                          : Container(),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailWidget(
                            placeId: favoritePlace.placeId,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
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
