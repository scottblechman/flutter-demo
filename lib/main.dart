import 'package:flutter/material.dart';

import 'places.dart';

// Dart requires a main method as an execution entry point, unlike Kotlin
// or Swift execution but similar to Java
void main() => runApp(new MyApp());

// Stateless Widget is primary Flutter view - views are programatically
// comprised of different widgets central to Flutter library
class MyApp extends StatelessWidget {
  // build is automayically called
  @override
  Widget build(BuildContext context) {
    // MaterialApp is a type of WidgetsApp base for mobile UIs in Flutter.
    // The widget is a container for other widgets
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData( // customize the overall app theme
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Restaurant Finder'),
    );
  }
}

// Stateful widgets maintain a component state defined in a subclass
// of State<StatefulWidget subclass> (ours is defined below)
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

// underscore-starting vars or classes are file-private
class _MyHomePageState extends State<MyHomePage> {

  List<Place> _places = <Place>[];

  @override
  void initState() {
      super.initState();
      fetchPlaces();  // start async fetching of place data
    }

    // async methods automatically work on new thread
    fetchPlaces() async {
      // get the future now, and wait for result (stream) before next statement
      var placeStream = await getPlaces(lat, lng);  //global to places.dart

      // listen for new stream data, and when added, re-set the state with
      // the new list (being the old list plus the new place)
      placeStream.listen( (place) => 
        setState( () => _places.add(place))
      );
    }

  // for reasons known to none, widget definitions for a stateful widget
  // are done in the widget's state class.
  @override
  Widget build(BuildContext context) {
    // Scaffold has basic material design layout structure (appbar + body)
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new ListView(
          children: _places.map((place) => new PlaceWidget(place)).toList(),
        )
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// Define a custom view that will take the list of place data fetched
// and display each item in its own view
class PlaceWidget extends StatelessWidget {

  // associated data that will be pass in in constructor
  final Place _place; //stateless widget is immutable so final is okay

  // constructor
  PlaceWidget(this._place);

  //utility method to color element based on rating (1 star is red and 5
  // is green, ratings in between have a mixed color)
  Color getColor(double rating) {
    return Color.lerp(Colors.red, Colors.green, rating/5);
  }

  @override
  Widget build(BuildContext context) {
    // define the view to render. Dismissible widgets can be swiped away
    return new Dismissible(
      key: new Key(_place.name),  //track what is dismissed and what is hidden
      background: new Container(color: Colors.green), //will be shown on right swipe
      secondaryBackground: new Container(color: Colors.red), //will be shown on left swipe

      // what action should happen when dismissed? utilizing which direction the swipe was
      // here, we will show a snackbar to provide context to the swipe
      onDismissed: (direction) {
        String text = "";
        final String positiveText = "You liked this place";
        final String negativeText = "You disliked this place";

        // true if we swiped from start (left) to end (right), false otherwise
        direction == DismissDirection.startToEnd ? text = positiveText : text = negativeText;
        //build and show the snackbar
        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(text)));
      },

      // ListTile widgets contain some text as well as an (optional)
      // leading icon
      child: new ListTile(
      leading: new CircleAvatar(
        child: new Text(_place.rating.toString()),  //displayed inside the circle
        backgroundColor: getColor(_place.rating)
      ),

      title: new Text(_place.name),
      subtitle: new Text(_place.address)
      )
    );
  }
}
