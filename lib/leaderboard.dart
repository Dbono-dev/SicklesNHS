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
    Query qn = firestore.collection("members").orderBy('hours', descending: true);
    QuerySnapshot qns = await qn.getDocuments();
    return qns.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget> [
          Padding(padding: EdgeInsets.all(5)),
          Container(
            height: SizeConfig.blockSizeVertical * 78,
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
                    height: SizeConfig.blockSizeVertical * 75,
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {
                        return ViewStudentsCard(snapshot.data[index], index);
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

  Widget ViewStudentsCard(DocumentSnapshot snapshot, int index) {
    Color color;
    String place;

    if(index == 0) {
      color = Colors.yellow[400];
      place = "1st";
    }
    else if(index == 1) {
      color = Colors.grey[400];
      place = "2nd";
    }
    else if(index == 2) {
      color = Colors.brown[400];
      place = "3rd";
    }
    else {
      color = Colors.transparent;
      place = "";
    }

    return Stack(
      children: <Widget>[
        Container(
          height: 65,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
            child: Card(
              elevation: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.5, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(snapshot.data['first name'] + " " + snapshot.data['last name']),
                        Text("Grade: " + snapshot.data['grade'])
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Center(child: Text(snapshot.data['hours'].toString(), style: TextStyle(fontSize: SizeConfig.blockSizeVertical * 3.5),)),
                  )
                ]
              )
            ),
          ),
        ),
        medals(color, place)
      ],
    );
  }

  Widget medals(Color color, String place) {
    return Container(
      height: 50,
      width: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color
      ),
      child: Center(child: Text(place)),
    );
  }
}