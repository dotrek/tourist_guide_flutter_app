import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firestoreDatabase.dart';
import 'package:tourist_guide/com/pb/touristguide/trip/tripView.dart';

class UserTrips extends StatefulWidget {
  @override
  _UserTripsState createState() => _UserTripsState();
}

class _UserTripsState extends State<UserTrips> {
  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Database.getTrips(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
                future: _getTripList(snapshot.data.documents),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      child: getGridView(snapshot.data),
                    );
                  } else {
                    return Center(child: RefreshProgressIndicator());
                  }
                });
          } else {
            return Center(
              child: Container(
                child: Text("Currently you have no Trips created"),
              ),
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
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TripView(
                  trip: trip,
                  tripViewMode: TripViewMode.UPDATE,
                ))),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  trip.tripName,
                  textAlign: TextAlign.center,
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
            trip.isDone
                ? SizedBox.fromSize(
                    size: Size(200, 200),
                    child: Opacity(
                      opacity: 0.8,
                      child: Container(
                        color: Colors.white,
                        child: Icon(
                          Icons.done_outline,
                          color: Colors.greenAccent,
                          size: 100,
                        ),
                      ),
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }

  Future _getTripList(List<DocumentSnapshot> documents) async {
    List<Trip> trips = [];
    for (DocumentSnapshot docSnap in documents) {
      var trip = Trip.fromSnapshot(docSnap);
      trip.placesList = await Database.getPlacesListFromDocSnapshot(docSnap);
      trip.routeSteps =
          await Database.getRouteStepsFromDocumentSnapshot(docSnap);
      trips.add(trip);
    }
    return trips;
  }
}

//Image _getRandomTripPhotoRef(Trip trip) {
//  int placesLenght = trip.placesList.length;
//  List photoRefs = trip.placesList[Random().nextInt(placesLenght)].photoRefs;
//  if (photoRefs == null) {
//    return null;
//  }
//  int photoRefsLength = photoRefs.length;
//  if (photoRefsLength == 0) {
//    return null;
//  } else {
//    return Image.network(
//      PlaceUtil.buildPhotoURL(
//          API_KEY, photoRefs[Random().nextInt(photoRefsLength)], 1000),
//      fit: BoxFit.fill,
//    );
//  }
//}
