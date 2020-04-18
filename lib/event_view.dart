import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/add_new_event.dart';
import 'package:sickles_nhs_app/qr_code_page.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:sickles_nhs_app/database.dart';
import 'package:sickles_nhs_app/user.dart';
import 'package:sickles_nhs_app/account_profile.dart';

class EventPageView extends StatelessWidget {
  EventPageView ({Key key, this.post}) : super (key: key);

  final DocumentSnapshot post;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(color: Colors.white,),
          Container(
              child: Column(
              children: <Widget>[
                TopHalfViewEventsPage(post: post),
                Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2),),
                MiddleEventViewPage(post: post,),
                Spacer(),
                BottomEventViewPage(post: post,),
        ], ),
          )
          ],
        ),
    );
  }
}

class TopHalfViewEventsPage extends StatelessWidget {
  TopHalfViewEventsPage({Key key, this.post}) : super (key: key);

  DocumentSnapshot post;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
          Widget editIcon() {
            if(userData.permissions == 0) {
              return IconButton(
                color: Colors.white,
                iconSize: 55,
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddNewEvent(title: post.data['title'], description: post.data['description'], max: post.data['max participates'], address: post.data['address'], type: post.data['type'], date: post.data['date'], startTime: post.data['start time'], startTimeMinutes: post.data['start time minutes'], endTimeMinutes: post.data['end time minutes'], endTime: post.data['end time'],)));
                },
              );
            }
            else {
              return Container();
            }
          }

            return Material(
              child: Container(
              height: SizeConfig.blockSizeVertical * 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)
                ),
                boxShadow: [BoxShadow(
                  color: Colors.black,
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 5.0)
                  )
                ],
                color: Colors.green,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    iconSize: 60,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 22),
                  ),
                  editIcon(),
                  Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 1)),
                  Container(
                    child: FloatingActionButton(
                      backgroundColor: Colors.grey,
                      elevation: 8,
                      onPressed: () {
                        Navigator.push(context, 
                          MaterialPageRoute(builder: (context) => AccountProfile(type: "student",)
                          ));
                      },
                      child: Text(userData.firstName.substring(0, 1) + userData.lastName.substring(0, 1), style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.blockSizeVertical * 5.5
                      ),),
                    ),
                  )
                ],
              ),
            ),
      );
        }
        else {
          return Container();
        }
      });
  }
}

class MiddleEventViewPage extends StatelessWidget {
  MiddleEventViewPage ({Key key, this.post}) : super (key: key);

  final DocumentSnapshot post;
  String timeofDayStart = "am";
  String timeofDayEnd = "am";
  int startTime;
  int endTime;
  int startTimeMinutes;
  int endTimeMinutes;
  double modifiedStartTimeMinutes;
  double modifiedEndTimeMinutes;
  String theStartTimeMinutes;
  String theEndTimeMinutes;
  String location;
  String remainingSpots;
  String title;
  String description;
  double differenceTime;
  Widget _image;

  @override
  Widget build(BuildContext context) {
    if(post.data['type'] == "clubDates") {
      location = "Sickles High School";
      remainingSpots = "";
      title = "Club Meeting" + " " + post.data['date'].toString().substring(0, 5);
      description= "";
      startTime = 10;
      endTime = 11;
      startTimeMinutes = 56;
      endTimeMinutes = 31;
      differenceTime = 0.5;
      _image = Image.asset("SicklesNHS.jpg");
    }
    else {
      location = post.data['address'];
      remainingSpots = (int.parse(post.data["max participates"]) - post.data["participates"].length).toString();
      title = post.data['title'];
      description = post.data['description'];
      startTimeMinutes = post.data["start time minutes"];
      endTimeMinutes = post.data["end time minutes"];
      if(post.data['photo url'] != null) {
        _image = Image.network(post.data['photo url'].toString());
      }
      else {
        _image = Image.asset("SicklesNHS.jpg");
      }

      if(startTimeMinutes == 0) {
        modifiedStartTimeMinutes = 0.0;
        theStartTimeMinutes = "00";
      }
      if(startTimeMinutes == 15) {
        modifiedStartTimeMinutes = 0.25;
        theStartTimeMinutes = "15";
      }
      if(startTimeMinutes == 30) {
        modifiedStartTimeMinutes = 0.5;
        theStartTimeMinutes = "30";
      }
      if(startTimeMinutes == 45) {
        modifiedStartTimeMinutes = 0.75;
        theStartTimeMinutes = "45";
      }

      if(endTimeMinutes == 0) {
        modifiedEndTimeMinutes = 0.0;
        theEndTimeMinutes = "00";
      }
      if(endTimeMinutes == 15) {
        modifiedEndTimeMinutes = 0.25;
        theEndTimeMinutes = "15";
      }
      if(endTimeMinutes == 30) {
        modifiedEndTimeMinutes = 0.5;
        theEndTimeMinutes = "30";
      }
      if(endTimeMinutes == 45) {
        modifiedEndTimeMinutes = 0.75;
        theEndTimeMinutes = "45";
      }
      
      double modifiedEndTime = post.data["end time"] + modifiedEndTimeMinutes;
      double modifiedStartTime = post.data["start time"] + modifiedStartTimeMinutes;

      differenceTime = modifiedEndTime - modifiedStartTime;

      startTime = post.data['start time'];
      endTime = post.data['end time'];

      if(post.data["end time"] > 12) {
        endTime = (post.data["end time"] - 12);
        timeofDayEnd = "pm";
      }
      if(post.data["start time"] > 12) {
        startTime = (post.data["start time"] - 12);
        timeofDayStart = "pm";
      }
      if(post.data["start time"] == 12) {
        timeofDayStart = "pm";
      }
      if(post.data["end time"] == 12) {
        timeofDayEnd = "pm";
      }
    }

    return Card(
      elevation: 8,
        child: Material(
        color: Colors.white,
          child: Stack(
            children: <Widget>[
              Container(
                color: Colors.white,
              ),
              Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(title, style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold
                ),
                ),
                Text(post.data["date"]),
                Container(
                  height: 145,
                  width: 315,
                  child: _image,
                ),
                Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 3),),
                Container(
                  height: 140,
                  child: SingleChildScrollView(
                    child:
                      Text(description,
                        textAlign: TextAlign.center,
                      ),                  
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(location),
                    Text("Remaining Spots: " + remainingSpots)
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget> [
                        Card(
                         elevation: 8,
                         child: Container(
                           height: 42,
                           width: 200,
                           child: Center(
                             child: Material(
                               child: Text(
                                 startTime.toString() + ":" + theStartTimeMinutes + " " + timeofDayStart + " - " + endTime.toString() + ":" + theEndTimeMinutes.toString() + " " + timeofDayEnd, style: TextStyle(fontSize: 20)
                               ),
                             ),
                           ),
                         ),
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                        height: 42,
                        width: 150,
                          child: Center(
                            child: Material(
                            child: Text(
                              differenceTime.toString() + " hours", style: TextStyle(fontSize: 20),
                            ),
                        ),
                          ),
                      ),
                    ),
                    ]
                  ),
                ),
              ],
            ),
        ),
            ],
          ),
      ),
    );
  }
}

class BottomEventViewPage extends StatelessWidget {
  BottomEventViewPage ({Key key, this.post}) : super (key: key);

  final DocumentSnapshot post;
  String differentSignUp = "Check In";
  int newTime;
  double timing = 0.0;
  String title; 

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if(post.data['type'] == "clubDates") {
      title = "Club Dates " + post.data['date'].toString().substring(0, 5);
    }
    else {
      DateTime now = DateTime.now();
      String month = formatDate(now, [mm]);
      String day = formatDate(now, [dd]);
      String year = formatDate(now, [yyyy]);
      String date = month + "/" + day + "/" + year;
      newTime = int.parse(formatDate(now, [HH]));

      int modifiedStartMinutes = post.data['start time minutes'];
      int modifiedEndMinutes = post.data['end time minutes'];

      double bonusStartMinutes; 
      double bonusEndMinutes;

      if(modifiedStartMinutes == 0) {
        bonusStartMinutes = 0.0;
      }
      if(modifiedStartMinutes == 15) {
        bonusStartMinutes = 0.25;
      } 
      if(modifiedStartMinutes == 30) {
        bonusStartMinutes = 0.5;
      } 
      if(modifiedStartMinutes == 45) {
        bonusStartMinutes = 0.75;
      } 

      if(modifiedEndMinutes == 0) {
        bonusEndMinutes = 0.0;
      } 
      if(modifiedEndMinutes == 15) {
        bonusEndMinutes = 0.25;
      } 
      if(modifiedEndMinutes == 30) {
        bonusEndMinutes = 0.5;
      } 
      if(modifiedEndMinutes == 45) {
        bonusEndMinutes = 0.75;
      } 

      timing = newTime - (post.data["start time"] + bonusStartMinutes);
      double endtiming = (post.data["end time"] + bonusEndMinutes) - newTime;

      if(date == post.data["date"].toString())
      {
        if(timing >= -1 && timing <= 0.5)
        {
          differentSignUp = "Check In";
        }
        else if(endtiming <= 1 && endtiming >= -1)
        {
          differentSignUp = "Check Out";
        }
        else {
          differentSignUp = "Sign Up";
        }
      }
      else {
        differentSignUp = "Sign Up";
      }

      title = post.data["title"];
    }

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
          //if(post.data['participates'].contains(userData.firstName + " " + userData.lastName)) {
            //differentSignUp = "";
          //}
          return Material(
            type: MaterialType.transparency,
            child: Container(
            height: 50,
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
                FlatButton(
                  onPressed: () {
                    if(differentSignUp == "Check In") {
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => QRCodePage(title: title, name: userData.firstName + userData.lastName, type: "Check In",)
                        ));
                    }
                    if(differentSignUp == "Check Out") {
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => QRCodePage(title: title, name: userData.firstName + userData.lastName, type: "Check Out",)
                        ));
                    }
                    if(differentSignUp == "Sign Up") {
                      var participates = post.data['participates'];
                      participates.add(userData.firstName + " " + userData.lastName);
                      dynamic result = sendEventToDatabases(participates, title);
                    }
                  },
                    child: Text(differentSignUp, style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  )),
                ),
              ],
            ),
          ),
          );
        }
        return CircularProgressIndicator();
      }
    );
  }

  Future sendEventToDatabases(var participate, String title) async {
    await DatabaseEvent().updateEvent(participate, title);
  }
}

