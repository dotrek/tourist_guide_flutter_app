import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:tourist_guide/com/pb/touristguide/models/trip.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firestoreDatabase.dart';

class TripNameDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  static final _formKey = GlobalKey<FormFieldState>();

  final Trip trip;

  TripNameDialog({Key key, this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Type trip name"),
      content: TextFormField(
        key: _formKey,
        controller: _controller,
        // ignore: missing_return
        validator: (value) {
          if (value.isEmpty) {
            return 'Trip name must not be empty';
          }
        },
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                trip.tripName = _formKey.currentState.value;
                Database.pushTrip(trip).then((pushed) {
                  _navigateToMainAndShowSnackbar(context);
                });
              }
            },
            child: Text("Confirm")),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ],
    );
  }

  _navigateToMainAndShowSnackbar(BuildContext context) async {
    Navigator.of(context).popUntil(ModalRoute.withName('/main'));
    Flushbar(
      title: "Trip succesfully created",
      message: "You can check all of your trips on 'My Trips' card",
      backgroundColor: Colors.lightGreen,
      duration: Duration(seconds: 3),
    ).show(context);
  }
}
