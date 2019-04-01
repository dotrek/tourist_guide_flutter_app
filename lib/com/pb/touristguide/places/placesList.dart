import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/main.dart';
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
    return Scaffold(
      body: Container(
        child: buildPlacesList(widget.places),
      ),
    );
  }

  ListView buildPlacesList(List<PlacesSearchResult> places) {
    final placesWidget = places.map((f) {
      return Card(
        child: InkWell(
          onLongPress: () {
            debugPrint("Long Pressed ${f.name}");
            setState(() => _handleLongPress(f));
          },
          highlightColor: Theme.of(context).primaryColor,
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 4.0, right: 4.0),
            selected: selectedPlaces.contains(f),
            title:Text(f.name),
            subtitle: Text(f.types.first),
            trailing: Text(
              f.vicinity,
              style: Theme.of(context).textTheme.caption,
            ),
            ),
        ),
      );
    }).toList();

    return ListView.builder(
        itemCount: placesWidget.length,
        itemBuilder: (context, int index) {
          return Slidable(
            delegate: SlidableDrawerDelegate(),
            actionExtentRatio: 0.25,
            actions: <Widget>[
              Card(
                child: IconSlideAction(
                  caption: "Details",
                  color: Colors.lightGreen,
                  icon: Icons.details,
                  onTap: () {
                    setState(() {
                      var elementAt = places.elementAt(index);
                      showDetailPlace(elementAt.placeId);
                    });
                  },
                ),
              )
            ],
            secondaryActions: <Widget>[
              Card(
                child: IconSlideAction(
                  caption: "Remove",
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    setState(() {
                      showDeleteDialog(places, index);
                    });
                  },
                ),
              )
            ],
            child: placesWidget.elementAt(index),
          );
        });
  }

  _handleLongPress(PlacesSearchResult psr) {
    selectedPlaces.contains(psr)
        ? selectedPlaces.remove(psr)
        : selectedPlaces.add(psr);
  }

  createRow(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
        ),
        Text(
          text,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void deleteItemFromList(List<PlacesSearchResult> places, int index) {
    setState(() {
      places.removeAt(index);
    });
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Removed"),
      duration: Duration(seconds: 1),
    ));
  }

  showDeleteDialog(List<PlacesSearchResult> places, int index) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return new AlertDialog(
          title: new Text('Delete'),
          content: new Text('Item will be deleted'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            new FlatButton(
                child: new Text('Ok'),
                onPressed: () {
//                  deleteItemFromList(places, index);
                  Navigator.of(context).pop(true);
                }),
          ],
        );
      },
    );
  }

  void showDetailPlace(String placeId) {
    if (placeId != null) {
      showDialog(
        context: context,
        builder: (context) => AboutDialog(
            applicationLegalese: null,
            children: [PlaceDetailWidget(placeId: placeId)]),
      );
    }
  }
}
