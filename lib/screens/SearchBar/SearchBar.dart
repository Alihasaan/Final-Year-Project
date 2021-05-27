import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlineTaxiApp/DataHandler/appData.dart';
import 'package:onlineTaxiApp/Models/address.dart';
import 'package:onlineTaxiApp/Models/placePredictions.dart';
import 'package:onlineTaxiApp/screens/Divider.dart';
import 'package:onlineTaxiApp/utilities/configMaps.dart';
import 'package:onlineTaxiApp/utilities/constants.dart';
import 'package:onlineTaxiApp/Assistants/requestAssistants.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  List<PlacePredictions> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: primary,
              padding: const EdgeInsets.only(top: 10.0, left: 5, bottom: 10),
              child: Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Search Drop Off",
                      style: TextStyle(
                        color: scText,
                        fontFamily: 'AlegreyaSansSC',
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Icon(
                                Icons.pin_drop,
                                color: Colors.indigoAccent,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              new Container(
                                  width: 300,
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      enabled: Provider.of<AppData>(context)
                                                  .pickUpLocation ==
                                              null
                                          ? true
                                          : false,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText: Provider.of<AppData>(context)
                                                    .pickUpLocation ==
                                                null
                                            ? 'From'
                                            : Provider.of<AppData>(context)
                                                .pickUpLocation
                                                .placeName,
                                        labelStyle: TextStyle(
                                          fontFamily: 'AlegreyaSansSC',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: new BoxDecoration(
                                    color: Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black54,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          spreadRadius: 0)
                                    ],
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Icon(
                                Icons.pin_drop,
                                color: Colors.amberAccent,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                  width: 300,
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      onChanged: (val) {
                                        findPlace(val);
                                      },
                                      enableSuggestions: true,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        enabledBorder: InputBorder.none,
                                        hintText: 'To',
                                        labelStyle: TextStyle(
                                          fontFamily: 'AlegreyaSansSC',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: new BoxDecoration(
                                    color: Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black54,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          spreadRadius: 0)
                                    ],
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(
                            height: 1,
                            color: primary,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            placePredictionList.length > 0
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: ListView.separated(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.all(0),
                        itemBuilder: (context, index) {
                          return PredictionTitle(
                            placePredictions: placePredictionList[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(
                              height: 5,
                            ),
                        itemCount: placePredictionList.length),
                  )
                : Container(
                    padding: EdgeInsets.only(),
                    child: Center(
                      heightFactor: 10,
                      child: Icon(
                        Icons.location_city_outlined,
                        color: primary,
                        size: 50,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$GoogleMapsAPI&sessiontoken=1234567890&components=country:pk";
      var res = await RequestAssistant.getRequest(autoCompleteUrl);
      if (res == "failed") {
        print("Request Failed");
        return;
      }
      if (res['status'] == 'OK') {
        var predictions = res['predictions'];
        var placeList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        setState(() {
          placePredictionList = placeList;
        });
      }
    }
  }
}

class PredictionTitle extends StatelessWidget {
  final PlacePredictions placePredictions;
  PredictionTitle({Key key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: TextButton(
      onPressed: () {
        getPlacesDetails(placePredictions.place_id, context);
      },
      child: Card(
        child: ListTile(
          leading: Icon(
            Icons.pin_drop_outlined,
            color: Colors.amber[400],
          ),
          title: Text(
            placePredictions.main_text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20, color: Colors.grey[700]),
          ),
          subtitle: Text(
            placePredictions.secondary_text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20, color: priText),
          ),
        ),
      ),
    ) /*Column(
        children: [
          SizedBox(
            width: 10,
          ),
          Row(
            children: [
              Icon(
                Icons.pin_drop_outlined,
                color: Colors.amber[400],
              ),
              SizedBox(
                width: 14,
              ),
              Container(
                child: Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placePredictions.main_text,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      placePredictions.secondary_text,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 20, color: priText),
                    ),
                    SizedBox(
                      width: 15,
                    )
                  ],
                )),
              )
            ],
          ),
          
        ],
        
      ),
      */
        );
  }

  void getPlacesDetails(String placeID, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 20,
                    ),
                    Text("Seting Location........ ")
                  ],
                ),
              ),
            ));
    String placeDetailsRul =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$GoogleMapsAPI";
    var res = await RequestAssistant.getRequest(placeDetailsRul);
    Navigator.pop(context);
    if (res == "failed") {
      return;
    }
    if (res['status'] == "OK") {
      Address address = new Address();
      address.placeName = res['result']['name'];
      address.placeID = placeID;
      address.latitude = res['result']['geometry']['location']['lat'];
      address.longitude = res['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateUserDropOffLOcation(address);
      //print(address.placeName);
      Navigator.pop(context, "obtainDirection");
    }
  }
}
