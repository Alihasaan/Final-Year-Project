import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onlineTaxiApp/Models/address.dart';

class RequestAssistant {
  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        print("!-------------------Response SuccesFull---------------------!");
        String jsonData = response.body;
        var decodeData = jsonDecode(jsonData);
        //String result = decodeData;
        //print(decodeData['results'][0]["formatted_address"]);

        return decodeData;
      } else {
        return "failed";
      }
    } catch (exp) {
      return "failed";
    }
  }
}
