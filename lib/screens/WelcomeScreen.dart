import 'package:flutter/material.dart';
import 'package:onlineTaxiApp/screens/HomeScreen.dart';
import '../auth_services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:onlineTaxiApp/utilities/constants.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool showNum = true;
  String user;
  bool proceeing = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController phonectrl = new TextEditingController();

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    print(showNum);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Online Taxi App",
          style: TextStyle(
            color: title,
            fontFamily: 'OpenSans',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: FlatButton(
              onPressed: () {
                AuthService(FirebaseAuth.instance).signOut();
                AuthService(FirebaseAuth.instance).signOutGoogle();
              },
              child: Icon(
                Icons.logout,
                color: title,
              ),
            ),
          )
        ],
        backgroundColor: primary,
      ),
      body: Stack(children: <Widget>[
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                ],
                stops: [0.1, 0.4, 0.7, 0.9],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(FirebaseAuth
                                .instance.currentUser.photoURL !=
                            null
                        ? FirebaseAuth.instance.currentUser.photoURL
                        : 'https://cdn2.iconfinder.com/data/icons/green-2/32/expand-color-web2-23-512.png'),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Welcome To the App.',
                    style: TextStyle(
                      color: priText,
                      fontFamily: 'OpenSans',
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  FirebaseAuth.instance.currentUser.displayName != null
                      ? Text(
                          FirebaseAuth.instance.currentUser.displayName,
                          style: TextStyle(
                            color: priText,
                            fontFamily: 'OpenSans',
                            fontSize: 30.0,
                            fontWeight: FontWeight.normal,
                          ),
                        )
                      : CircularProgressIndicator(backgroundColor: Colors.blue),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  showNum == false ? _buildPhoneTF() : showNumber(),
                  SizedBox(
                    height: 20.0,
                  ),
                  _buildSignUpBtn(context),
                  SizedBox(height: 20.0),
                  Text(
                    '- OR -',
                    style: TextStyle(
                      color: priText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  _buildLogOutBtn(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Future getuser() async {}

  StreamBuilder<QuerySnapshot> showNumber() {
    return StreamBuilder(
      stream: getTripsStream(),
      builder: (context, snapshot) {
        print(snapshot);
        if (!snapshot.hasData) {
          return CircularProgressIndicator(backgroundColor: Colors.white);
        } else if (snapshot.data.docs.length == 0) {
          return TextButton(
            onPressed: () {
              setState(() {
                showNum = false;
              });
            },
            child: Text("Add Phone No", style: TextStyle(color: priText)),
          );
        } else {
          return showNum == true
              ? Text(
                  snapshot.data.docs[0]['phoneNo'],
                  style: TextStyle(
                    color: scText,
                    fontFamily: 'OpenSans',
                    fontSize: 30.0,
                    fontWeight: FontWeight.normal,
                  ),
                )
              : CircularProgressIndicator(backgroundColor: Colors.white);
        }
      },
    );
  }

  Row _buildPhoneTF() {
    showNum = false;

    return Row(
      children: [
        SizedBox(
          width: 10,
        ),
        Container(
          margin: EdgeInsets.only(top: 25),
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          width: 75,
          child: Center(
            child: Row(
              children: [
                SizedBox(
                  width: 8,
                ),
                Image.asset(
                  'assets/flag-wave-250.png',
                  width: 30.0,
                  height: 30.0,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "+92",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        _buildPhoneNoTF(),
        TextButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                AuthService(FirebaseAuth.instance)
                    .addPhoneNo("+92" + phonectrl.text)
                    .then((value) => {
                          value == "Success"
                              ? setState(() {
                                  showNum = true;
                                })
                              : showNum = false
                        });
                print(showNum);
              } else {}
            },
            child: Container(
              margin: EdgeInsets.only(top: 25),
              alignment: Alignment.centerLeft,
              decoration: kBoxDecorationStyle,
              height: 60.0,
              width: 50,
              child: Center(
                child: Text(
                  "Go",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ))
      ],
    );
  }

  Widget _buildSignUpBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: 200,
      child: RaisedButton(
          elevation: 5.0,
          onPressed: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MainAppPage()))
              },
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Colors.white,
          child: Text(
            'Get Started ',
            style: TextStyle(
              color: primary,
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          )),
    );
  }

  Widget _buildLogOutBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: 200,
      child: RaisedButton(
          elevation: 5.0,
          onPressed: () {
            AuthService(FirebaseAuth.instance).signOut();
            AuthService(FirebaseAuth.instance).signOutGoogle();
          },
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Colors.white,
          child: Text(
            'Log Out',
            style: TextStyle(
              color: primary,
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          )),
    );
  }

  Widget _buildPhoneNoTF() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 100),
            child: Text(
              'Phone No.',
              style: TextStyle(color: priText),
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            width: 220,
            child: TextFormField(
              controller: phonectrl,
              validator: PhoneValidator.validate,
              obscureText: false,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14.0),
                hintText: 'Enter your Phone No.',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> getTripsStream() async* {
    yield* db
        .collection('userData')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('usersData')
        .snapshots();
  }
}
