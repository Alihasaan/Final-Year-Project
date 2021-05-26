import 'package:flutter/material.dart';
import 'package:onlineTaxiApp/Models/address.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation, dropOffLocation;
  void updateUserPickupLOcation(Address pickUpLoc) {
    pickUpLocation = pickUpLoc;
    notifyListeners();
  }

  void updateUserDropOffLOcation(Address dropOffLoc) {
    pickUpLocation = dropOffLoc;
    notifyListeners();
  }
}
