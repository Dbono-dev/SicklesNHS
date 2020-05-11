import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class ExportDataPage extends StatelessWidget {
  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").getDocuments();
    return qn.documents;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Spacer(),
          Container(
            child: FutureBuilder(
              future: getPosts(),
              builder: (_, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                else {
                  return Material(
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
                              onPressed: () async {
                                for(int i = 0; i < snapshot.data.length; i++) {
                                  await _submitForm(snapshot.data[i]);
                                }
                              }
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  );
                }
              },
            ),
          )
        ]
      ),
    );
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