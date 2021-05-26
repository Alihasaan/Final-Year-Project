import 'package:geolocator/geolocator.dart';
import 'package:onlineTaxiApp/Assistants/requestAssistants.dart';
import 'package:onlineTaxiApp/DataHandler/appData.dart';
import 'package:onlineTaxiApp/Models/address.dart';
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
}
