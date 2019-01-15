import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

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
      padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
      child: Card(
        child: InkWell(
          onTap: () {},
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
    );
  }).toList();

  return ListView(shrinkWrap: true, children: placesWidget);
}
