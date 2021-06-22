import 'dart:ffi';

import 'package:onlineTaxiApp/Models/driverNear.dart';

class GeoFireAssistants {
  static List<NearbyDrivers> nearByDriversList = [];
  static void removeDriverfromList(String key) {
    int index = nearByDriversList.indexWhere((element) => element.Key == key);
    nearByDriversList.removeAt(index);
  }

  static void updateDriverLocation(NearbyDrivers Driver) {
    int index =
        nearByDriversList.indexWhere((element) => element.Key == Driver.Key);
    nearByDriversList[index].latitude = Driver.latitude;
    nearByDriversList[index].longitude = Driver.longitude;
  }
}
