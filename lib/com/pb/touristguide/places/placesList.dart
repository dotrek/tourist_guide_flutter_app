import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
        list.add(
          Padding(
            padding: EdgeInsets.only(bottom: 2.0),
            child: Text(
              f.types.first,
            ),
          ),
        );
      }
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: InkWell(
              highlightColor: Colors.lightBlueAccent,
              splashColor: Colors.lightBlue,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: list,
                ),
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
            padding:
                EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
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

  void deleteItemFromList(List<PlacesSearchResult> places, int index) {
    var latLng = LatLng(places.elementAt(index).geometry.location.lat,
        places.elementAt(index).geometry.location.lng);
    GoogleMapController controller = mapWidgetKey.currentState?.mapController;
    debugPrint(controller.markers.length.toString());
    mapWidgetKey.currentState?.setState(() {
      Marker marker = controller.markers
          .firstWhere((Marker marker) => marker.options.position == latLng);
      debugPrint("Marker do delete: $marker");
      controller.removeMarker(marker);
      debugPrint("markers on map: ${controller.markers.length}");
    });
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
                  deleteItemFromList(places, index);
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
