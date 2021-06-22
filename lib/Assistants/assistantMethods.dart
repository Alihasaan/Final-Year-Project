import 'dart:math';

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
    String? st1, st2, st3;
    String placeAddress = "Null";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$GoogleMapsAPI";

    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      st1 = response['results'][0]["address_components"][0]['long_name'];
      st2 = response['results'][0]["address_components"][1]['long_name'];
      st3 = response['results'][0]["address_components"][2]['long_name'];

      placeAddress = st1! + ", " + st2! + ", " + st3!;

      Address userPickLoc = new Address();
      userPickLoc.latitude = position.latitude;
      userPickLoc.longitude = position.longitude;
      userPickLoc.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false)
          .updateUserPickupLOcation(userPickLoc);
    }
    return placeAddress;
  }

  static Future<DriectionDetails?> getDirectionDetails(
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

  static int calculateTRideFares(DriectionDetails driectionDetails) {
    double timeTraveledFare = (driectionDetails.durationValue! / 60) * 0.05;
    double distanceTraveledFare =
        (driectionDetails.distanceValue! / 1000) * 0.10;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;
    double totalInRupees;
    totalInRupees = totalFareAmount * 155;
    return totalInRupees.truncate();
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }
}
