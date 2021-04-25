import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onlineTaxiApp/screens/Divider.dart';

class MainAppPage extends StatefulWidget {
  @override
  _MainAppPageState createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController newGoogleMapController;
  final db = FirebaseFirestore.instance;
  Position currentPosition;
  String userNum;
  var geoLocator = Geolocator();
  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng positionLatLing = LatLng(position.altitude, position.latitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionLatLing, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Text(
          "Online Taxi App",
          style: TextStyle(
            color: Colors.grey[800],
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
                      backgroundImage: NetworkImage(FirebaseAuth
                                  .instance.currentUser.photoURL !=
                              null
                          ? FirebaseAuth.instance.currentUser.photoURL
                          : 'https://www.kindpng.com/picc/m/459-4595992_business-user-account-png-image-blue-link-icon.png'),
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
                            backgroundColor: Colors.red),
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
                  color: Colors.yellow[700],
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
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition:
              CameraPosition(target: LatLng(33.6844, 73.0479), zoom: 12),
          onMapCreated: (GoogleMapController _controller) {
            _googleMapController.complete(_controller);
            newGoogleMapController = _controller;
            locatePosition();
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
                        color: Colors.black54,
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Where To",
                        style: TextStyle(fontSize: 20, color: Colors.grey[800]),
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
                                  color: Colors.amberAccent,
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
                                  color: Colors.black54,
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
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey[800]),
                                  ),
                                  Text(
                                    "Add your Home Addreas.",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[800]),
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
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.grey[800]),
                                ),
                                Text(
                                  "Add your Office or Work Addreas.",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[800]),
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
