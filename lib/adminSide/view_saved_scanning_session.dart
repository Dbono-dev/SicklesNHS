import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';

class ViewSavedScanningSessions extends StatelessWidget {

  List theList = new List();

  ViewSavedScanningSessions({this.uid});

  final String uid;

  Future getSavedEvents() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    theList = sharedPreferences.getStringList(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder(
        future: getSavedEvents(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else {
            return Column(
              children: <Widget>[
                TopHalfViewStudentsPage(),
                Container()
              ],
            );
          }
        }
      ),
    );
  }
}