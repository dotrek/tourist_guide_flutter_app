import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeDetail.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/trip/tripView.dart';
import 'package:tourist_guide/main.dart';

class PlacesListView extends StatefulWidget {
  final List<PlacesSearchResult> places;

  const PlacesListView({Key key, this.places}) : super(key: key);

  @override
  _PlacesListViewState createState() => _PlacesListViewState();
}

class _PlacesListViewState extends State<PlacesListView> {
  List<PlacesSearchResult> selectedPlaces = List<PlacesSearchResult>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select places"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "createTrip",
        onPressed: () => selectedPlaces.length < 2
            ? null
            : Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => TripView(
                      selectedPlaces: selectedPlaces,
                    ))),
        label: Text("Create"),
        icon: Icon(Icons.create),
        backgroundColor:
            selectedPlaces.length < 2 ? Colors.transparent : Colors.lightGreen,
      ),
      body: Container(
        child: buildPlacesList(widget.places),
      ),
    );
  }

  ListView buildPlacesList(List<PlacesSearchResult> places) {
    final placesWidget = places.map((f) {
      return Card(
        color: Colors.grey.shade100,
        child: InkWell(
          onTap: () => showDetailPlace(f.placeId),
          onLongPress: () {
            debugPrint("Long Pressed ${f.name}");
            setState(() => _handleLongPress(f));
          },
          highlightColor: Theme.of(context).primaryColor,
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 4.0, right: 4.0),
            selected: selectedPlaces.contains(f),
            title: Text(f.name),
            leading: f.photos == null || f.photos.isEmpty
                ? SizedBox(
                    width: 100,
                    child: Icon(Icons.photo),
                  )
                : Padding(
                    padding: EdgeInsets.only(right: 1.0),
                    child: SizedBox(
                      width: 100,
                      child: Image.network(PlaceUtil.buildPhotoURL(
                          API_KEY, f.photos.first.photoReference, 100)),
                    )),
            subtitle: Text(
                f.types.toString().replaceFirst("[", "").replaceFirst("]", "")),
          ),
        ),
      );
    }).toList();

    return ListView.builder(
        itemCount: placesWidget.length,
        itemBuilder: (context, int index) {
          return placesWidget.elementAt(index);
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

  void showDetailPlace(String placeId) {
    if (placeId != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PlaceDetailWidget(placeId: placeId)));
    }
  }
}
