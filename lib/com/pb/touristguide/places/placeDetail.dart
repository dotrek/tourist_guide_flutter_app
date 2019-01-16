import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/main.dart';

class PlaceDetailWidget extends StatefulWidget {

  const PlaceDetailWidget(String placeId, {Key key}) : super(key: key);

  String get placeId => placeId;

  @override
  _PlaceDetailWidgetState createState() => _PlaceDetailWidgetState();
}

class _PlaceDetailWidgetState extends State<PlaceDetailWidget> {
  PlacesDetailsResponse place;

  @override
  void initState() {
    fetchPlaceDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildPlaceDetailList(place.result),
    );
  }

  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$API_KEY";
  }

  ListView buildPlaceDetailList(PlaceDetails placeDetail) {
    List<Widget> list = [];
    if (placeDetail.photos != null) {
      final photos = placeDetail.photos;
      list.add(SizedBox(
          height: 100.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(right: 1.0),
                    child: SizedBox(
                      height: 100,
                      child: Image.network(
                          buildPhotoURL(photos[index].photoReference)),
                    ));
              })));
    }

    list.add(
      Padding(
          padding:
              EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Text(
            placeDetail.name,
            style: Theme.of(context).textTheme.subtitle,
          )),
    );

    if (placeDetail.formattedAddress != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              placeDetail.formattedAddress,
              style: Theme.of(context).textTheme.body1,
            )),
      );
    }

    if (placeDetail.types?.first != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 0.0),
            child: Text(
              placeDetail.types.first.toUpperCase(),
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.formattedPhoneNumber != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              placeDetail.formattedPhoneNumber,
              style: Theme.of(context).textTheme.button,
            )),
      );
    }

    if (placeDetail.openingHours != null) {
      final openingHour = placeDetail.openingHours;
      var text = '';
      if (openingHour.openNow) {
        text = 'Open';
      } else {
        text = 'Closed';
      }
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.website != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              placeDetail.website,
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.rating != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              "Rating: ${placeDetail.rating}",
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: list,
    );
  }

  void fetchPlaceDetail() async {
    PlacesDetailsResponse place =
        await mapsPlaces.getDetailsByPlaceId(widget.placeId);

    if (mounted) {
      setState(() {
        if (place.status == "OK") {
          this.place = place;
        }
      });
    }
  }
}
