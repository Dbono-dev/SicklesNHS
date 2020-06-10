import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/adminSide/add_new_event.dart';
import 'package:sickles_nhs_app/memberSide/qr_code_page.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'package:sickles_nhs_app/memberSide/account_profile.dart';
import 'package:sickles_nhs_app/backend/globals.dart' as global;

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
              child: SingleChildScrollView(
                child: Column(
                children: <Widget>[
                  TopHalfViewEventsPage(post: post),
                  Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2),),
                  MiddleEventViewPage(post: post,),
                  Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 1)),
                  BottomEventViewPage(post: post,),
                  Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2)),
                  post.data['type'] == "clubDates" ? Container() : BottomBottomEventViewPage(post: post,)
        ], ),
              ),
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
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 19),
                  ),
                  editIcon(),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Container(
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
                          fontSize: 30
                        ),),
                      ),
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

class MiddleEventViewPage extends StatefulWidget {
  MiddleEventViewPage ({Key key, this.post}) : super (key: key);

  final DocumentSnapshot post;

  @override
  _MiddleEventViewPageState createState() => _MiddleEventViewPageState();
}

class _MiddleEventViewPageState extends State<MiddleEventViewPage> {
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
  int shownDate = 0;
  String theShownDate = "";

  @override
  Widget build(BuildContext context) {
    if(widget.post.data['type'] == "clubDates") {
      location = "Sickles High School";
      remainingSpots = "";
      title = "Club Meeting" + " " + widget.post.data['date'].toString().substring(0, 5);
      description= "";
      startTime = 10;
      endTime = 11;
      theStartTimeMinutes = "56";
      theEndTimeMinutes = "31";
      differenceTime = 0.5;
      _image = Image.asset("SicklesNHS.jpg");
    }
    else {
      location = widget.post.data['address'];
      remainingSpots = (int.parse(widget.post.data["max participates"]) - widget.post.data["participates"].length).toString();
      title = widget.post.data['title'];
      description = widget.post.data['description'];
      startTimeMinutes = widget.post.data["start time minutes"];
      endTimeMinutes = widget.post.data["end time minutes"];
      if(widget.post.data['photo url'] != null) {
        _image = Image.network(widget.post.data['photo url'].toString());
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
      
      double modifiedEndTime = widget.post.data["end time"] + modifiedEndTimeMinutes;
      double modifiedStartTime = widget.post.data["start time"] + modifiedStartTimeMinutes;

      differenceTime = modifiedEndTime - modifiedStartTime;

      startTime = widget.post.data['start time'];
      endTime = widget.post.data['end time'];

      if(widget.post.data["end time"] > 12) {
        endTime = (widget.post.data["end time"] - 12);
        timeofDayEnd = "pm";
      }
      if(widget.post.data["start time"] > 12) {
        startTime = (widget.post.data["start time"] - 12);
        timeofDayStart = "pm";
      }
      if(widget.post.data["start time"] == 12) {
        timeofDayStart = "pm";
      }
      if(widget.post.data["end time"] == 12) {
        timeofDayEnd = "pm";
      }
    }

    List theDates = new List();
    List<Widget> listWidgetDates = new List<Widget>();

    if(widget.post.data['date'].toString().length > 10) {
      String alsoTheDates = widget.post.data['date'];
      for(int i = 0; i < alsoTheDates.length; i++) {
        if(alsoTheDates.substring(0, i).contains("-")) {
          theDates.add(alsoTheDates.substring(0, i - 1));
          listWidgetDates.add(Text(alsoTheDates.substring(0, i - 1)));
          alsoTheDates = alsoTheDates.substring(i);
          i = 0;
        }
        else if(i == alsoTheDates.length - 1) {
          theDates.add(alsoTheDates);
          listWidgetDates.add(Text(alsoTheDates));
        }
      }
      theShownDate = theDates[shownDate];
      global.shownDate = theDates[shownDate];
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
                height: SizeConfig.blockSizeVertical * 66,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(title, style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold
                ),
                ),
                widget.post.data['date'].toString().length > 10 ? GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: SizeConfig.blockSizeVertical * 33,
                          child: CupertinoPicker(
                            backgroundColor: Colors.white,
                            itemExtent: 32,
                            onSelectedItemChanged: (value) {
                              setState(() {
                                shownDate = value;
                              });
                            },
                            children: listWidgetDates
                          ),
                        );
                      }
                    );
                  },
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal * 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(theShownDate),
                        Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                  )
                ) : Text(widget.post.data['date']),
                Container(
                  height: 145,
                  width: 315,
                  child: _image,
                ),
                Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 3),),
                Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      child:
                        Text(description,
                          textAlign: TextAlign.center,
                        ),                  
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                           height: SizeConfig.blockSizeVertical * 6.14,
                           width: 200,
                           child: Center(
                             child: Material(
                               color: Colors.transparent,
                               child: Text(
                                 startTime.toString() + ":" + theStartTimeMinutes.toString() + " " + timeofDayStart + " - " + endTime.toString() + ":" + theEndTimeMinutes.toString() + " " + timeofDayEnd, style: TextStyle(fontSize: 20)
                               ),
                             ),
                           ),
                         ),
                    ),
                    Card(
                      elevation: 8,
                      child: Container(
                        height: SizeConfig.blockSizeVertical * 6.14,
                        width: 150,
                          child: Center(
                            child: Material(
                              color: Colors.transparent,
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
      if(post.data['participates'].length == int.parse(post.data['max participates'])) {
        differentSignUp = "";
      }

      title = post.data["title"];
    }

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
          if(post.data['type'] == "clubDates") {

          }
          else {
            if(post.data['participates'].contains(userData.firstName + " " + userData.lastName) && (differentSignUp != "Check In" || differentSignUp != "Check Out")) {
              differentSignUp = "";
            }
          }
          return Material(
            type: MaterialType.transparency,
            child: Container(
            height: SizeConfig.blockSizeVertical * 7.316,
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
                        MaterialPageRoute(builder: (context) => QRCodePage(title: title, name: userData.firstName + userData.lastName, type: "Check In", uid: user.uid),
                        ));
                    }
                    if(differentSignUp == "Check Out") {
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => QRCodePage(title: title, name: userData.firstName + userData.lastName, type: "Check Out", uid: user.uid,)
                        ));
                    }
                    if(differentSignUp == "Sign Up") {
                      var participates = post.data['participates'];
                      var participateDate = post.data['participates dates'];
                      participates.add(userData.firstName + " " + userData.lastName);
                      participateDate.add(global.shownDate);
                      dynamic result = sendEventToDatabases(participates, title, participateDate);
                      dynamic result2 = sendBugToEmail(title, post);
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


  Future sendEventToDatabases(var participate, String title, var participateDate) async {
    await DatabaseEvent().updateEvent(participate, title, participateDate);
  }

  Future sendBugToEmail(String title, DocumentSnapshot post) async {
    final _auth = FirebaseAuth.instance;
    var currentUser = await _auth.currentUser();
    String userEmail = currentUser.email;

    String userName = "dbosports2";
    String password = "Dbo7030217";

    final smtpServer = gmail(userName, password);

    final message = Message()
    ..from = Address(userName, 'Sickles NHS Developer')
    ..recipients.add(userEmail)
    ..subject = "Signed up for " + title
    ..text = "Thank you for signing up for " + title + ". \n Event Start Time: " + post.data['start time'].toString() + ":" + post.data['start time minutes'].toString();

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
    }
  }
}

class BottomBottomEventViewPage extends StatefulWidget {

  BottomBottomEventViewPage({this.post});

  DocumentSnapshot post;

  @override
  _BottomBottomEventViewPageState createState() => _BottomBottomEventViewPageState();
}

class _BottomBottomEventViewPageState extends State<BottomBottomEventViewPage> {
  List participatesList = new List();
  List participatesDate = new List();

  int shownDate = 0;
  String theShownDate = "";

  @override
  Widget build(BuildContext context) {
    participatesList = widget.post.data['participates'];
    participatesDate = widget.post.data['participates dates'];

    List theDates = new List();
    List<Widget> listWidgetDates = new List<Widget>();

    if(widget.post.data['date'].toString().length > 10) {
      String alsoTheDates = widget.post.data['date'];
      for(int i = 0; i < alsoTheDates.length; i++) {
        if(alsoTheDates.substring(0, i).contains("-")) {
          theDates.add(alsoTheDates.substring(0, i - 1));
          listWidgetDates.add(Text(alsoTheDates.substring(0, i - 1)));
          alsoTheDates = alsoTheDates.substring(i);
          i = 0;
        }
        else if(i == alsoTheDates.length - 1) {
          theDates.add(alsoTheDates);
          listWidgetDates.add(Text(alsoTheDates));
        }
      }
      theShownDate = theDates[shownDate];
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Participates", style: TextStyle(fontSize: 40), textAlign: TextAlign.left,),
            participatesDate == null ? Container() : GestureDetector(
              onTap: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: SizeConfig.blockSizeVertical * 33,
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 32,
                        onSelectedItemChanged: (value) {
                          setState(() {
                            shownDate = value;
                          });
                        },
                        children: listWidgetDates
                      ),
                    );
                  }
                );
              },
              child: Container(
                width: SizeConfig.blockSizeHorizontal * 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(theShownDate),
                    Icon(Icons.keyboard_arrow_down)
                  ],
                ),
              )
            ),
            Container(
              height: SizeConfig.blockSizeVertical * 45,
              child: participatesDate == null ? ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                itemCount: participatesList.length,
                itemBuilder: (_, index) {
                  if(participatesList.length == 0) {
                    return Center(child: Text("No Participates", style: TextStyle(fontSize: 30),),);
                  }
                  else {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                      child: Card(
                        elevation: 10,
                        child: ListTile(
                          leading: Text((index + 1).toString() + ".", style: TextStyle(fontSize: 20),),
                          title: Text(participatesList[index])
                        )
                      ),
                    );
                  }
                },
              ) : ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                itemCount: participatesDate.length,
                itemBuilder: (_, index) {
                  if(participatesDate[index] == theShownDate) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                      child: Card(
                        elevation: 10,
                        child: ListTile(
                          leading: Text((index + 1).toString() + ".", style: TextStyle(fontSize: 20)),
                          title: Text(participatesList[index]),
                        )
                      ),
                    );
                  }
                  else {
                    return Center(child: Text("No Participates", style: TextStyle(fontSize: 30),),);
                  }
                }
              ),
            )
          ],
        )
      ),
    );
  }
}
