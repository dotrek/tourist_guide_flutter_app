import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firebaseData.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
        crossAxisCount: 4,
        itemCount: tripList.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: tripList[index].placesList.length,
                  itemBuilder: (BuildContext context, int placeIndex) {
                    return Text(tripList[index].placesList[placeIndex].name);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
              ),
            ),
          );
        },
        staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
      ),
    );
  }

  void _onTripAdded(Event event) {
    setState(() {
      tripList.add(Trip.fromSnapshot(event.snapshot));
    });
  }
}
