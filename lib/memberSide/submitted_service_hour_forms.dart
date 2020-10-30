import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/user.dart';

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
          )
        ]
      ),
    );
  }
}