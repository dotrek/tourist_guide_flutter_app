import 'dart:convert';

import 'dart:math';

import 'package:tourist_guide/com/pb/touristguide/models/placeInfo.dart';

class PlaceUtil {
  static String buildPhotoURL(
      String apiKey, String photoReference, int maxWidth) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$apiKey";
  }

  static String generateKey() {
    var values = List<int>.generate(5, (i) => Random.secure().nextInt(256));

    return base64Url.encode(values);
  }

  static List<PlaceInfo> reorderList(List<PlaceInfo> listToReorder) {
    for (num i = 0; i < listToReorder.length; i++) {
      listToReorder[i].order = i;
    }
    return listToReorder;
  }
}
