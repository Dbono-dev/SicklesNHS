import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/user.dart';

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
      var a = await Firestore.instance.collection('members').document(user.uid).get();
      if(a.exists) {
        
      }
      else {
        String firstName;
        String lastName;
        String studentNum;
        String grade;
        String permissions;
        var firestore = FirebaseDatabase.instance.reference().child('members');
        var result = await firestore.child(user.uid).once().then((DataSnapshot snapshot) => {
          firstName = snapshot.value['firstName'],
          lastName = snapshot.value['lastName'],
          grade = snapshot.value['grade'].toString(),
          permissions = snapshot.value['permissions'].toString(),
          studentNum = snapshot.value['studentNum'].toString()
        });
        await DatabaseService(uid: user.uid).updateUserData(firstName, lastName, studentNum, grade, user.uid, permissions);
      }

      return user;
    }
    catch(error) {
      print(error);
      return errorMessage(error.message.toString(), context);
    }
  }

  Future resetPassword(String email, BuildContext context) async {
    try {
      var result = await _auth.sendPasswordResetEmail(email: email);
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Reset Password"),
            content: Text("Check your email to reset your password", textAlign: TextAlign.center),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(), 
                child: Text("DONE", style: TextStyle(color: Colors.green),)
              )
            ],
          );
        }
      );
    }
    catch(e) {
      print(e);
      Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(e.message, textAlign: TextAlign.center,),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(), 
                  child: Text("DONE", style: TextStyle(color: Colors.green),)
                )
              ],
            );
          }
        );
    }
  }

  Future<void> errorMessage(String body, BuildContext context) async {
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
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
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
        },
      );
    }
  }

  Future createUser({String firstName, String lastName, String email, String password, String studentNum, String grade}) async {
    var r = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

    await DatabaseService(uid: r.user.uid).updateUserData(firstName, lastName, studentNum, grade, r.user.uid, "2");
    var result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    FirebaseUser user = result.user; 
    return user;
  }

  Future<String> createImportedUser(String email, String password) async {
    var r = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    return r.user.uid;
  }
}
