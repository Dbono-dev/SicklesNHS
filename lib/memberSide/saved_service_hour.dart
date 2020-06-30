import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/memberSide/add_new_hours.dart';

class ViewSavedServiceHourForms extends StatefulWidget {

  @override
  _ViewSavedServiceHourFormsState createState() => _ViewSavedServiceHourFormsState();
}

class _ViewSavedServiceHourFormsState extends State<ViewSavedServiceHourForms> {
  Future getPosts() async {
      var firestore = Firestore.instance;
      QuerySnapshot qn = await firestore.collection("Approving Hours").getDocuments();
      return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2)),
          FutureBuilder(
            future: getPosts(),
            builder: (_, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.green)),);
              }
              else {
                return Container(
                  height: SizeConfig.blockSizeVertical * 76,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      if(snapshot.data[index].data['save_submit'] == "save") {
                        return Card(
                          elevation: 10,
                          child: ListTile(
                            title: Text(snapshot.data[index].data['type'], textAlign: TextAlign.center,),
                            trailing: Container(
                              width: SizeConfig.blockSizeHorizontal * 43,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      List fromSaved = new List();
                                      fromSaved.add(snapshot.data[index].data['type']);
                                      fromSaved.add(snapshot.data[index].data['location']);
                                      fromSaved.add(snapshot.data[index].data['date']);
                                      fromSaved.add(snapshot.data[index].data['hours']);
                                      fromSaved.add(snapshot.data[index].data['name of supervisor']);
                                      fromSaved.add(snapshot.data[index].data['supervisor phone number']);
                                      fromSaved.add(snapshot.data[index].data['supervisor email']);
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddNewHours(fromSaved: fromSaved,)));
                                    }, 
                                    child: Text("Edit", style: TextStyle(color: Colors.green))
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      dynamic result = sendEventToDatabase(snapshot.data[index].data['type']);
                                      setState(() {
                                        
                                      });
                                    },
                                    child: Text("Submit", style: TextStyle(color: Colors.green))
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      else {
                        return Container();
                      }
                    }
                  ),
                );
              }
            }
          )
        ]
      ),      
    );
  }

  Future sendEventToDatabase(String type) async {
    await DatabaseSubmitHours().fromSaveToSubmit(type);
  }
}