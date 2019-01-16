import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeDetail.dart';

class PlacesListView extends StatefulWidget {
  final List<PlacesSearchResult> places;

  const PlacesListView({Key key, this.places}) : super(key: key);

  @override
  _PlacesListViewState createState() => _PlacesListViewState();
}

class _PlacesListViewState extends State<PlacesListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildPlacesList(widget.places),
    );
  }

  ListView buildPlacesList(List<PlacesSearchResult> places) {
    final placesWidget = places.map((f) {
      List<Widget> list = [
        Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            f.name,
          ),
        )
      ];
      if (f.formattedAddress != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.formattedAddress,
          ),
        ));
      }

      if (f.vicinity != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.vicinity,
          ),
        ));
      }

      if (f.types?.first != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.types.first,
          ),
        ));
      }

      return Padding(
          padding:
              EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
          child: Slidable(
              delegate: SlidableStrechDelegate(),
              actionExtentRatio: 0.25,
              actions: <Widget>[
                IconSlideAction(
                  caption: "Details",
                  color: Colors.lightGreen,
                  icon: Icons.details,
                  onTap: () => debugPrint("DetailsClicked"),
                )
              ],
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: "Remove",
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap:() {
                    debugPrint("Removed");
                  },
                )
              ],
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: InkWell(
                      onTap: _handlePressButton,
                      highlightColor: Colors.lightBlueAccent,
                      splashColor: Colors.lightBlue,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: list,
                        ),
                      ),
                    ),
                  ),
                ),
              )));
    }).toList();

    return ListView(shrinkWrap: true, children: placesWidget);
  }

  Future<void> _handlePressButton() async {
    try {
      final center = await getUserLocation();
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: API_KEY,
          mode: Mode.fullscreen,
          language: "en",
          location: center == null
              ? null
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 10000);

      showDetailPlace(p.placeId);
    } catch (e) {
      return;
    }
  }

  void showDetailPlace(String placeId) {
    if (placeId != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => PlaceDetailWidget(placeId)));
    }
  }
}
