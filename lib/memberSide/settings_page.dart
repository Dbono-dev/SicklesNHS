import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/login_screen.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 3)),
          Expanded(child: SettingsPageBody())
        ]
      ),
    );
  }
}

class SettingsPageBody extends StatelessWidget {
  String _summary;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Material(
            child: RaisedButton(
              color: Colors.white,
              elevation: 10,
              onPressed: () {
                resetPassword(context);
              },
              child: Text("Reset Password"),
            ),
          ),
          Padding(padding: EdgeInsets.all(5)),
          Material(
            child: RaisedButton(
              color: Colors.white,
              elevation: 10,
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 75, 10, 75),
                      child: AlertDialog(
                        elevation: 10,
                        content: Column(
                          children: <Widget> [
                            Text("Report a Bug"),
                            Form(
                              key: _formKey,
                              child: Expanded(
                                child: TextFormField(
                                  minLines: 10,
                                  maxLines: 20,
                                  onSaved: (val) => _summary = val ,
                                  decoration: InputDecoration(
                                    hintText: "Type a summary of the bug you found here...",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black)
                                    )
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("CANCEL")
                                ),
                                FlatButton(
                                  onPressed: () {
                                    dynamic result;
                                    _formKey.currentState.save();
                                    try {
                                      result = sendBugToDatabase(_summary);
                                    }
                                    catch (e) {
                                      print(e);
                                    }
                                    if(result != null) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text("SUBMIT")
                                )
                              ],
                            )
                          ]
                        ),
                      ),
                    );
                  }
                );
              },
              child: Text("Report a Bug")
            )
          ),
        ],
      ),
    );
  }

  Future sendBugToDatabase(String _summary) async {
    await DatabaseBugs().submmissionBugs(_summary);
  }
}