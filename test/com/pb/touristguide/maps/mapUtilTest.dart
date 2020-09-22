import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/map/mapUtil.dart';

void main() {
  test("Should return LatLng object with specified location Geometry", () {
    var bounds = Bounds(Location(1.0, 2.0), Location(2.0, 1.0));
    Geometry geometry = Geometry(Location(20.0, 20.0), "any", bounds, bounds);
    expect(
        MapUtil.getLatLngLocationOfPlace(geometry), equals(LatLng(20.0, 20.0)));
  });
}
