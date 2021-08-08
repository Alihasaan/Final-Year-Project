import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:onlineTaxiApp/DataHandler/appData.dart';
import 'package:onlineTaxiApp/auth_services.dart';
import 'package:onlineTaxiApp/utilities/configMaps.dart';
import 'package:onlineTaxiApp/utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'screens/WelcomeScreen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_database/firebase_database.dart';

late final DatabaseReference db;
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final FirebaseApp app = await Firebase.initializeApp();
    db = FirebaseDatabase(app: app).reference();
  } on FirebaseException catch (e) {
    print(e.message);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppData(),
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: MaterialApp(
            title: 'Online Taxi Ap',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Scaffold(
              body: Center(
                  child: Container(
                child: AuthService(FirebaseAuth.instance).handleAuth(),
              )),
            ),
          ),
        ));
  }
}

class LogInSignUp extends StatefulWidget {
  @override
  _LogInSignUpState createState() => _LogInSignUpState();
}

class _LogInSignUpState extends State<LogInSignUp> {
  @override
  TextEditingController? emailctrl, passctrl, namectrl, phonectrl;
  TextEditingController emailFctrl = new TextEditingController();
  TextEditingController emailSignUpctrl = new TextEditingController();
  TextEditingController errorControl = new TextEditingController();
  bool _obscureText = true;
  bool signin = true;
  bool processing = false;
  bool clicked = false;

  String? Cerror;
  FirebaseAuth? auth;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    emailctrl = new TextEditingController();
    emailFctrl = new TextEditingController();
    passctrl = new TextEditingController();
    namectrl = new TextEditingController();
    phonectrl = new TextEditingController();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.only(left: 20.0),
            child: FlatButton(
              onPressed: () {},
              child: Icon(
                Icons.login_rounded,
                color: title,
              ),
            ),
          )
        ],
        backgroundColor: primary,
      ),
      body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
              color: Colors.white,
              height: double.infinity,
              child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/logo.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      showAlert(),
                      boxUi(),
                      SizedBox(
                        height: 35,
                      ),
                      signInGoogleButton(),
                    ],
                  )))),
    );
  }

  void changeState() {
    if (signin) {
      setState(() {
        signin = false;
      });
    } else
      setState(() {
        signin = true;
      });
  }

  void registerUser() async {
    setState(() {
      processing = true;
    });

    await AuthService(FirebaseAuth.instance)
        .signUp(
          emailctrl!.text,
          passctrl!.text,
          namectrl!.text,
        )
        .then((value) => setState(() {
              Cerror = value;
            }));
    ;

    setState(() {
      processing = false;
    });
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _hideShow() {
    setState(() {
      clicked = !clicked;
    });
  }

  userSignIn() async {
    String temp;
    setState(() {
      processing = true;
    });

    await AuthService(FirebaseAuth.instance)
        .signIn(emailctrl!.text, passctrl!.text)
        .then((value) => setState(() {
              Cerror = value;
            }));
    setState(() {
      processing = false;
    });
  }

  Widget showAlert() {
    if (Cerror != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.redAccent,
        ),
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: AutoSizeText(
                Cerror!,
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    Cerror = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }

  Widget boxUi() {
    return Column(
      children: [
        Card(
          elevation: 10.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () => changeState(),
                      child: Text(
                        'SIGN IN',
                        style: TextStyle(
                          color: signin == true ? primary : Colors.grey,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () => {
                        changeState(),
                        emailctrl!.text = "",
                        namectrl!.text = "",
                        passctrl!.text = ""
                      },
                      child: Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: signin != true ? primary : Colors.grey,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                signin == true ? signInUi() : signUpUi(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget forgoetPassword() {
    String error = "";
    return Padding(
      padding: const EdgeInsets.only(right: 1.0),
      child: Container(
          child: MaterialButton(
              onPressed: () => {
                    Alert(
                        context: context,
                        title: "Reset Password",
                        content: Column(
                          children: <Widget>[
                            Icon(
                              Icons.email,
                              color: primary,
                              size: 60,
                            ),
                            Text(
                              "Enter Your email for Password reset.",
                              style: TextStyle(
                                color: priText,
                                fontFamily: 'OpenSans',
                                fontSize: 20.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: errorControl,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontFamily: 'OpenSans',
                                fontSize: 20.0,
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: ""),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: emailFctrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email,
                                  ),
                                  hintText: 'Email'),
                            ),
                            DialogButton(
                              onPressed: () {
                                if (emailFctrl.text.isNotEmpty) {
                                  AuthService(FirebaseAuth.instance)
                                      .resetPassword(emailFctrl.text);
                                  Navigator.pop(context);
                                } else if (emailFctrl.text.isEmpty) {
                                  errorControl.text = "Email cannot be empty";
                                }

                                print(emailFctrl.text);
                              },
                              child: Text(
                                "Send",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            )
                          ],
                        ),
                        buttons: []).show()
                  },
              child: Text(
                'Forgot Password',
                style: TextStyle(fontSize: 12.0, color: primary),
              ))),
    );
  }

  Widget signInUi() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Your Email :",
              style: TextStyle(fontSize: 15, color: priText),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: Theme(
                data: new ThemeData(
                  primaryColor: primary,
                  primaryColorDark: Colors.red,
                ),
                child: new TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email Can not be empty.";
                    }
                  },
                  controller: emailctrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: new BorderSide(color: primary)),
                      prefixIcon: Icon(
                        Icons.email,
                      ),
                      hintText: 'Email'),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Password :",
                    style: TextStyle(fontSize: 15, color: priText),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Theme(
                    data: new ThemeData(
                      primaryColor: primary,
                      primaryColorDark: Colors.red,
                    ),
                    child: new TextFormField(
                      obscureText: _obscureText,
                      controller: passctrl,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password Can not be empty.";
                        }
                      },
                      decoration: new InputDecoration(
                          border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: new BorderSide(color: primary)),
                          hintText: 'Password',
                          prefixIcon: const Icon(
                            Icons.lock,
                          ),
                          suffixIcon: _obscureText
                              ? IconButton(
                                  icon: Icon(Icons.remove_red_eye_outlined,
                                      color: primary),
                                  onPressed: _toggle)
                              : IconButton(
                                  icon: Icon(Icons.remove_red_eye,
                                      color: primary),
                                  onPressed: _toggle)),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(child: forgoetPassword()),
            SizedBox(
              height: 10.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 100,
                ),
                Center(
                  child: MaterialButton(
                      color: primary,
                      minWidth: 130,
                      height: 45,
                      onPressed: () => {
                            if (_formKey.currentState!.validate())
                              {userSignIn()}
                          },
                      child: processing == false
                          ? Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.white),
                            )
                          : CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget signInGoogleButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        AuthService(FirebaseAuth.instance).signInWithGoogle();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/g-logo.jpg',
              width: 40.0,
              height: 40.0,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget signUpUi() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 8,
            ),
            Text(
              "Your Name :",
              style: TextStyle(fontSize: 15, color: priText),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              child: Theme(
                data: new ThemeData(
                  primaryColor: primary,
                  primaryColorDark: Colors.red,
                ),
                child: new TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Name Can not be empty.";
                    } else if (value.length <= 2) {
                      return "Name too Short";
                    } else if (value.length > 15) {
                      return "Name too Long";
                    }
                  },
                  controller: namectrl,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: new BorderSide(color: primary)),
                      prefixIcon: Icon(
                        Icons.portrait,
                      ),
                      hintText: 'Name'),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Your Email :",
              style: TextStyle(fontSize: 15, color: priText),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: Theme(
                data: new ThemeData(
                  primaryColor: primary,
                  primaryColorDark: Colors.red,
                ),
                child: new TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email Can not be empty.";
                    }
                  },
                  controller: emailctrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: new BorderSide(color: primary)),
                      prefixIcon: Icon(
                        Icons.email,
                      ),
                      hintText: 'Email'),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Password :",
                    style: TextStyle(fontSize: 15, color: priText),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Theme(
                    data: new ThemeData(
                      primaryColor: primary,
                      primaryColorDark: Colors.red,
                    ),
                    child: new TextFormField(
                      obscureText: _obscureText,
                      controller: passctrl,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password Can not be empty.";
                        } else if (value.length < 8) {
                          return "Password too short. ";
                        }
                      },
                      decoration: new InputDecoration(
                          border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: new BorderSide(color: primary)),
                          hintText: 'Password',
                          helperText: "Password must be 8 characters long.",
                          prefixIcon: const Icon(
                            Icons.lock,
                          ),
                          suffixIcon: _obscureText
                              ? IconButton(
                                  icon: Icon(Icons.remove_red_eye_outlined,
                                      color: primary),
                                  onPressed: _toggle)
                              : IconButton(
                                  icon: Icon(Icons.remove_red_eye,
                                      color: primary),
                                  onPressed: _toggle)),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: MaterialButton(
                  color: primary,
                  minWidth: 130,
                  height: 45,
                  onPressed: () => {
                        if (_formKey.currentState!.validate()) {registerUser()}
                      },
                  child: processing == false
                      ? Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        )
                      : CircularProgressIndicator(
                          backgroundColor: Colors.white)),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}
