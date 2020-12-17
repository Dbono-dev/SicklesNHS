import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/leaderboard_painter.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/currentQuarter.dart';

class Leaderboard extends StatelessWidget {
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
              child: LeaderBoardTheReal()
            ),
          )
        ]
      ),
    );
  }
}

class LeaderBoardTheReal extends StatefulWidget {
  @override
  _LeaderBoardTheRealState createState() => _LeaderBoardTheRealState();
}

class _LeaderBoardTheRealState extends State<LeaderBoardTheReal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Color left = Colors.black;
  Color right = Colors.white;

  Future getPosts(String quarter) async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").orderBy(quarter, descending: true).getDocuments();
    return qn.documents;
  }

  String currentQuarter = "";

  Future getQuarter() async {
    currentQuarter = await CurrentQuarter(DateTime.now()).currentQuarter();
  }

  PageController _pageController;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: Container(
              child: SingleChildScrollView(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: SizeConfig.blockSizeVertical * 82,
                        width: SizeConfig.blockSizeHorizontal * 100,
                        child: Card(
                          elevation: 0,
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: _buildMenuBar(context)
                              ),
                              Container(
                                child: Expanded(
                                  flex: 2,
                                  child: PageView(
                                    controller: _pageController,
                                    onPageChanged: (i) {
                                      if(i == 0) {
                                        setState(() {
                                          right = Colors.white;
                                          left = Colors.black;
                                        });
                                      }
                                      else if(i == 1) {
                                        setState(() {
                                          right = Colors.black;
                                          left = Colors.white;
                                        });
                                      }
                                    },
                                    children: <Widget> [
                                      ConstrainedBox(
                                        constraints: BoxConstraints.expand(),
                                        child: theLeaderBoard("quarter"),
                                      ),
                                      ConstrainedBox(
                                        constraints: BoxConstraints.expand(),
                                        child: theLeaderBoard("hours"),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ),
                      )
                    ],
                  ),
                ),
              )
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      height: 50,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.green
      ),
      child: CustomPaint(
        painter: LeaderBoardPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: _onSignInButtonPress,
                child: Text("Current Quarter", style: TextStyle(color: left,))
                ),
            ),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text("This Year", style: TextStyle(color: right,))
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget theLeaderBoard(String quarter) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: <Widget> [
          Container(
            height: SizeConfig.blockSizeVertical * 69,
            child: FutureBuilder(
              future: getQuarter(),
              builder: (_, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.green)
                  )
                );
              }
              else {
                if(quarter.contains("hours")) {
                  currentQuarter = "hours";
                }
                return FutureBuilder(
                  future: getPosts(currentQuarter),
                  builder: (_, notTheSnapshot) {
                    if(notTheSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green)
                        )
                      );
                    }
                    else {
                      return Material(
                        color: Colors.transparent,
                        child: Container(
                          height: SizeConfig.blockSizeVertical * 75,
                          child: ListView.builder(
                            itemCount: notTheSnapshot.data.length,
                            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
                            itemBuilder: (_, index) {
                              return viewStudentsCard(notTheSnapshot.data[index], index, currentQuarter);
                            }
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            }
            ),
          ),
        ]
      )
    );
  }

  Widget viewStudentsCard(DocumentSnapshot snapshot, int index, String quarter) {
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

    String hours;

    if(snapshot.data[quarter] is double) {
      if(snapshot.data[quarter].toString().substring(snapshot.data[quarter].toString().length - 2) == ".0") {
        hours = snapshot.data[quarter].toString().substring(0, snapshot.data[quarter].toString().length - 2);
      }
      else {
        hours = snapshot.data[quarter].toString();
      }
    }
    else {
      hours = snapshot.data[quarter].toString();
    }

    return Stack(
      children: <Widget>[
        Container(
          height: 65,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 6,
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
                    child: Center(child: Text(hours, style: TextStyle(fontSize: SizeConfig.blockSizeVertical * 2.5),)),
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
        color: color,
      ),
      child: Center(child: Text(place)),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

}