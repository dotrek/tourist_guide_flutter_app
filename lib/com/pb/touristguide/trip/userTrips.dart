import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firestoreDatabase.dart';
import 'package:tourist_guide/main.dart';

class UserTrips extends StatefulWidget {
  @override
  _UserTripsState createState() => _UserTripsState();
}

class _UserTripsState extends State<UserTrips> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Database.getTrips(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            var tripList = snapshot.data.documents
                .map((docSnap) => Trip.fromSnapshot(docSnap)).toList();
            Container(
              child: getGridView(tripList),
            );
          }
        });
  }

  Widget getGridView(List<Trip> tripList) {
    return StaggeredGridView.countBuilder(
      itemCount: tripList.length,
      itemBuilder: (context, index) => tripItem(tripList[index]),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 4.0,
      crossAxisCount: 4,
    );
  }

  Widget tripItem(Trip trip) {
    var tripImage = _getRandomTripPhotoRef(trip);
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Stack(
        children: <Widget>[
          tripImage,
          Column(
            children: <Widget>[
              Text(
                trip.tripName,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Center(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.directions_walk,
                            ),
                            Padding(padding: EdgeInsets.all(4.0)),
                            Expanded(
                                child: Text(
                              "${trip.distance} metres",
                            )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                            ),
                            Expanded(
                              child: Text(
                                "${printDuration(Duration(seconds: trip.durationInSeconds))}",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

Image _getRandomTripPhotoRef(Trip trip) {
  int placesLenght = trip.placesList.length;
  List photoRefs = trip.placesList[Random().nextInt(placesLenght)].photoRefs;
  if (photoRefs == null) {
    return null;
  }
  int photoRefsLength = photoRefs.length;
  if (photoRefsLength == 0) {
    return null;
  } else {
    return Image.network(
      PlaceUtil.buildPhotoURL(
          API_KEY, photoRefs[Random().nextInt(photoRefsLength)], 1000),
      fit: BoxFit.fill,
    );
  }
}
