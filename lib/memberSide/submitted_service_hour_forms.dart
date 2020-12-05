import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';

class SubmittedServiceHourForms extends StatelessWidget {

  SubmittedServiceHourForms({this.uid});

  final String uid;

  Future getPosts() async {
      var firestore = Firestore.instance;
      QuerySnapshot qn = await firestore.collection("Approving Hours").getDocuments();
      return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      int x = snapshot.data.length - 1;
                      return Container(
                        height: SizeConfig.blockSizeVertical * 76,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          itemCount: snapshot.data.length,
                          itemBuilder: (_, index) {
                            if(snapshot.data[index].data['save_submit'] == "submit" && uid == snapshot.data[index].data['uid']) {
                              return Card(
                                elevation: 10,
                                child: ListTile(
                                  title: Text(snapshot.data[index].data['type'] + " - " + (snapshot.data[index].data['date'] == null ? "No Date" : snapshot.data[index].data['date'])),
                                  trailing: snapshot.data[index].data['complete'] == true ? Text("Approved", style: TextStyle(color: Colors.green),) : Text("Pending", style: TextStyle(color: Colors.lightBlue),)
                                ),
                              );
                            }
                            else if (x == 0) {
                              return Text("No Submitted Events", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 35), textAlign: TextAlign.center,);
                            }
                            else {
                              x--;
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
}