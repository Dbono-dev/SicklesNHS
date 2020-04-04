import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:sickles_nhs_app/view_students.dart';

class Leaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          LeaderboardBody()
        ]
      ),
    );
  }
}

class LeaderboardBody extends StatelessWidget {
  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget> [
          Padding(padding: EdgeInsets.all(5)),
          Container(
            height: SizeConfig.blockSizeVertical * 65,
            child: FutureBuilder(
              future: getPosts(),
              builder: (_, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.green)
                  )
                );
              }
              else {
                return Material(
                  child: Container(
                    height: SizeConfig.blockSizeVertical * 59,
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {
                        return ViewStudentsCard(snapshot.data[index]);
                      }
                    ),
                  ),
                );
              }
            }
            ),
          ),
        ]
      )
    );
  }

  Widget ViewStudentsCard(DocumentSnapshot snapshot) {
    return Container(
      child: Card(
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(snapshot.data['first name'] + " " + snapshot.data['last name']),
                Text("Grade: " + snapshot.data['grade'])
              ],
            ),
            Spacer(),
            Text(snapshot.data['hours'], style: TextStyle(fontSize: SizeConfig.blockSizeVertical * 3.5),)
          ]
        )
      ),
    );
  }
}