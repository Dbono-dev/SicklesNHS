import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/memberSide/add_new_hours.dart';

class ViewSavedServiceHourForms extends StatefulWidget {

  ViewSavedServiceHourForms({this.uid});

  final String uid;

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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(000000).withOpacity(0.25),
                    offset: Offset(0, -2),
                    blurRadius: 15,
                    spreadRadius: 5
                  )
                ]
              ),
              child: Padding(
                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                child: FutureBuilder(
                  future: getPosts(),
                  builder: (_, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.green)),);
                    }
                    else {
                      return Container(
                        color: Colors.white,
                        height: SizeConfig.blockSizeVertical * 78,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          itemCount: snapshot.data.length,
                          itemBuilder: (_, index) {
                            if(snapshot.data[index].data['save_submit'] == "save" && widget.uid == snapshot.data[index].data['uid']) {
                              return Card(
                                elevation: 10,
                                child: ListTile(
                                  title: Text(snapshot.data[index].data['type'], textAlign: TextAlign.center,),
                                  trailing: Container(
                                    width: SizeConfig.blockSizeHorizontal * 49,
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
                                            fromSaved.add(snapshot.data[index].data['url']);
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
                ),
              ),
            ),
          )
        ]
      ),      
    );
  }

  Future sendEventToDatabase(String type) async {
    await DatabaseSubmitHours().fromSaveToSubmit(type);
  }
}