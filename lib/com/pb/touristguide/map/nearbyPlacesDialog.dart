import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NearbyPlacesDialog extends StatefulWidget {
  @override
  _NearbyPlacesDialogState createState() => _NearbyPlacesDialogState();
}

class _NearbyPlacesDialogState extends State<NearbyPlacesDialog> {
  double _radius = 1000;
  var _objectTypes = {
    "accounting": false,
    "airport": false,
    "amusement_park": false,
    "aquarium": false,
    "art_gallery": false,
    "bank": false,
    "bar": false,
    "bus_station": false,
    "cafe": false,
    "campground": false,
    "car_rental": false,
    "car_repair": false,
    "casino": false,
    "church": false,
    "city_hall": false,
    "department_store": false,
    "embassy": false,
    "gas_station": false,
    "hospital": false,
    "movie_theater": false,
    "museum": false,
    "night_club": false,
    "park": false,
    "restaurant": false,
    "shopping_mall": false,
    "stadium": false,
    "subway_station": false,
    "train_station": false,
  };

  @override
  Widget build(BuildContext context) {
    var objectTypeStrings = _objectTypes.keys.toList();
    return AlertDialog(
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Search"),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
      ],
      title: Text(
        "Nearby search preferences",
        textAlign: TextAlign.center,
      ),
      content: Column(
        children: <Widget>[
          Text("Choose radius from your position"),
          Text("${_radius.toInt()} metres"),
          Divider(),
          Slider.adaptive(
              activeColor: Colors.green,
              min: 100,
              max: 10000,
              value: _radius,
              onChanged: (val) => setState(() => _radius = val)),
          Divider(),
          Expanded(
            child: ListView.builder(
                itemCount: _objectTypes.length,
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 8.0),
                itemBuilder: (context, index) {
                  var textWidget = Text(
                    objectTypeStrings[index],
                    overflow: TextOverflow.clip,
                    softWrap: true,
                  );
                  var actualValue = _objectTypes[textWidget.data];
                  return CheckboxListTile(
                    value: actualValue,
                    onChanged: (value) =>
                        setState(() => _objectTypes[textWidget.data] = value),
                    title: textWidget,
                    selected: actualValue,
                  );
                }),
          ),
        ],
      ),
    );
  }
}
