import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/auth_service.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:convert';

enum ExportDataOptions {specificEvent, specificClass, specificPerson, allStudents}

class ExportDataPage extends StatefulWidget {
  @override
  _ExportDataPageState createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").getDocuments();
    return qn.documents;
  }

  Future getEvents() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("events").getDocuments();
    return qn.documents;
  }

  String firstName;
  String lastName;
  String grade;
  String emailAddress;
  String permissions;
  String studentNum;

  Future getAllDataForStudent() async {
    List myList = new List ();
    var firestore = FirebaseDatabase.instance.reference().child('members');
    var result = await firestore.child('dGhlZHlsYW5yYm9ub0BnbWFpbC5jb20=-Dylan').once().then((DataSnapshot snapshot) => {
      firstName = snapshot.value['firstName'],
      lastName = snapshot.value['lastName'],
      grade = snapshot.value['grade'].toString(),
      emailAddress = snapshot.value['emailAddress'],
      permissions = snapshot.value['permissions'].toString(),
      studentNum = snapshot.value['studentNum'].toString()
    });
    String uid = await AuthService().createImportedUser(emailAddress, "password");
    var resultTwo = await DatabaseService(uid: uid).updateUserData(firstName, lastName, studentNum, grade, uid, permissions);
    var resultThree = await AuthService().logout();
  }

  ExportDataOptions _choice;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(padding: EdgeInsets.all(7),),
          Card(
            elevation: 10,
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: RadioListTile<ExportDataOptions>(
              title: Text("Specific Event"),
              value: ExportDataOptions.specificEvent,
              groupValue: _choice,
              onChanged: (ExportDataOptions value) {
                setState(() {
                  _choice = value;
                });
              }
            ),
          ),
          Card(
            elevation: 10,
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: RadioListTile<ExportDataOptions>(
              title: Text("Specific Grade Level"),
              value: ExportDataOptions.specificClass,
              groupValue: _choice,
              onChanged: (ExportDataOptions value) {
                setState(() {
                  _choice = value;
                });
              }
            ),
          ),
          Card(
            elevation: 10,
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: RadioListTile<ExportDataOptions>(
              title: Text("Specific Person"),
              value: ExportDataOptions.specificPerson,
              groupValue: _choice,
              onChanged: (ExportDataOptions value) {
                setState(() {
                  _choice = value;
                });
              }
            ),
          ),
          Card(
            elevation: 10,
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: RadioListTile<ExportDataOptions>(
              title: Text("All Students"),
              value: ExportDataOptions.allStudents,
              groupValue: _choice,
              onChanged: (ExportDataOptions value) {
                setState(() {
                  _choice = value;
                });
              }
            ),
          ),
          Spacer(),
          RaisedButton(
            elevation: 10,
            color: Colors.white,
            onPressed: () {
              getAllDataForStudent();
            },
            child: Text("Import Data"),
          ),
          Padding(padding: EdgeInsets.all(7)),
          Material(
            type: MaterialType.transparency,
            child: Container(
            height: SizeConfig.blockSizeVertical * 7,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                color: Colors.black,
                blurRadius: 15.0,
                spreadRadius: 2.0,
                offset: Offset(0, 10.0)
                )
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30)
              ),
              color: Colors.green,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Builder(
                  builder: (context) {
                    return FlatButton(
                      child: Text("Export Data", style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      )),
                      onPressed: ()  {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return exportDataDialog(_choice);
                          }
                        );
                      }
                    );
                  },
                ),
              ],
            ),
          ),
          )
        ]
      ),
    );
  }

  Widget exportDataDialog(ExportDataOptions choice) {
    if(choice == ExportDataOptions.allStudents) {
      return AlertDialog(
        title: Text("Confirmation!"),
        content: Text("Are you sure you would like to export all students data?"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel")
          ),
          FlatButton(
            onPressed: () {

            },
            child: Text("Confirm")
          )
        ],
      );
    }
    else if (choice == ExportDataOptions.specificEvent) {
      return Container(
        height: SizeConfig.blockSizeVertical * 45,
        child: AlertDialog(
          title: Text("Please Choose One!"),
          content: Container(
            child: FutureBuilder(
              future: getEvents(),
              builder: (_, snapshot) {
                if(snapshot.hasData) {
                  List<Widget> theEvents = new List<Widget> ();
                  for(int i = 0; i < snapshot.data.length; i++) {
                    theEvents.add(
                      ListTile(
                        title: Text(snapshot.data[i].data['title']),
                      )
                    );
                  }
                  return Container(
                    height: SizeConfig.blockSizeVertical * 45,
                    width: SizeConfig.blockSizeHorizontal * 75,
                    child: ListView(
                      children: theEvents,
                    ),
                  );
                }
                else {
                  return CircularProgressIndicator(
                    value: SizeConfig.blockSizeVertical * 45,
                  );
                }
              }
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Back")
            )
          ],
        ),
      );
    }
    else if (choice == ExportDataOptions.specificClass) {

    }
    else if (choice == ExportDataOptions.specificPerson) {

    }
    else {
      return AlertDialog(
        title: Text("Error"),
        content: Text("Please Select an Option"),
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


  Future _submitForm(DocumentSnapshot snapshot) async {

    FeedbackForm feedbackForm = FeedbackForm(
      snapshot.data['last name'].toString(),
      snapshot.data['first name'].toString(),
      snapshot.data['grade'].toString(),
      snapshot.data['student number'].toString()
    );

    FormController formController = FormController((String response) {
      print("Response: $response");
      if(response == FormController.STATUS_SUCCESS) {

      }
    });

    await formController.submitForm(feedbackForm);
  }
}


class FeedbackForm {
  String _firstName;
  String _lastName;
  String _grade;
  String _studentNum;

  FeedbackForm(this._lastName, this._firstName, this._grade, this._studentNum);

  String toParams() => "?lastName=$_lastName&firstName=$_firstName&grade=$_grade&studentNum=$_studentNum";
}

class FormController {
  final void Function(String) callback;
  static const String URL = "https://script.google.com/macros/s/AKfycbyqXO_XC-JTSmLS7DYb-oRyAYQBO7wBV_L9UnLaJxTP4i4E9Akh/exec";

  static const STATUS_SUCCESS = "SUCCESS";

  FormController(this.callback);

  Future submitForm(FeedbackForm feedbackForm) async {
    try {
      await http.get(URL + feedbackForm.toParams()).then((response) {
        callback(convert.jsonDecode(response.body)['status']);
      });
    }
    catch (e) {
      print(e);
    }
  }
}