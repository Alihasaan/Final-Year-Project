import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onlineTaxiApp/Assistants/assistantMethods.dart';
import 'package:onlineTaxiApp/Assistants/geofireAssistant.dart';
import 'package:onlineTaxiApp/DataHandler/appData.dart';
import 'package:onlineTaxiApp/Models/directionDetails.dart';
import 'package:onlineTaxiApp/Models/driverModel.dart';
import 'package:onlineTaxiApp/Models/driverNear.dart';
import 'package:onlineTaxiApp/Models/users_model.dart';
import 'package:onlineTaxiApp/main.dart';
import 'package:onlineTaxiApp/screens/Divider.dart';
import 'package:onlineTaxiApp/screens/SearchBar/SearchBar.dart';
import 'package:onlineTaxiApp/screens/Widgets/DriverDetailsPage.dart';
import 'package:onlineTaxiApp/utilities/configMaps.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:onlineTaxiApp/utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class MainAppPage extends StatefulWidget {
  final UserModel? currentUser;

  const MainAppPage({Key? key, this.currentUser}) : super(key: key);

  get app => null;
  @override
  _MainAppPageState createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  Completer<GoogleMapController> _googleMapController = Completer();
  late GoogleMapController newGoogleMapController;
  String appState = "normal";
  String rideState = "normal";
  DriverModel driverDetails = DriverModel();
  late Position currentPosition;

  late StreamSubscription rideStreamSub;
  List<NearbyDrivers> availableDrivers = [];
  LatLng destLocation = LatLng(33.69817543885961, 73.07077813109619);
  String? userNum;
  var geoLocator = Geolocator();
  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
    });
    LatLng positionLatLing = LatLng(position.altitude, position.latitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionLatLing, zoom: 14);

    String address =
        await AssistantsMethods.searchCoordinatesAddress(position, context);
    print(address);
    setState(() {
      userLocation = address;
    });
    print("!----------------------Current Pos :");
    print(currentPosition);
    intiializeGeoFire();
  }

  bool nearbyDriverKeyLoaded = false;
  Set<Marker> _marker = Set<Marker>();
  Set<Circle> _circle = {};
  String? userLocation;
  bool requestRide = false;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

  late DatabaseReference _rideRefDB;
  late DatabaseReference _driverRefDB;
  late BitmapDescriptor nearByDriverIcon;

  DriectionDetails? tripDetails;

  @override
  void initState() {
    super.initState();

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(1, 1)), "assets/taxi_logo.png")
        .then((value) {
      nearByDriverIcon = value;
    });
    fireDatabase();
  }

  void fireDatabase() async {
    final FirebaseApp app = await Firebase.initializeApp();
    final FirebaseDatabase database = FirebaseDatabase(app: app);
    _rideRefDB = database.reference().child('ride_requests').push();
    _driverRefDB = database.reference().child('Drivers');
    print("!---------------");
    print(_rideRefDB);
  }

  Widget rideRequested() {
    const colorizeColors = [
      Colors.greenAccent,
      Colors.purple,
      Colors.lightBlueAccent,
      Colors.amberAccent,
      Colors.pinkAccent
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 55.0,
      fontFamily: 'Signatra',
      fontWeight: FontWeight.normal,
    );
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: priText,
                blurRadius: 16,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SizedBox(
                  width: 250,
                  child: AnimatedTextKit(
                    totalRepeatCount: 5,
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Confirming Ride',
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                      ColorizeAnimatedText(
                        'Please Wait...',
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                      ColorizeAnimatedText(
                        'Finding Drivers',
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                    ],
                    isRepeatingAnimation: true,
                    onTap: () {
                      print("Tap Event");
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: IconButton(
                    icon: Icon(
                      Icons.cancel_sharp,
                      size: 60,
                      color: primary,
                    ),
                    onPressed: () {
                      setState(() {
                        requestRide = false;
                        appState = "normal";
                      });
                      _rideRefDB.remove();
                    }),
              ),
              SizedBox(
                height: 35,
              ),
              Text("    Cancel Ride ",
                  style: TextStyle(fontSize: 14, color: scText))
            ],
          ),
        ),
      ),
    );
  }

  Widget rideDetailForm() {
    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: 330,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                    color: priText,
                    blurRadius: 16,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 1,
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
                                style: TextStyle(fontSize: 15, color: priText),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                Provider.of<AppData>(context)
                                    .pickUpLocation!
                                    .placeName!,
                                style: TextStyle(fontSize: 20, color: scText),
                              ),
                            ],
                          ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Where To",
                      style: TextStyle(fontSize: 15, color: priText),
                    ),
                    SizedBox(
                      height: 0,
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
                                      contentPadding: EdgeInsets.all(8),
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
                                  Flexible(
                                    child: Text(
                                      Provider.of<AppData>(context)
                                          .dropOffLocation!
                                          .placeName!,
                                      maxLines: 3,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 20, color: scText),
                                    ),
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
                              Row(
                                children: [
                                  Container(
                                    height: 90,
                                    width: 120,
                                    child: Image.asset(
                                      "assets/taxi.jpg",
                                    ),
                                  ),
                                  Container(
                                    width: 220,
                                    height: 59,
                                    color: Colors.lightBlueAccent[100],
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Taxi",
                                              style: TextStyle(
                                                  fontFamily: 'OpenSans',
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              tripDetails != null
                                                  ? tripDetails!.distanceText!
                                                  : "",
                                              style: TextStyle(
                                                  fontFamily: 'OpenSans',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          width: 70,
                                        ),
                                        Expanded(
                                          child: Text(
                                            tripDetails != null
                                                ? "\Rs. ${AssistantsMethods.calculateTRideFares(tripDetails!)}"
                                                : "",
                                            style: TextStyle(
                                                fontFamily: 'OpenSans',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on_outlined,
                                    size: 22,
                                    color: priText,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Cash",
                                    style:
                                        TextStyle(fontSize: 17, color: priText),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: priText,
                                    size: 20,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: 160,
                                height: 50,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 90,
                                ),
                                color: primary,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.local_taxi,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 11,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            appState = "requestingRide";
                                            requestRide = true;
                                            availableDrivers = GeoFireAssistants
                                                .nearByDriversList;
                                          });
                                          searchNearestDriver();
                                          sendRideRequest();
                                        },
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
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 0,
                              ),
                            ],
                          ),
                    SizedBox(
                      height: 8,
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
          ),
        ));
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
                      backgroundImage:
                          (FirebaseAuth.instance.currentUser!.photoURL != null
                              ? NetworkImage(FirebaseAuth
                                  .instance.currentUser!.photoURL
                                  .toString()
                                  .replaceAll("s96-c", "s400-c"))
                              : AssetImage(
                                  "assets/user_profile.png",
                                )) as ImageProvider<Object>?,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    FirebaseAuth.instance.currentUser!.displayName != null
                        ? Text(
                            FirebaseAuth.instance.currentUser!.displayName!,
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
          padding: EdgeInsets.only(bottom: requestRide == false ? 330.0 : 240),
          myLocationEnabled: true,
          compassEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
          polylines: _polylines,
          markers: _marker,
          circles: _circle,
          myLocationButtonEnabled: true,
          initialCameraPosition:
              CameraPosition(target: LatLng(33.6844, 73.0479), zoom: 12),
          onMapCreated: (GoogleMapController _controller) {
            _googleMapController.complete(_controller);
            newGoogleMapController = _controller;
            locatePosition();
          },
        ),
        rideState == "normal"
            ? requestRide == false
                ? rideDetailForm()
                : rideRequested()
            : rideAccepted(driverDetails)
      ]),
    );
  }

  Widget rideAccepted(DriverModel driver) {
    return DriverDetails(driver: driver);
  }

  // ignore: missing_return
  Future<Widget> getPlaceDirction() async {
    var intialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation!;
    var finalPos =
        Provider.of<AppData>(context, listen: false).dropOffLocation!;

    var pickUpLatng = LatLng(intialPos.latitude!, intialPos.longitude!);

    var dropOffLatng = LatLng(finalPos.latitude!, finalPos.longitude!);

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
                    Text("Please Wait.......")
                  ],
                ),
              ),
            ));
    DriectionDetails? details = await (AssistantsMethods.getDirectionDetails(
        pickUpLatng, dropOffLatng));
    setState(() {
      tripDetails = details;
    });
    Navigator.pop(context);
    print("Polylines" + details!.encodedPoints!);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinesPoints =
        polylinePoints.decodePolyline(details.encodedPoints!);
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
    LatLngBounds latLngBounds;
    if (pickUpLatng.latitude > dropOffLatng.latitude &&
        pickUpLatng.longitude > dropOffLatng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatng, northeast: pickUpLatng);
    } else if (pickUpLatng.longitude > dropOffLatng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatng.latitude, dropOffLatng.longitude),
          northeast: LatLng(dropOffLatng.latitude, pickUpLatng.longitude));
    } else if (pickUpLatng.latitude > dropOffLatng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatng.latitude, pickUpLatng.longitude),
          northeast: LatLng(pickUpLatng.latitude, dropOffLatng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatng, northeast: dropOffLatng);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    setState(() {
      _marker.add(Marker(
        markerId: MarkerId("StartLoc"),
        position: pickUpLatng,
        infoWindow:
            InfoWindow(title: intialPos.placeName, snippet: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ));
      _marker.add(Marker(
        markerId: MarkerId("EndLoc"),
        position: dropOffLatng,
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: "Your Destination"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ));
    });
    setState(() {
      _circle.add(Circle(
        circleId: CircleId("pickUpCircle"),
        fillColor: Colors.blueAccent,
        center: pickUpLatng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
      ));
      _circle.add(Circle(
        circleId: CircleId("dropOffCircle"),
        fillColor: Colors.amberAccent,
        center: dropOffLatng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.amberAccent,
      ));
    });
    return SizedBox();
  }

  void sendRideRequest() {
    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation!;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation!;
    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };
    Map dropOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };
    Map rideInfoMap = {
      "driver_id": "waiting",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "userid": widget.currentUser!.userID,
      "username": widget.currentUser!.userName,
      "ride-status": "waiting",
      "userphone": widget.currentUser!.userPhoneno,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
      "userphotourl": FirebaseAuth.instance.currentUser!.photoURL == null
          ? "https://cdn2.iconfinder.com/data/icons/avatars-99/62/avatar-370-456322-512.png"
          : FirebaseAuth.instance.currentUser!.photoURL
    };
    print('!----------!Instance');
    print(_rideRefDB);

    _rideRefDB.set(rideInfoMap);
  }

  void intiializeGeoFire() {
    Geofire.initialize("availableDrivers");
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDrivers nearbyDrivers = NearbyDrivers(
                Key: map['key'],
                latitude: map['latitude'],
                longitude: map['longitude']);
            nearbyDrivers.Key = map['key'];
            nearbyDrivers.latitude = map['latitude'];
            nearbyDrivers.longitude = map['longitude'];
            GeoFireAssistants.nearByDriversList.add(nearbyDrivers);
            if (nearbyDriverKeyLoaded == true) {
              updateNearByDriversOnMap();
            }

            break;

          case Geofire.onKeyExited:
            GeoFireAssistants.removeDriverfromList(map['key']);
            updateNearByDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyDrivers nearbyDrivers = NearbyDrivers(
                Key: map['key'],
                latitude: map['latitude'],
                longitude: map['longitude']);
            nearbyDrivers.Key = map['key'];
            nearbyDrivers.latitude = map['latitude'];
            nearbyDrivers.longitude = map['longitude'];
            GeoFireAssistants.updateDriverLocation(nearbyDrivers);
            updateNearByDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            updateNearByDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
  }

  void updateNearByDriversOnMap() {
    print("!-------------!" + "Driver Markers");
    setState(() {
      _marker.clear();
    });
    Set<Marker> dMarkers = Set<Marker>();
    for (NearbyDrivers drivers in GeoFireAssistants.nearByDriversList) {
      LatLng driverCurrentPosition =
          LatLng(drivers.latitude, drivers.longitude);
      Marker marker = Marker(
        markerId: MarkerId('driver${drivers.Key}'),
        position: driverCurrentPosition,
        // ignore: unnecessary_null_comparison
        icon: nearByDriverIcon,
        rotation: AssistantsMethods.createRandomNumber(360),
      );
      dMarkers.add(marker);
    }
    setState(() {
      _marker = dMarkers;
    });
  }

  void createIconMarker() {
    // ignore: unnecessary_null_comparison
    if (nearByDriverIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/taxi_logo.png")
          .then((value) {
        setState(() {
          nearByDriverIcon = value;
        });
      });
    }
  }

  void noDriverFound() {
    Alert(context: context, title: "No Driver Found").show();
    setState(() {
      requestRide = false;
    });
  }

  void searchNearestDriver() {
    if (availableDrivers.length == 0) {
      print("No Driver Found");
      noDriverFound();
      return;
    }
    var driver = availableDrivers[0];
    notifyDriver(driver);
    availableDrivers.removeAt(0);
    print(driver.latitude);
  }

  void notifyDriver(NearbyDrivers drivers) {
    _driverRefDB.child(drivers.Key).child("newRide").set(_rideRefDB.key);
    String token;
    var time;
    _driverRefDB
        .child(drivers.Key)
        .child("token")
        .once()
        .then((DataSnapshot snap) => {
              if (snap.value != null)
                {
                  token = snap.value.toString(),
                  AssistantsMethods.sendRideReqToDriver(
                      token, context, _rideRefDB.key)
                },
              time = Timer.periodic(Duration(seconds: 1), (timer) {
                if (appState != "requestingRide") {
                  _driverRefDB
                      .child(drivers.Key)
                      .child("newRide")
                      .set("cancelled");
                  _driverRefDB
                      .child(drivers.Key)
                      .child("newRide")
                      .onDisconnect();
                }
                rideRequestTimeout = rideRequestTimeout - 1;

                _driverRefDB
                    .child(drivers.Key)
                    .child("newRide")
                    .onValue
                    .listen((event) {
                  if (event.snapshot.value.toString() == "ride-accpted") {
                    rideRequestTimeout = 40;
                    timer.cancel();
                    _driverRefDB.child(drivers.Key).once().then((data) => {
                          if (data.value != null)
                            {
                              setState(() {
                                driverDetails.driverID = drivers.Key;
                                driverDetails.driverName =
                                    data.value["driver_name"];
                                driverDetails.driverPhoneno =
                                    data.value["driver_phone"];
                                driverDetails.driverPhotoUrl =
                                    "https://cdn2.iconfinder.com/data/icons/avatars-99/62/avatar-370-456322-512.png";
                                rideState = "RideAccepted";
                                requestRide = false;
                              }),
                              print("Driver Info : "),
                              print(driverDetails)
                            }
                        });
                    _driverRefDB
                        .child(drivers.Key)
                        .child("newRide")
                        .onDisconnect();
                  }
                });
                if (rideRequestTimeout == 0) {
                  _driverRefDB
                      .child(drivers.Key)
                      .child("newRide")
                      .set("Request Time Out");
                  _driverRefDB
                      .child(drivers.Key)
                      .child("newRide")
                      .onDisconnect();
                  rideRequestTimeout = 40;
                  timer.cancel();
                  noDriverFound();
                  //searchNearestDriver();
                }
              })
            });
  }
}
