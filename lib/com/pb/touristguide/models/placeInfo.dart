import 'package:google_maps_webservice/places.dart';

class PlaceInfo {
    final Geometry geometry;
    final String name;
    final String placeId;
    final num rating;
    final List<String> types;
    final String vicinity;
    final String formattedAddress;
  PlaceInfo(this.geometry, this.name, this.placeId, this.rating, this.types, this.vicinity, this.formattedAddress);

  factory PlaceInfo.fromJson(Map json) => json != null
      ? new PlaceInfo(
          new Geometry.fromJson(json["geometry"]),
          json["name"],
          json["place_id"],
          json["rating"],
          (json["types"] as List)?.cast<String>(),
          json["vicinity"],
          json["formatted_address"],
        )
      : null;

  Map<String, dynamic> toJson() => {
        'name': name,
        "location": {
          "lat": geometry.location.lat,
          "lng": geometry.location.lng
        },
        'rating': rating,
        'placeId': placeId
      };
}
