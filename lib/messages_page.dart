import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/view_students.dart';

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          TopHalfViewStudentsPage(),
          MessagesMiddlePage()
        ],
      ),
    );
  }
}

class MessagesMiddlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}