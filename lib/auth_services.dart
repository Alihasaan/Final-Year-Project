import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  AuthService(this._firebaseAuth);
  final db = FirebaseFirestore.instance;

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<String> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      print("User Signed In");
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    print("User Signed Out");
  }

  Future<String> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseAuth.instance.currentUser.updateProfile(displayName: name);

      return "Account created";
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return e.message;
    }
  }

  Future<String> addPhoneNo(
    String phoneNo,
  ) async {
    await db
        .collection("userData")
        .doc(_firebaseAuth.currentUser.uid)
        .collection('usersData')
        .add({'phoneNo': phoneNo});
    return "Success";
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      UserCredential authResult =
          await _firebaseAuth.signInWithCredential(credential);
      User currentUser = auth.currentUser;
      print(currentUser.uid);
      return currentUser;
    } else {
      print("Sign In Failed");
    }

    return null;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Signed Out");
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

class EmailValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Email Can not be empty.";
    }
  }
}

class NameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Name Can not be empty.";
    } else if (value.length <= 2) {
      return "Name too Short";
    } else if (value.length > 15) {
      return "Name too Long";
    }
  }
}

class PasswordValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Password Can not be empty.";
    } else if (value.length < 8) {
      return "Password too short. ";
    }
  }
}

class PhoneValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Please enter your Phone No.";
    } else if (value.length < 10) {
      return " Invalid Phone No. Format";
    } else if (value.length > 10) {
      return " Invalid Phone No. Format";
    }
  }
}
