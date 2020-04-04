import "package:firebase_auth/firebase_auth.dart";
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

  Future loginUser({String email, String password}) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return user;
    }
    catch(error) {
      print(error.toString());
      return null;
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