import 'package:geolocator/geolocator.dart';
import 'package:onlineTaxiApp/Assistants/requestAssistants.dart';
import 'package:onlineTaxiApp/utilities/configMaps.dart';

class AssistantsMethods {
  static Future<String> searchCoordinatesAddress(Position position) async {
    String placeAddress = "Null";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$GoogleMapsAPI";

    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      placeAddress = response;
      return placeAddress;
    }
  }
}
