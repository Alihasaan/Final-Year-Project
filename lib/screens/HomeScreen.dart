import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onlineTaxiApp/screens/Divider.dart';
import 'package:onlineTaxiApp/utilities/configMaps.dart';
import 'package:onlineTaxiApp/utilities/constants.dart';

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
    currentPosition = position;

    LatLng positionLatLing = LatLng(position.altitude, position.latitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionLatLing, zoom: 14);
  }

  Set<Marker> _marker = Set<Marker>();

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
  }

  void setPolylines() async {
    print(
        "------------------------------------------------------------Polylines---------------------------------------------");
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      "AIzaSyAq2xonoSe1RK1UGm4oNeYU7_z_lS6T9og",
      PointLatLng(currenLocation.latitude, currenLocation.longitude),
      PointLatLng(destLocation.latitude, destLocation.longitude),
    );
    print("Status : " + result.status);
    if (result.status == "OK") {
      print(result.status);
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      _polylines.add(Polyline(
        width: 7,
        polylineId: PolylineId("polyline"),
        color: Colors.lightGreen,
        points: polylineCoordinates,
      ));
    });
  }

  void showPinsOnMap() {
    setState(() {
      _marker.add(Marker(
        markerId: MarkerId("StartLoc"),
        position: currenLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
      _marker.add(Marker(
        markerId: MarkerId("EndLoc"),
        position: destLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
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
                      backgroundImage: NetworkImage(FirebaseAuth
                                  .instance.currentUser.photoURL !=
                              null
                          ? FirebaseAuth.instance.currentUser.photoURL
                          : 'https://cdn2.iconfinder.com/data/icons/green-2/32/expand-color-web2-23-512.png'),
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
            if (currenLocation.latitude != 0 && currenLocation.longitude != 0) {
              showPinsOnMap();

              setPolylines();
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
                height: 300.0,
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
                      Text(
                        "Hi there",
                        style: TextStyle(fontSize: 12, color: priText),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Where To",
                        style: TextStyle(fontSize: 20, color: priText),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                          width: 350,
                          height: 44,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: primary,
                                ),
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
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: priText,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  spreadRadius: 0)
                            ],
                          )),
                      SizedBox(
                        height: 20,
                      ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add Home ",
                                    style:
                                        TextStyle(fontSize: 20, color: scText),
                                  ),
                                  Text(
                                    "Add your Home Addreas.",
                                    style:
                                        TextStyle(fontSize: 12, color: scText),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Work ",
                                  style: TextStyle(fontSize: 20, color: scText),
                                ),
                                Text(
                                  "Add your Office or Work Addreas.",
                                  style: TextStyle(fontSize: 12, color: scText),
                                )
                              ],
                            )
                          ],
                        ),
                        onTap: () {},
                      )
                    ],
                  ),
                ),
              ),
            ))
      ]),
    );
  }
}
