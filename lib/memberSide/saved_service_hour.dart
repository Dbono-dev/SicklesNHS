import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';

class ViewSavedServiceHourForms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
        ]
      ),      
    );
  }
}