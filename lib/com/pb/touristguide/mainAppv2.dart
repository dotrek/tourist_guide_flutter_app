import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String _placeSearched;
  var mapWidget = MapWidget(
    key: mapWidgetKey,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(children: <Widget>[
          mapWidget,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: PlacesAutocompleteField(
                      apiKey: API_KEY,
                      hint: "Search by city",
                      mode: Mode.overlay,
                      types: ["(cities)"],
                      leading: Icon(Icons.search),
                      trailing: Icon(Icons.tune),
                      onChanged: (place) {
                        this.setState(() => this._placeSearched = place);
                        debugPrint("Place: $place");
                        getCityPOI(place);
                      }),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

  void getCityPOI(String place) async {
    PlacesSearchResponse searchByText =
        await mapsPlaces.searchByText(place, type: "point_of_interest");
    if (searchByText.isOkay) {
      var results = searchByText.results;
      results.forEach((psr) {
        mapWidgetKey.currentState.addMarker(psr.id,
            LatLng(psr.geometry.location.lat, psr.geometry.location.lng));
        debugPrint(psr.name);
      });
    }
  }
}
