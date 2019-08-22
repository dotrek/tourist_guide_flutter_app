import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteStep {
  final LatLng _startLoc;
  final LatLng _endLoc;
  final int _distance;
  final int _durationInSeconds;

//  final String textInstruction;
  RouteStep(this._startLoc, this._endLoc, this._distance, this._durationInSeconds);

  RouteStep.fromJson(Map<String, dynamic> json)
      : _startLoc = LatLng(
            json['start_location']['lat'], json['start_location']['lng']),
        _endLoc =
            LatLng(json['end_location']['lat'], json['end_location']['lng']),
        _distance = json['distance']['value'],
        _durationInSeconds = json['duration']['value'];

  Map<String, dynamic> toJson() => {
        "start_location": {'lat': _startLoc.latitude, 'lng': _startLoc.longitude},
        "end_location": {'lat': _endLoc.latitude, 'lng': _endLoc.longitude},
        "distance": {'value': _distance},
        "duration": {'value': _durationInSeconds}
      };

  int get durationInSeconds => _durationInSeconds;

  int get distance => _distance;

  LatLng get endLoc => _endLoc;

  LatLng get startLoc => _startLoc;

}
