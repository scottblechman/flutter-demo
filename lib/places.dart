import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

// Provides functionality to define place data for the application, and fetch
// a stream of data from an HTTP RESTful API

// For this application, we will define the location we want to load from.
// Check if Flutter has plugins to do location updating (or maps integration)
final double lat = 29.7417;
final double lng = -95.4177;

// places.dart can be run from the command line, which will call this method.
// However, main.dart will only call the getPlaces() method by itself
main() {
  getPlaces(lat, lng);
}

// transform Google Places API data to format needed by app
class Place {
  final String name;
  final double rating;
  final String address;

  // constructor
  Place.fromJson(Map jsonMap) :
    name = jsonMap['name'],
    rating = jsonMap['rating']?.toDouble() ?? -1.0,
    address = jsonMap['vicinity'];

  // for printing
  String toString() => 'Place: $name';
}

// Futures work approximately like empty data placeholders that will be
// filled in the future with a specific format of data
Future<Stream<Place>> getPlaces(double latitude, double longitude) async {
  var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json' +
    '?location=$lat,$lng' +
    '&radius=500&type=restaurant' +
    '&key=AIzaSyADSFtKbtd4IQQII7PfPP0BpLndppaQpAg';

 // native parsing with stream
 // streams return multiple parts of data
 // here, we can return each individual place (restaurant)
 var client = new http.Client();
 var streamedRes = await client.send(
   new http.Request('get', Uri.parse(url))
 ); // client.send

  // transform the raw data stream into a stream of Place objects
  // using bin-to-string decoding, JSON transforming, and JSON mapping
  return streamedRes.stream
    .transform(utf8.decoder)
    .transform(json.decoder)
    .expand((jsonBody) => (jsonBody as Map)['results'])
    .map((jsonPlace) => new Place.fromJson(jsonPlace));
}