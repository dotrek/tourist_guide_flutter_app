import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/directions.dart';

void main() {
  test("Should return properly formatted lat lng string", () {
    LatLng latLng = LatLng(20, 20);
    String expected = "20.0,20.0";
    String actual = DirectionsRequest.getLatLngString(latLng);
    expect(actual, expected);
  });
}
