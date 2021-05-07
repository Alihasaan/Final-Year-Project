import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:onlineTaxiApp/auth_services.dart';
import 'package:onlineTaxiApp/utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'screens/WelcomeScreen.dart';
import 'package:easy_loader/easy_loader.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    print(e.message);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => AuthService(FirebaseAuth.instance),
          ),
          StreamProvider(
            create: (context) => context.read<AuthService>().authStateChanges,
          )
        ],
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
                child: AuthWrapper(),
              )),
            ),
          ),
        ));
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return WelcomeScreen();
    } else {
      return LogInSignUp();
    }
  }
}

class LogInSignUp extends StatefulWidget {
  @override
  _LogInSignUpState createState() => _LogInSignUpState();
}

class _LogInSignUpState extends State<LogInSignUp> {
  @override
  TextEditingController emailctrl, passctrl, namectrl, phonectrl;
  bool _obscureText = true;
  bool signin = true;
  bool processing = false;
  bool clicked = false;

  String Cerror;
  FirebaseAuth auth;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    emailctrl = new TextEditingController();
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
            color: Colors.black,
            fontFamily: 'OpenSans',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    vertical: 80.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/logo.png',
                        width: 600.0,
                        height: 240.0,
                        fit: BoxFit.none,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      showAlert(),
                      boxUi(),
                      SizedBox(
                        height: 50,
                      ),
                      signInGoogleButton(),
                    ],
                  )))),
    );
  }

  void _openLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: CircularProgressIndicator(),
        );
      },
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

    await context
        .read<AuthService>()
        .signUp(
          emailctrl.text,
          passctrl.text,
          namectrl.text,
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
        .signIn(emailctrl.text, passctrl.text)
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
                Cerror,
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
                        emailctrl.text = "",
                        namectrl.text = "",
                        passctrl.text = ""
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

  Widget signInUi() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: EmailValidator.validate,
            controller: emailctrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.email,
                ),
                hintText: 'Email'),
          ),
          Container(
            child: Column(
              children: [
                TextFormField(
                  onTap: _hideShow,
                  validator: PasswordValidator.validate,
                  obscureText: _obscureText,
                  controller: passctrl,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                      ),
                      hintText: 'Password'),
                ),
                clicked == false
                    ? Text("")
                    : TextButton(
                        onPressed: _toggle,
                        child: _obscureText
                            ? Icon(
                                Icons.remove_red_eye_outlined,
                                color: primary,
                              )
                            : Icon(Icons.remove_red_eye, color: primary))
              ],
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          MaterialButton(
              onPressed: () => {
                    if (_formKey.currentState.validate()) {userSignIn()}
                  },
              child: processing == false
                  ? Text(
                      'Sign In',
                      style: TextStyle(fontSize: 18.0, color: primary),
                    )
                  : CircularProgressIndicator(
                      backgroundColor: primary,
                    )),
        ],
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
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: NameValidator.validate,
            controller: namectrl,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.account_circle_outlined,
                ),
                hintText: 'Name'),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextFormField(
            controller: emailctrl,
            validator: EmailValidator.validate,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
                hintText: 'Email'),
          ),
          TextFormField(
            validator: PasswordValidator.validate,
            controller: passctrl,
            obscureText: true,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                ),
                hintText: 'Password'),
          ),
          SizedBox(
            height: 10.0,
          ),

          /* TextField(
            controller: phonectrl,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                ),
                hintText: 'Phone NO.'),
          ),*/
          SizedBox(
            height: 10.0,
          ),
          MaterialButton(
              onPressed: () => {
                    if (_formKey.currentState.validate()) {registerUser()}
                  },
              child: processing == false
                  ? Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18.0, color: primary),
                    )
                  : CircularProgressIndicator(backgroundColor: primary)),
        ],
      ),
    );
  }
}
