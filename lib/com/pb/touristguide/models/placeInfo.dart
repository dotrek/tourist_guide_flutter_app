import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';

class PlaceInfo {
  final Geometry geometry;
  final String name;
  final String placeId;
  final num rating;
  final List<String> types;
  final String vicinity;
  final String formattedAddress;
  final List<String> photoRefs;

  PlaceInfo(this.geometry, this.name, this.placeId, this.rating, this.types,
      this.vicinity, this.formattedAddress, this.photoRefs);

  factory PlaceInfo.fromPlacesSearchResult(PlacesSearchResult psr) =>
      new PlaceInfo(
          psr.geometry,
          psr.name,
          psr.placeId ?? PlaceUtil.generateKey(),
          psr.rating,
          psr.types,
          psr.vicinity,
          psr.formattedAddress,
          psr.photos?.map((photo) => photo.photoReference)?.toList());

  factory PlaceInfo.fromJson(Map json) => json != null
      ? new PlaceInfo(
          new Geometry.fromJson(json["geometry"]),
          json["name"],
          json["place_id"],
          json["rating"],
          (json["types"] as List)?.cast<String>(),
          json["vicinity"],
          json["formatted_address"],
          (json["photoRefs"] as List)?.cast<String>(),
        )
      : null;

  Map<String, dynamic> toJson() => {
        'name': name,
        "geometry": {
          "location": {
            "lat": geometry.location.lat,
            "lng": geometry.location.lng
          }
        },
        'types': types,
        'formatted_address': formattedAddress,
        'vicinity': vicinity,
        'photoRefs': photoRefs,
        'rating': rating,
        'place_id': placeId
      };
}
