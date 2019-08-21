import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourist_guide/com/pb/touristguide/models/favouritePlaceModel.dart';
import 'package:tourist_guide/com/pb/touristguide/places/placeUtil.dart';
import 'package:tourist_guide/com/pb/touristguide/rest/firestoreDatabase.dart';
import 'package:tourist_guide/main.dart';

class PlaceDetailWidget extends StatefulWidget {
  final String placeId;

  const PlaceDetailWidget({Key key, this.placeId}) : super(key: key);

  @override
  _PlaceDetailWidgetState createState() => _PlaceDetailWidgetState();
}

class _PlaceDetailWidgetState extends State<PlaceDetailWidget> {
  Future<PlacesDetailsResponse> place;
  bool isFavorite = false;
  var favoriteIcon = Icons.favorite_border;

  @override
  void initState() {
    fetchPlaceDetail();
    isFavouriteCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Place details"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              favoriteIcon,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                if (isFavorite) {
                  Database.removeFavoritePlace(widget.placeId)
                      .then((dynamic) => isFavouriteCheck());
                } else {
                  place.then((response) {
                    PlaceDetails placeDetails = response.result;
                    Database.pushFavoritePlace(FavoritePlaceModel(
                        placeDetails.placeId,
                        placeDetails.name,
                        placeDetails.formattedAddress,
                        auth.getCurrentUser()));
                  });
                  isFavouriteCheck();
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: place,
          builder: (context, widgetBuilder) {
            if (widgetBuilder.hasData) {
              return buildPlaceDetailList(
                  (widgetBuilder.data as PlacesDetailsResponse).result);
            } else {
              return Center(
                  child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator()));
            }
          }),
    );
  }

  Column buildPlaceDetailList(PlaceDetails placeDetail) {
    List<Widget> list = [];
    list.add(
      Padding(
          padding:
              EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Text(
            placeDetail.name,
            style: Theme.of(context).textTheme.title,
          )),
    );

    if (placeDetail.formattedAddress != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              placeDetail.formattedAddress,
              style: Theme.of(context).textTheme.body1,
            )),
      );
    }

    if (placeDetail.types.isNotEmpty) {
      String typesText = '';
      placeDetail.types.forEach((type) => typesText += type);
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 0.0),
            child: Text(
              placeDetail.types.toString(),
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.formattedPhoneNumber != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              placeDetail.formattedPhoneNumber,
              style: Theme.of(context).textTheme.button,
            )),
      );
    }

    if (placeDetail.openingHours != null) {
      final openingHour = placeDetail.openingHours;
      var text = '';
      if (openingHour.openNow) {
        text = 'Open';
      } else {
        text = 'Closed';
      }
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.website != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              placeDetail.website,
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.rating != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              "Rating: ${placeDetail.rating}",
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }
    if (placeDetail.photos != null) {
      final photos = placeDetail.photos;
      list.add(Expanded(
        child: StaggeredGridView.countBuilder(
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.all(4.0),
                child: Hero(
                  tag: photos[index].photoReference,
                  child: GestureDetector(
                      onTap: () {
                        debugPrint("photo $index tapped");
                        Navigator.push(
                            context,
                            HeroDialogRoute(
                                builder: (context) => Hero(
                                      tag: photos[index].photoReference,
                                      child: Image.network(
                                          PlaceUtil.buildPhotoURL(
                                              API_KEY,
                                              photos[index].photoReference,
                                              1000)),
                                    )));
                      },
                      child: Image.network(PlaceUtil.buildPhotoURL(
                          API_KEY, photos[index].photoReference, 200))),
                ));
          },
          staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
          crossAxisCount: 4,
        ),
      ));
    } else {
      list.add(Center(
        child: Text("No photos currently available"),
      ));
    }
    return Column(
      children: list,
    );
  }

  void fetchPlaceDetail() async {
    place = mapsPlaces.getDetailsByPlaceId(widget.placeId);
  }

  void isFavouriteCheck() {
    Database.checkIfFavorite(widget.placeId).then((snapshot) {
      setState(() {
        if (snapshot.exists) {
          isFavorite = true;
          favoriteIcon = Icons.favorite;
        } else {
          isFavorite = false;
          favoriteIcon = Icons.favorite_border;
        }
      });
    });
  }
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({this.builder}) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
        opacity: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return GestureDetector(
        onTap: () => Navigator.of(context).pop(), child: builder(context));
  }

  @override
  String get barrierLabel => null;
}
