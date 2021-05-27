import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onlineTaxiApp/Assistants/assistantMethods.dart';
import 'package:onlineTaxiApp/DataHandler/appData.dart';
import 'package:onlineTaxiApp/screens/Divider.dart';
import 'package:onlineTaxiApp/screens/SearchBar/SearchBar.dart';
import 'package:onlineTaxiApp/utilities/configMaps.dart';
import 'package:onlineTaxiApp/utilities/constants.dart';
import 'package:provider/provider.dart';

class MainAppPage extends StatefulWidget {
  @override
  _MainAppPageState createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController newGoogleMapController;
  final db = FirebaseFirestore.instance;
  Position currentPosition;
  LatLng currenLocation = LatLng(33.65258674284576, 73.07084250411232);
  LatLng destLocation = LatLng(33.69817543885961, 73.07077813109619);
  String userNum;
  var geoLocator = Geolocator();
  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng positionLatLing = LatLng(position.altitude, position.latitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionLatLing, zoom: 14);
    currenLocation = LatLng(33.65258674284576, 73.07084250411232);
    String address =
        await AssistantsMethods.searchCoordinatesAddress(position, context);
    print(address);
    setState(() {
      userLocation = address;
    });
  }

  Set<Marker> _marker = Set<Marker>();
  String userLocation;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
  }

  void showPinsOnMap() {
    var intialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    LatLng pickUpLatng = LatLng(intialPos.latitude, intialPos.longitude);

    LatLng dropOffLatng = LatLng(finalPos.latitude, finalPos.longitude);
    setState(() {
      _marker.add(Marker(
        markerId: MarkerId("StartLoc"),
        position: pickUpLatng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      ));
      _marker.add(Marker(
        markerId: MarkerId("EndLoc"),
        position: dropOffLatng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          "Online Taxi App",
          style: TextStyle(
            color: title,
            fontFamily: 'OpenSans',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 250,
              child: DrawerHeader(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: primary,
                      backgroundImage: NetworkImage(
                          FirebaseAuth.instance.currentUser.photoURL != null
                              ? FirebaseAuth.instance.currentUser.photoURL
                              : photoURL),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    FirebaseAuth.instance.currentUser.displayName != null
                        ? Text(
                            FirebaseAuth.instance.currentUser.displayName,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'OpenSans',
                              fontSize: 25.0,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        : CircularProgressIndicator(
                            backgroundColor: Colors.blue),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "View Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: primary,
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 30,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    " History ",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'OpenSans',
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              onTap: () {},
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.settings,
                    size: 30,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    " Settings ",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'OpenSans',
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              onTap: () {},
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 30,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    " About ",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'OpenSans',
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Stack(children: [
        GoogleMap(
          padding: EdgeInsets.only(
              bottom: Provider.of<AppData>(context).pickUpLocation == null
                  ? 270
                  : 330.0),
          myLocationEnabled: true,
          compassEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
          polylines: _polylines,
          markers: _marker,
          myLocationButtonEnabled: true,
          initialCameraPosition:
              CameraPosition(target: LatLng(33.6844, 73.0479), zoom: 12),
          onMapCreated: (GoogleMapController _controller) {
            _googleMapController.complete(_controller);
            newGoogleMapController = _controller;
            locatePosition();
            if (Provider.of<AppData>(context, listen: false).dropOffLocation !=
                null) {
              showPinsOnMap();
            }
          },
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                height: Provider.of<AppData>(context).pickUpLocation == null
                    ? 270
                    : Provider.of<AppData>(context)
                            .pickUpLocation
                            .placeName
                            .length
                            .toDouble() +
                        290,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: priText,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 6,
                      ),
                      Provider.of<AppData>(context).pickUpLocation == null
                          ? SizedBox(
                              height: 8,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "You're here",
                                  style:
                                      TextStyle(fontSize: 12, color: priText),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  Provider.of<AppData>(context)
                                      .pickUpLocation
                                      .placeName,
                                  style: TextStyle(fontSize: 20, color: scText),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Where To",
                        style: TextStyle(fontSize: 15, color: priText),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Provider.of<AppData>(context, listen: false)
                                  .dropOffLocation ==
                              null
                          ? GestureDetector(
                              onTap: () async {
                                var res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchBar()));
                                if (res == "obtainDirection") {
                                  await getPlaceDirction();
                                }
                              },
                              child: Container(
                                  width: 350,
                                  height: 44,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      enabled: false,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: primary,
                                        ),
                                        contentPadding: EdgeInsets.all(10),
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText: 'Search Destination',
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
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: priText,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          spreadRadius: 0)
                                    ],
                                  )),
                            )
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      Provider.of<AppData>(context)
                                          .dropOffLocation
                                          .placeName,
                                      style: TextStyle(
                                          fontSize: 20, color: scText),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        var res = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchBar()));
                                        if (res == "obtainDirection") {
                                          await getPlaceDirction();
                                        }
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        color: primary,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Confirm Ride",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'OpenSans',
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(
                                  height: 1,
                                  color: Colors.amberAccent,
                                  thickness: 2,
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      Provider.of<AppData>(context).dropOffLocation == null
                          ? Column(
                              children: [
                                ListTile(
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.home,
                                          color: Colors.grey,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Add Home ",
                                              style: TextStyle(
                                                  fontSize: 20, color: scText),
                                            ),
                                            Text(
                                              "Add your Home Addreas.",
                                              style: TextStyle(
                                                  fontSize: 12, color: scText),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    onTap: () {}),
                                DividerW(),
                                ListTile(
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.work,
                                        color: Colors.grey,
                                        size: 35,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Add Work ",
                                            style: TextStyle(
                                                fontSize: 20, color: scText),
                                          ),
                                          Text(
                                            "Add your Office or Work Addreas.",
                                            style: TextStyle(
                                                fontSize: 12, color: scText),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  onTap: () {},
                                )
                              ],
                            )
                          : SizedBox()
                    ],
                  ),
                ),
              ),
            ))
      ]),
    );
  }

  Future<Widget> getPlaceDirction() async {
    var intialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatng = LatLng(intialPos.latitude, intialPos.longitude);

    var dropOffLatng = LatLng(finalPos.latitude, finalPos.longitude);

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
                    Text("Please Wait........ ")
                  ],
                ),
              ),
            ));
    var details =
        await AssistantsMethods.getDirectionDetails(pickUpLatng, dropOffLatng);
    Navigator.pop(context);
    print("Polylines" + details.encodedPoints);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinesPoints =
        polylinePoints.decodePolyline(details.encodedPoints);
    polylineCoordinates.clear();
    if (decodePolylinesPoints.isNotEmpty) {
      decodePolylinesPoints.forEach((PointLatLng pointLatLng) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("PolyllineID"),
          color: Colors.lightBlueAccent,
          jointType: JointType.round,
          points: polylineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);
      _polylines.add(polyline);
    });
  }
}
