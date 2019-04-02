import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placesList.dart';
import 'package:tourist_guide/main.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  List<PlacesSearchResult> placesList = List();
  var mapWidget = MapWidget(
    key: mapWidgetKey,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "centerLocation",
            mini: true,
            onPressed: () => mapWidgetKey.currentState.animateToUserLocation(),
            child: Center(child: Icon(Icons.my_location)),
          ),
          FloatingActionButton(
            heroTag: "createTrip",
            backgroundColor:
                placesList.isEmpty ? Colors.transparent : Colors.lightGreen,
            onPressed: () {
              if (placesList.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => PlacesListView(
                          places: placesList,
                        ),
                  ),
                );
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 2),
                    content: Text(
                        "There are no places on map, type the city name you want to visit or click settings button on search bar and configure nearby search")));
              }
            },
            child: Column(
              children: [
                Center(child: Icon(Icons.call_missed_outgoing)),
                Center(
                  child: Text(
                    "Create trip",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FloatingActionButton(
            heroTag: "clearMarkers",
            backgroundColor:
                placesList.isEmpty ? Colors.transparent : Colors.lightGreen,
            mini: true,
            onPressed: () => setState(() {
                  placesList.clear();
                  mapWidgetKey.currentState.clearMarkers();
                }),
            child: Center(child: Icon(Icons.location_off)),
          )
        ],
      ),
      body: Stack(children: <Widget>[
        mapWidget,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.grey.shade50,
                  child: PlacesAutocompleteField(
                      apiKey: API_KEY,
                      hint: "Search by city",
                      mode: Mode.overlay,
                      types: ["(cities)"],
                      leading: Icon(Icons.search),
                      trailing: Icon(Icons.tune),
                      trailingOnTap: () => showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                                title: Text("Nearby search preferences"),
                              )),
                      onChanged: (place) {
                        debugPrint("Place: $place");
                        getCityPOI(place);
                      }),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

  void getCityPOI(String place) async {
    var currentMapState = mapWidgetKey.currentState;
    currentMapState.clearMarkers();
    Location location = await getCityLocation(place);
    if (location == null) {
      debugPrint("City location not found");
      return;
    }
    PlacesSearchResponse cityPointsOfInterests =
        await mapsPlaces.searchNearbyWithRadius(location, 5000,
            type: "point_of_interest",
            keyword:
                "(tourist) OR (monument) OR (cathedral) OR (palace) OR (museum)");
    if (cityPointsOfInterests.isOkay) {
      var cityPointsOfInterestsResult = cityPointsOfInterests.results;
      cityPointsOfInterestsResult.forEach((psr) {
        currentMapState.addMarker(psr);
        debugPrint("location name: ${psr.name}");
        debugPrint("location type: ${psr.types.first}");
      });
      setState(() {
        this.placesList = cityPointsOfInterestsResult;
      });
      var pointsLatLngList = cityPointsOfInterestsResult
          .map((poi) =>
              MapUtil.getLatLngLocationOfPlace(poi))
          .toList();
      LatLng southwest = MapUtil.getSouthwestPoint(pointsLatLngList);
      LatLng northeast = MapUtil.getNorthEastPoint(pointsLatLngList);
      mapWidgetKey.currentState.animateToLocation(southwest, northeast);
    }
  }

  Future<Location> getCityLocation(String cityName) async {
    PlacesSearchResponse cityPlace = await mapsPlaces.searchByText(cityName);
    if (cityPlace.isOkay) {
      var cityPlaceResponse = cityPlace.results;
      return cityPlaceResponse.first.geometry.location;
    }
    return null;
  }
}
