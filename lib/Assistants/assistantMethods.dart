import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onlineTaxiApp/Assistants/requestAssistants.dart';
import 'package:onlineTaxiApp/DataHandler/appData.dart';
import 'package:onlineTaxiApp/Models/address.dart';
import 'package:onlineTaxiApp/Models/directionDetails.dart';
import 'package:onlineTaxiApp/utilities/configMaps.dart';
import 'package:provider/provider.dart';

class AssistantsMethods {
  static Future<String> searchCoordinatesAddress(
      Position position, context) async {
    String placeAddress = "Null";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$GoogleMapsAPI";

    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      placeAddress = response['results'][0]["formatted_address"];

      Address userPickLoc = new Address();
      userPickLoc.latitude = position.latitude;
      userPickLoc.longitude = position.longitude;
      userPickLoc.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false)
          .updateUserPickupLOcation(userPickLoc);
    }
    return placeAddress;
  }

  static Future<DriectionDetails> getDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionURL =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$GoogleMapsAPI";
    var res = await RequestAssistant.getRequest(directionURL);
    if (res == "failed") {
      print("!-------------Polylines ---------------------!");
      print(res);
      return null;
    }
    DriectionDetails directionDetails = DriectionDetails();
    directionDetails.encodedPoints =
        res['routes'][0]['overview_polyline']['points'];
    directionDetails.distanceText =
        res['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue =
        res['routes'][0]['legs'][0]['distance']['value'];
    directionDetails.durationText =
        res['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue =
        res['routes'][0]['legs'][0]['duration']['value'];
    print("!-------------Polylines ---------------------!");
    print(directionDetails.encodedPoints);
    return directionDetails;
  }
}
