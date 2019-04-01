import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placesList.dart';
import 'package:tourist_guide/main.dart';
import 'package:tourist_guide/com/pb/touristguide/map/map.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<PlacesSearchResult> placesList = List();
  var mapWidget = MapWidget(
    key: mapWidgetKey,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          onPressed: () {
            if (placesList.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PlacesListView(places: placesList,)));
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
            keyword: "(tourist) OR (monument) OR (cathedra) OR (palace)");
    if (cityPointsOfInterests.isOkay) {
      var cityPointsOfInterestsResult = cityPointsOfInterests.results;
      cityPointsOfInterestsResult.forEach((psr) {
        currentMapState.addMarker(psr);
        debugPrint("location name: ${psr.name}");
        debugPrint("location type: ${psr.types.first}");
      });
      setState(() {
        this.placesList=cityPointsOfInterestsResult;
      });
      var pointsLatLngList = cityPointsOfInterestsResult
          .map((poi) =>
              LatLng(poi.geometry.location.lat, poi.geometry.location.lng))
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
