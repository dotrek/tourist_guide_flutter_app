import 'dart:async';
import 'dart:math';

import 'package:duration/duration.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firebaseData.dart';
import 'package:tourist_guide/main.dart';

class UserTrips extends StatefulWidget {
  @override
  _UserTripsState createState() => _UserTripsState();
}

class _UserTripsState extends State<UserTrips> {
  List<Trip> tripList;
  StreamSubscription<Event> _onTripAddedSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tripList = new List<Trip>();
    _onTripAddedSubscription =
        Database.database.reference().onChildAdded.listen(_onTripAdded);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _onTripAddedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StaggeredGridView.countBuilder(
        itemCount: tripList.length,
        itemBuilder: (context, index) {
          var trip = tripList[index];
          var tripImage = _getRandomTripPhotoRef(trip);
          return Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: Stack(
              children: <Widget>[
                tripImage,
                Column(
                  children: <Widget>[
                    Text(
                      trip.tripName,
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
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
        },
        staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 4.0,
        crossAxisCount: 4,
      ),
    );
  }

  void _onTripAdded(Event event) {
    setState(() {
      tripList.add(Trip.fromSnapshot(event.snapshot));
    });
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
}
