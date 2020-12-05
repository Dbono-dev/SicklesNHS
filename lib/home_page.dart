import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sickles_nhs_app/adminSide/view_images.dart';
import 'package:sickles_nhs_app/memberSide/account_profile.dart';
import 'package:sickles_nhs_app/adminSide/add_new_event.dart';
import 'package:sickles_nhs_app/adminSide/approve_hours.dart';
import 'package:sickles_nhs_app/backend/auth_service.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/memberSide/create_new_event_options.dart';
import 'package:sickles_nhs_app/memberSide/event_view.dart';
import 'package:sickles_nhs_app/adminSide/important_dates.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/adminSide/notification_system.dart';
import 'package:sickles_nhs_app/adminSide/export_data.dart';
import 'package:intl/intl.dart';

class TheOpeningPage extends StatefulWidget {
  TheOpeningPage({Key key, this.userData}) : super (key: key);

  final UserData userData;

  @override
  _TheOpeningPageState createState() => _TheOpeningPageState();
}

class _TheOpeningPageState extends State<TheOpeningPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          TopHalfHomePage(),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.10),),
          MiddleHomePage(userData: widget.userData,),
          Spacer(),
          BottonHalfHomePage()
        ],
      )
    ); 
  }
}

class MiddleHomePage extends StatefulWidget {
  MiddleHomePage({Key key, this.userData}) : super (key: key);

  UserData userData;

  @override
  _MiddleHomePageState createState() => _MiddleHomePageState();
}

class _MiddleHomePageState extends State<MiddleHomePage> {

  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("events").orderBy('date').getDocuments();

    return qn.documents;
  }

  DateFormat format = new DateFormat("MM/dd/yyyy");
  DateFormat secondFormat = new DateFormat("yyyy-MM-dd");

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final user = Provider.of<User>(context);

    return Container(
      height: SizeConfig.blockSizeVertical * 45,
      color: Colors.transparent,
      padding: EdgeInsets.all(10),
      child: StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            UserData userData = snapshot.data;
            return FutureBuilder(
              future: getPosts(),
              builder: (_, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  );
                }
                else if (snapshot.data.length == 0) {
                  return Material(
                    color: Colors.transparent,
                      child: Center(
                      child: Text("NO EVENTS", style: TextStyle(
                        color: Colors.green,
                        fontSize: 45
                      )),
                    ),
                  );
                }
                else {
                  int theLength = snapshot.data.length;
                  for(int i = 0; i < snapshot.data.length; i++) {
                    int numberOfTimesThrough = 0;
                    int a = 0;
                    for(int k = a; a < snapshot.data[i].data['date'].toString().length; k + 1) {
                      numberOfTimesThrough = numberOfTimesThrough + 1;
                      if(format.parse(snapshot.data[i].data['date'].toString().substring(a, a + 10)).isBefore(secondFormat.parse(DateTime.now().toString().substring(0, 10)))) {
                        numberOfTimesThrough--;
                      }
                      a = a + 11;
                    }
                    if(numberOfTimesThrough == 0) {
                      theLength = theLength - 1;
                    }
                    else if(snapshot.data[i].data['participates'].contains(userData.firstName + " " + userData.lastName)) {
                      theLength = theLength - 1;
                    }
                    else {

                    }
                  }
                  if(theLength == 0) {
                    return Material(
                      color: Colors.transparent,
                      child: Center(
                        child: Text("NO EVENTS", style: TextStyle(
                          color: Colors.green,
                          fontSize: 45
                        )),
                      ),
                    );
                  }
                  else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {
                        int numberOfTimesThrough = 0;
                        int a = 0;
                        for(int i = a; a < snapshot.data[index].data['date'].toString().length; i + 1) {
                          numberOfTimesThrough = numberOfTimesThrough + 1;
                          if(format.parse(snapshot.data[index].data['date'].toString().substring(a, a + 10)).isBefore(secondFormat.parse(DateTime.now().toString().substring(0, 10)))) { //&& format.parse(snapshot.data[index].data['date'].toString().substring(a, a + 10)).isAtSameMomentAs(DateTime.now())) {
                            numberOfTimesThrough--;
                          }
                          a = a + 11;
                        }
                        if(numberOfTimesThrough > 0) {
                          return MiddleHomePageCards(post: snapshot.data[index], officerSponsor: userData.permissions == 0 || userData.permissions == 1 ? true : false);
                        }
                        else {
                          return Container();
                        }
                      }
                    );
                  }
                }
              }
            );
          }
          else {
            return CircularProgressIndicator();
          }
        }
      )
    );
  }
}

class TopHalfHomePage extends StatelessWidget {
  TopHalfHomePage({Key key}) : super (key: key);

  String timeOfDay;
  

  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);

  String timeOfDay = "";
  int currentTime = DateTime.now().hour;
  
  if(currentTime > 4 && currentTime < 12) {
    timeOfDay = "Good Morning ";
  }
  else if(currentTime >= 12 && currentTime < 17) {
    timeOfDay = "Good Afternoon ";
  }
  else {
    timeOfDay = "Good Evening ";
  }

    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;

            return Material(
              color: Colors.transparent,
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
                    Padding(padding: EdgeInsets.all(10),),
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 63,
                        child: FittedBox(
                        fit: BoxFit.fitWidth,
                          child: Text(timeOfDay + userData.firstName, style: TextStyle(
                          fontStyle: FontStyle.normal,
                          color: Colors.white
                        )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5.5),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: FloatingActionButton(
                        heroTag: "homePage",
                        backgroundColor: Colors.grey,
                        elevation: 8,
                        onPressed: () {
                          Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => AccountProfile(type: "student", name: userData.firstName + " " + userData.lastName, uid: user.uid),
                            ));
                        },
                        child: FittedBox(fit: BoxFit.fitWidth, child: Text(userData.firstName.substring(0, 1) + userData.lastName.substring(0, 1), style: TextStyle(color: Colors.white, fontSize: SizeConfig.blockSizeHorizontal * 9))),
                      ),
                    )
                  ],
                ),
              ),
            );
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }
}

class MiddleHomePageCards extends StatelessWidget {
  MiddleHomePageCards({Key key, this.post, this.officerSponsor}) : super (key: key);

  final DocumentSnapshot post;
  final bool officerSponsor;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final AuthService _auth = AuthService();
    Color theColor;
    Widget image;

    navigateToDetail(DocumentSnapshot post) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => EventPageView(post: post, officerSponsor: officerSponsor,)));
    }

    final user = Provider.of<User>(context);

     return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
          if(post.data['photo url'] != null) {
            image = Image.network(post.data['photo url']);
          }
          if(post.data['photo url'] == null) {
            image = Image.asset("SicklesNHS.jpg");
          }
          if(post.data["type"].toString() == "Community Service Project") {
            theColor = Colors.yellow[400];
          }
          else {
            theColor = Colors.white;
          }
          if(post.data["participates"].contains(userData.firstName + " " + userData.lastName)) {
            return Container(
              height: 0,
              width: 0,
            );
          }
          else {
            return GestureDetector(
              onTap: () {
                navigateToDetail(post);
              },
                child: Container(
                padding: EdgeInsets.all(3),
                height: SizeConfig.blockSizeVertical * 40,
                width: SizeConfig.blockSizeHorizontal * 55, 
                child: Card(
                  elevation: 8,
                  color: theColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    side: BorderSide(width: 3, color: theColor)
                  ),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              height: SizeConfig.blockSizeVertical * 16,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 1, 0, SizeConfig.blockSizeHorizontal * 1, 0),
                                child: Hero(
                                  tag: 'eventView' + post.data['title'],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    clipBehavior: Clip.antiAlias,
                                    child: image
                                  ),
                                ),
                              ),
                            ),
                            Text(post.data["title"], style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 4.5,
                              fontWeight: FontWeight.bold, 
                              color: Colors.black
                            ),
                            overflow: TextOverflow.ellipsis,
                            ),
                            Text(post.data["description"], overflow: TextOverflow.ellipsis, style: TextStyle(
                              color: Colors.black
                            ),),
                            Text("SIGN UP", style: TextStyle(
                              color: Colors.green,
                              fontSize: 30,
                              decoration: TextDecoration.underline
                                ),)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                ),
              ),
            );
          }
        }
        return CircularProgressIndicator();
      }
     );
  }
}

class BottonHalfHomePage extends StatelessWidget {
  BottonHalfHomePage({Key key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
          DateFormat format = new DateFormat('MM/dd/yyyy');
          
          if(userData.permissions == 0) {
            return Stack(
                children: <Widget>[
                Material(
                  child: Container(
                  height: SizeConfig.blockSizeVertical * 34,
                  width: SizeConfig.blockSizeVertical * 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                    ),
                    color: Colors.green,
                    boxShadow: [BoxShadow(
                      color: Colors.black,
                      blurRadius: 25.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 10)
                      )
                ],
              ),
          ),),
          AdminMyEvents(uid: userData.uid,)
        ]
       );
          }
          if(userData.permissions == 2) {
            return Stack(
                children: <Widget>[
                Material(
                  child: Container(
                  height: SizeConfig.blockSizeVertical * 34,
                  width: SizeConfig.blockSizeVertical * 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                    ),
                    color: Colors.green,
                    boxShadow: [BoxShadow(
                      color: Colors.black,
                      blurRadius: 25.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 10)
                      )
                ],
              ),
          ),),
          StudentMyEvents()
        ]
       );
          }
          if(userData.permissions == 1 && format.parse(userData.date).isAfter(DateTime.now())) {
            return Stack(
                children: <Widget>[
                Material(
                  child: Container(
                  height: SizeConfig.blockSizeVertical * 34,
                  width: SizeConfig.blockSizeVertical * 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                    ),
                    color: Colors.green,
                    boxShadow: [BoxShadow(
                      color: Colors.black,
                      blurRadius: 25.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 10)
                      )
                ],
              ),
          ),),
          OfficerMyEvents()
        ]
       );
          }
          else {
            return Container();
          }
    }
      return CircularProgressIndicator();
    }
    );
  }
}

class BottomPageCards extends StatelessWidget {
  BottomPageCards ({Key key, this.post}) : super (key: key);

  DocumentSnapshot post;
  String title;

  Widget build(BuildContext context) {


  navigateToDetail(DocumentSnapshot post) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => EventPageView(post: post,)));
  }

  if(post.data["type"].toString() == "clubDates") {
    title = "Club Meeting " + post.data["date"].toString().substring(0, 5);
  }
  else {
    title = post.data['title'];
  }

    return GestureDetector(
      onTap: () {
        navigateToDetail(post);
      },
        child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(width: 3, color: Colors.transparent)
          ),
          child: Container(
          child: Material(
            color: Colors.transparent,
              child: Container(
              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(width: 2, color: Colors.transparent)
            ),
              padding: const EdgeInsets.all(3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(title, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 2,),
                  Text("View Event", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, decoration: TextDecoration.underline, color: Colors.green), textAlign: TextAlign.center,),
                  Row()
                ],
              ),
            ),
          ),
          ),
      ),
    );
  }
}

class StudentMyEvents extends StatefulWidget {
  @override
  _StudentMyEvents createState() => _StudentMyEvents();

}

class _StudentMyEvents extends State<StudentMyEvents> {

  Future getStudentCards() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("Important Dates").getDocuments();
    QuerySnapshot otherQn = await firestore.collection("events").getDocuments();
    return qn.documents + otherQn.documents;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final AuthService _auth = AuthService();
    int x = 0;
    final user = Provider.of<User>(context);
    DateFormat format = new DateFormat("MM/dd/yyyy");

    int _whithin10Days(DocumentSnapshot snapshot) {
      int _date = Jiffy(DateTime.now()).dayOfYear;
      return _date;
    }

    int _clubDate(DocumentSnapshot snapshot) {
      int _date = Jiffy(DateTime(int.parse(snapshot.data['date'].substring(6)), int.parse(snapshot.data['date'].substring(0, 2)), int.parse(snapshot.data['date'].substring(3, 5)))).dayOfYear;
      return _date;
    }

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
          return Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(15)),
                  Container(
                  width: SizeConfig.blockSizeHorizontal * 50,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                      child: Text(
                      "My Events", textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
            ),
            Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5)),
            Container(
              width: SizeConfig.blockSizeHorizontal * 25,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                color: Colors.white,
                elevation: 8,
                child: Text("LOGOUT"),
                onPressed: () async {
                  await _auth.logout();
                }, 
              ),
            )
                ],
              ),
              Container(
              height: SizeConfig.blockSizeVertical * 26,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: FutureBuilder(
                future: getStudentCards(),
                builder: (_, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      )
                    );
                  }
                  else {
                    int numOfEvents = snapshot.data.length;
                    for(int i = 0; i < snapshot.data.length; i++) {
                      if(snapshot.data[i].data['type'] == "Service Event") {
                        if(snapshot.data[i].data["participates"].contains(userData.firstName + " " + userData.lastName) && format.parse(snapshot.data[i].data['date']).isAfter(DateTime.now())) {

                        }
                        else {
                          numOfEvents -= 1;
                        }
                      }
                      else if(snapshot.data[i].data['type'] == "clubDates"){
                        numOfEvents -= 1;
                      }
                      else {
                        numOfEvents -= 1;
                      }
                    }
                    
                    return Container(
                      child: numOfEvents == 0 ? Center(child: Text("NO EVENTS", style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),)) : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        itemBuilder: (_, index) {
                          if(snapshot.data[index].data['type'] == "clubDates") {
                            x += 1;
                            if(_clubDate(snapshot.data[index]) - _whithin10Days(snapshot.data[index]) <= 10 && _clubDate(snapshot.data[index]) > _whithin10Days(snapshot.data[index])) {
                              return BottomPageCards(post: snapshot.data[index]);
                            }
                            else {
                              return Container(height: 0,);
                            }
                          }
                          else {
                            if(snapshot.data[index].data['type'] == "Service Event") {
                              if(snapshot.data[index].data["participates"].contains(userData.firstName + " " + userData.lastName) && format.parse(snapshot.data[index].data['date']).isAfter(DateTime.now())) {
                                return BottomPageCards(post: snapshot.data[index]);
                              }
                              else {
                                return Container();
                              }
                            }
                            else {
                              return Container();
                            }
                          }
                          
                        }
                      ),
                    );
                  }
                }
              )
          ),
              ],
            )
        );
        }
        else {
          return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.grey));
        }
      }
    );
}
}

class AdminMyEvents extends StatefulWidget {

  AdminMyEvents({this.uid});

  final String uid;

  @override
  _AdminMyEvents createState() => _AdminMyEvents();

}

class _AdminMyEvents extends State<AdminMyEvents> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final AuthService _auth = AuthService();

        return Material(
          color: Colors.transparent,
            child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5),),
                  Container(
                    child: Text("Sponsor", style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    ),)
                    ),
                    Spacer(),
                    Padding(
                      padding:  EdgeInsets.fromLTRB(0, 0, SizeConfig.blockSizeHorizontal * 10, 0),
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          color: Colors.white,
                                elevation: 8,
                                child: FittedBox(fit: BoxFit.fill, child: Text("LOGOUT")),
                                onPressed: () async {
                                  await _auth.logout();
                                }, 
                        ),
                      ),
                    ),
                ],),
              Container(
                height: SizeConfig.blockSizeVertical * 25,
                width: SizeConfig.blockSizeHorizontal * 90,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  children: <Widget>[
                    adminTags(context, AddNewEvent("new"), Icons.add_circle, "Add New Event"),
                    adminTags(context, ViewStudents(), Icons.people, "View Students"),
                    adminTags(context, Notifications(), Icons.notifications, "Send Notification"),
                    adminTags(context, CreateNewHoursOptionsPage(tile1: "Create New Scanning Session", tile2: "View Saved Scanning Sessions", tile3: "View Submitted Scanning Sessions", uid: widget.uid,), Icons.photo_camera, "Start Scanning",),
                    adminTags(context, ApproveHoursPage(), Icons.check_circle, "Approve Hours"),
                    adminTags(context, ViewImages(), Icons.image, "View Images"),
                    adminTags(context, ExportDataPage(), Icons.import_export, "Export Data"),
                    adminTags(context, ImportantDateMain(), Icons.date_range, "Set Important Dates"),
                  ],
              ))
            ],
          ),
        );
}
}

Widget adminTags(BuildContext context, Widget location, IconData theIcon, String theText) {
  return Column(
    children: <Widget>[
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => location));
        },
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              Icon(
                theIcon,
                size: 35,
                color: Colors.black,
              ),
              Padding(padding: EdgeInsets.all(7)),
              Text(theText, textAlign: TextAlign.center, style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),),
            ]
          )
        )
      ),
      Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.5)),
    ],
  );
}

class OfficerMyEvents extends StatefulWidget {
  @override
  _OfficerMyEvents createState() => _OfficerMyEvents();

}

class _OfficerMyEvents extends State<OfficerMyEvents> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final AuthService _auth = AuthService();

        return Material(
          color: Colors.transparent,
            child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5),),
                  Container(
                    child: Text("Officer", style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    ),)
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 25, 0.0, 0.0, 0.0)),
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 25,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        color: Colors.white,
                              elevation: 8,
                              child: FittedBox(fit: BoxFit.fill, child: Text("LOGOUT")),
                              onPressed: () async {
                                await _auth.logout();
                              }, 
                      ),
                    ),
                ],),
              Container(
                height: SizeConfig.blockSizeVertical * 25,
                width: SizeConfig.blockSizeHorizontal * 90,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    adminTags(context, CreateNewHoursOptionsPage(tile1: "Create New Scanning Session", tile2: "View Saved Scanning Sessions", tile3: "View Submitted Scanning Sessions",), Icons.photo_camera, "Start Scanning"),
                    adminTags(context, ViewStudents(), Icons.people, "View Students"),
                    adminTags(context, ViewImages(), Icons.image, "View Images"),
                    adminTags(context, ExportDataPage(), Icons.import_export, "Export Data"),
                  ],
                ),
                )
            ],
          ),
        );
  }
}