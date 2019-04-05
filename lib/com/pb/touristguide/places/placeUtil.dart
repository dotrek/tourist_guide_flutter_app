class PlaceUtil {
  static String buildPhotoURL(String apiKey, String photoReference,
      int maxWidth) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$apiKey";
  }
}
