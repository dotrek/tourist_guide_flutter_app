import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteStep {
  final LatLng startLoc;
  final LatLng endLoc;
  final int distance;
  final int durationInSeconds;

//  final String textInstruction;
  RouteStep(this.startLoc, this.endLoc, this.distance, this.durationInSeconds);

  RouteStep.fromJson(Map<String, dynamic> json)
      : startLoc =
            LatLng(json['start_location']['lat'], json['start_location']['lng']),
        endLoc =
            LatLng(json['end_location']['lat'], json['end_location']['lng']),
        distance = json['distance']['value'],
        durationInSeconds = json['duration']['value'];
}
