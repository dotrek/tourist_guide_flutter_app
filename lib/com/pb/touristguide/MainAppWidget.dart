import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/mapWithPlaces.dart';
import 'package:tourist_guide/com/pb/touristguide/tripDialog.dart';

class MainAppWidget extends StatefulWidget {
  Widget actualWidget;
  FirebaseUser user;

  MainAppWidget({Key key, this.actualWidget, this.user}) : super(key: key);

  @override
  _MainAppWidgetState createState() => _MainAppWidgetState();
}

class _MainAppWidgetState extends State<MainAppWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: mainKey,
        appBar: AppBar(
          backgroundColor: Colors.green.shade900,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title: ImageIcon(
            Image.asset(
              'assets/appLogo.png',
              fit: BoxFit.cover,
            ).image,
            size: 200.0,
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("Lorem Ipsum"),
                accountEmail: Text("It dolore"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => widget.actualWidget = MapsWithPlacesWidget());
                },
                title: Text("Nearby places"),
                leading: Icon(Icons.near_me),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    widget.actualWidget = PlacesAutocompleteWidget(
                        logo: Icon(Icons.place), apiKey: API_KEY);
                  });
                },
                title: Text("Other places"),
                leading: Icon(Icons.priority_high),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _handleCreateRouteButton(context),
          child: Column(
            children: [
              Center(child: Icon(Icons.call_missed_outgoing)),
              Center(
                  child: Text("Create trip",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12.0,
                      ))),
            ],
          ),
        ),
        body: widget.actualWidget);
  }

  _handleCreateRouteButton(BuildContext context) {
    return selectedPlaces.isEmpty
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "List is empty",
                  style: Theme.of(context).textTheme.body1,
                ),
                content: Text(
                  "Select any places you would like to add to new trip",
                  style: Theme.of(context).textTheme.caption,
                ),
              );
            })
        : _showRouteInfoDialog(context);
  }

  Future _showRouteInfoDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return TripDialog();
        });
  }
}
