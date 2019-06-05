import 'dart:convert';

import 'dart:math';

class PlaceUtil {
  static String buildPhotoURL(
      String apiKey, String photoReference, int maxWidth) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$apiKey";
  }

  static String generateKey() {
    var values = List<int>.generate(5, (i) => Random.secure().nextInt(256));

    return base64Url.encode(values);
  }
}
