// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:book_club/Services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Models/user.dart';

class CurrentUser extends ChangeNotifier {
  late OurUser? _currentUser = OurUser();

  OurUser? get getcurrentUser => _currentUser;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> onStartUp() async {
    String retVal = "error";

    try {
      User _firebaseUser = await _auth.currentUser!;
      _currentUser!.uid = _firebaseUser.uid;
      _currentUser!.email = _firebaseUser.email!;
      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String?> signOut() async {
    String retVal = "error";

    try {
      await _auth.signOut();
      _currentUser = OurUser();

      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String?> signUpUser(
      String email, String password, String fullName) async {
    String? retVal = "error";
    OurUser _user = OurUser();

    try {
      UserCredential _userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _user = _userCredential.user?.uid as OurUser;
      _user.email = _userCredential.user?.uid;
      _user.fullName = fullName;
      String _returnString = await OurDataBase().createUser(_user);

      if (_returnString == "success") {
        retVal = "success";
      }
    } on FirebaseAuthException catch (e) {
      retVal = e.message;
    }

    return retVal;
  }

  Future<String?> logInUserWithEmail(String email, String password) async {
    String? retVal = "error";

    try {
      UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (_userCredential.user != null) {
        _currentUser?.uid = _userCredential.user!.uid;
        _currentUser!.email = _userCredential.user!.email!;

        retVal = "success";
      }
    } on FirebaseAuthException catch (e) {
      retVal = e.message;
    }

    return retVal;
  }

  Future<String?> logInUserWithGoogle() async {
    String? retVal = "error";
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    try {
      GoogleSignInAccount? _googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication _googleAuth =
          await _googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
      UserCredential _userCredential =
          await _auth.signInWithCredential(credential);
      if (_userCredential.user != null) {
        _currentUser!.uid = _userCredential.user!.uid;
        _currentUser!.email = _userCredential.user!.email!;
        retVal = "success";
      }
    } on FirebaseAuthException catch (e) {
      retVal = e.message;
    }

    return retVal;
  }
}
