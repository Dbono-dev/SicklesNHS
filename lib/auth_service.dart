import 'dart:io';

import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:sickles_nhs_app/database.dart';
import 'package:sickles_nhs_app/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  Future logout() async {
    try {
      return await _auth.signOut();
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future loginUser({String email, String password, BuildContext context}) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return user;
    }
    catch(error) {
      return ErrorMessage(error.message.toString(), context);
    }
  }

  Future<void> ErrorMessage(String body, BuildContext context) async {
    if(Platform.isAndroid) {
      return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error Message"),
              content: Text(body),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
    }
    else {
      return CupertinoAlertDialog(
        title: Text("Error Message"),
        content: Text(body),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Ok")
          )
        ],
      );
    }
  }

  Future createUser({String firstName, String lastName, String email, String password, String studentNum, String grade}) async {
    var r = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    var u = r.user;

    await DatabaseService(uid: u.uid).updateUserData(firstName, lastName, "0", studentNum, grade);
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = '$firstName $lastName';
    return await u.updateProfile(info);
  }
}