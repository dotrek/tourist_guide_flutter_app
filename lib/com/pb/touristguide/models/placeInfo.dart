import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';

class PlaceInfo {
  num order;
  final Geometry _geometry;
  final String _name;
  final String _placeId;
  final num _rating;
  final List<String> _types;
  final String _vicinity;
  final String _formattedAddress;
  final List<String> _photoRefs;

  PlaceInfo(this._geometry, this._name, this._placeId, this._rating,
      this._types, this._vicinity, this._formattedAddress, this._photoRefs,
      {num order});

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
        'name': _name,
        "geometry": {
          "location": {
            "lat": _geometry.location.lat,
            "lng": _geometry.location.lng
          }
        },
        'types': _types,
        'formatted_address': _formattedAddress,
        'vicinity': _vicinity,
        'photoRefs': _photoRefs,
        'rating': _rating,
        'place_id': _placeId,
        'order': order
      };

  List<String> get photoRefs => _photoRefs;

  String get formattedAddress => _formattedAddress;

  String get vicinity => _vicinity;

  List<String> get types => _types;

  num get rating => _rating;

  String get placeId => _placeId;

  String get name => _name;

  Geometry get geometry => _geometry;

}
