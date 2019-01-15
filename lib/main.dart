import 'package:flutter/material.dart';
import 'package:tourist_guide/map.dart';

///This API Key will be used for both the interactive maps as well as the static maps.

const API_KEY = "***REMOVED***";
final customTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  accentColor: Colors.redAccent,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.00)),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 12.50,
      horizontal: 10.00,
    ),
  ),
);

void main() {
  runApp(MaterialApp(
    theme: customTheme,
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps demo'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Lorem Ipsum"),
              accountEmail: Text("It dolore"),
            )
          ],
        ),
      ),
      body: Column(
        children: [MapWidget(), Expanded(child: ListView())],
      ),
    ),
  ));
}
