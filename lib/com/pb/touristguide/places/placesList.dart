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
    return Container(
      child: buildPlacesList(widget.places),
    );
  }

  ListView buildPlacesList(List<PlacesSearchResult> places) {
    final placesWidget = places.map((f) {
      List<Widget> list = List<Widget>();
      list.add(createRow(f.name, Icons.info_outline));
      if (f.vicinity != null) {
        list.add(createRow(f.vicinity, Icons.place));
      }
      if (f.types?.first != null) {
        list.add(createRow(f.types.first, Icons.account_balance));
      }
      return Card(
        child: ListTile(
          selected: selectedPlaces.contains(f),
          leading: InkWell(
            onLongPress: () {
              debugPrint("Long Pressed ${f.name}");
              setState(() => _handleLongPress(f));
            },
            highlightColor: Theme.of(context).primaryColor,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: Column(
                children: list,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return ListView.builder(
        itemCount: placesWidget.length,
        itemBuilder: (context, int index) {
          return Padding(
            padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0),
            child: Slidable(
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
            ),
          );
        });
  }

  _handleLongPress(PlacesSearchResult psr) {
    selectedPlaces.contains(psr)
        ? selectedPlaces.remove(psr)
        : selectedPlaces.add(psr);
  }

  createRow(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
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
