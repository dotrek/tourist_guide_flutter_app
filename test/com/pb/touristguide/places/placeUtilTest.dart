import 'package:flutter_test/flutter_test.dart';
import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';

void main() {
  group("Some Group", () {
    test('PlaceInfo list should be reordered', () {
      Map json = {"order": 2};
      PlaceInfo b = PlaceInfo.fromJson(json);
      json["order"] = 4;
      PlaceInfo c = PlaceInfo.fromJson(json);
      List<PlaceInfo> cb = [c, b];
      List<PlaceInfo> reorderedList = PlaceUtil.reorderList(cb);
      expect(reorderedList.indexOf(c), 0);
      expect(reorderedList.indexOf(b), 1);
    });
    test(
        'Should generate key with length 83 and which contains base photo API URL',
        () {
      var baseString = "https://maps.googleapis.com/maps/api/place/photo";
      var api = "a";
      var photoRef = "b";
      var maxWidth = 10;
      String key = PlaceUtil.buildPhotoURL(api, photoRef, maxWidth);
      expect(key.length, 83);
      expect(true, key.contains(baseString));
    });
  });
}
