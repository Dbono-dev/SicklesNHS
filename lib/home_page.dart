import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sickles_nhs_app/account_profile.dart';
import 'package:sickles_nhs_app/add_new_event.dart';
import 'package:sickles_nhs_app/approve_hours.dart';
import 'package:sickles_nhs_app/auth_service.dart';
import 'package:sickles_nhs_app/database.dart';
import 'package:sickles_nhs_app/event_view.dart';
import 'package:date_format/date_format.dart';
import 'package:sickles_nhs_app/event.dart';
import 'package:sickles_nhs_app/important_dates.dart';
import 'package:sickles_nhs_app/scanning_page.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:sickles_nhs_app/user.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/view_students.dart';
import 'package:sickles_nhs_app/notification_system.dart';

class TheOpeningPage extends StatelessWidget {
  TheOpeningPage({Key key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: <Widget>[
              TopHalfHomePage(),
              Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.10),),
              MiddleHomePage(),
              Spacer(),
              BottonHalfHomePage()
            ],
          )
    ); 
  }
}

class MiddleHomePage extends StatelessWidget {
  MiddleHomePage({Key key}) : super (key: key);

    Future getPosts() async {
      var firestore = Firestore.instance;
      QuerySnapshot qn = await firestore.collection("events").getDocuments();
      return qn.documents;
    }

    Future getClubDates() async {
      var firestore = Firestore.instance;
      QuerySnapshot qn = await firestore.collection("Important Dates").getDocuments();
      return qn.documents;
    }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Stack(
      children: <Widget>[
        Container(
          height: SizeConfig.blockSizeVertical * 45,
          padding: EdgeInsets.all(10),
          child: FutureBuilder(
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
                    return MiddleHomePageCards(post: snapshot.data[index]);
                  }
                );
              }
            }
          )
        )
      ],
    );
  }
}

class TopHalfHomePage extends StatelessWidget {
  TopHalfHomePage({Key key}) : super (key: key);

  String timeOfDay;
  int theTiming;

  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);

  DateTime now = DateTime.now();
  String time = formatDate(now, [HH]);
  String theTime = time.substring(0);
  theTiming = int.parse(time);
  print(theTiming);
  if(4 < theTiming && theTiming < 12)
  {
    timeOfDay = "Good Morning ";
  }
  if(theTiming >= 12 && theTiming <= 16)
  {
    timeOfDay = "Good Afternoon ";
  }
  else {
    timeOfDay = "Good Evening ";
  }

  

    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        print(snapshot);
        if(snapshot.hasData) {
          UserData userData = snapshot.data;

          return Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
              height: SizeConfig.blockSizeVertical * 20,
            ),
            Material(
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
                        backgroundColor: Colors.grey,
                        elevation: 8,
                        onPressed: () {
                          Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => AccountProfile(type: "student", name: userData.firstName + userData.lastName, uid: user.uid)
                            ));
                        },
                        child: FittedBox(fit: BoxFit.fitWidth, child: Text(userData.firstName.substring(0, 1) + userData.lastName.substring(0, 1), style: TextStyle(color: Colors.white, fontSize: SizeConfig.blockSizeHorizontal * 9))),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }
}

class MiddleHomePageCards extends StatelessWidget {
  MiddleHomePageCards({Key key, this.post}) : super (key: key);

  final DocumentSnapshot post;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final AuthService _auth = AuthService();
    Color theColor;
    Widget image;

    navigateToDetail(DocumentSnapshot post) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => EventPageView(post: post,)));
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  clipBehavior: Clip.antiAlias,
                                  child: image
                                ),
                              ),
                            ),
                            Text(post.data["title"], style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 6.5,
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

  final items = Event.getEvents();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
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
          AdminMyEvents()
        ]
       );
          }
          if(userData.permissions == 1) {
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
          if(userData.permissions == 2) { //&& (int.parse(userData.date.substring(0, 2)) == DateTime.now().month || int.parse(userData.date.substring(0, 2)) < DateTime.now().month) && int.parse(userData.date.substring(3, 5)) < DateTime.now().day) {
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
            borderRadius: BorderRadius.all(Radius.circular(20)),
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
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final AuthService _auth = AuthService();
    int x = 0;
    final user = Provider.of<User>(context);

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
                  width: MediaQuery.of(context).size.width / 2,
                  child: FittedBox(
                    fit: BoxFit.cover,
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
              height: SizeConfig.blockSizeVertical * 27,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: FutureBuilder(
                      future: MiddleHomePage().getClubDates(),
                      builder: (_, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                            )
                          );
                        }
                        else {
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data.length,
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
                                return Container(height: 0,);
                              }
                              
                            }
                          );
                        }
                        
                      }
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: MiddleHomePage().getPosts(),
                      builder: (_, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          );
                        }
                        else if (snapshot.data.length == 0) {
                          return Material(
                              child: Center(
                              child: Text("NO EVENTS", style: TextStyle(
                                color: Colors.white,
                                fontSize: 45
                              )),
                            ),
                          );
                        }
                        else {
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data.length,
                            itemBuilder: (_, index) {
                              if(snapshot.data[index].data["participates"].contains(userData.firstName + " " + userData.lastName)) {
                                return BottomPageCards(post: snapshot.data[index]);
                              }
                              else {
                                return Container(
                                  height: 0,
                                  width: 0,
                                );
                              }
                            }
                          );
                        }
                      }
                    ),
                  ),
                ],
              )
          ),
              ],
            )
        );
        }
        return Container(
              width: SizeConfig.blockSizeHorizontal * 25,
              child: RaisedButton(
                color: Colors.white,
                      elevation: 8,
                      child: Text("LOGOUT"),
                      onPressed: () async {
                        await _auth.logout();
                      }, 
              ),
            );
      }
    );
}
}

class AdminMyEvents extends StatefulWidget {
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
                    child: Text("Admin", style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    ),)
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 25, 0.0, 0.0, 0.0)),
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 25,
                      child: RaisedButton(
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
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNewEvent()
                    ));
                      },
                        child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(
                              Icons.add_circle,
                              size: 35,
                            ),
                            Text("Add New Event", textAlign: TextAlign.center, style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 5,
                              fontWeight: FontWeight.w600
                            ),),
                          ],
                        )
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.5)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewStudents()
                        ));
                      },
                      child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(
                              Icons.people,
                              size: 35,
                            ),
                            Text("View Students", textAlign: TextAlign.center, style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 5,
                              fontWeight: FontWeight.w600
                            ),),
                          ],
                        )
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.5)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Notifications()
                        ));
                      },
                      child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(
                              Icons.notifications,
                              size: 35,
                            ),
                            Text("Send Notification", textAlign: TextAlign.center, style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 5,
                              fontWeight: FontWeight.w600
                            ),),
                          ],
                        )
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.5)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScanningPage()
                        ));
                      },
                      child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(
                              Icons.photo_camera,
                              size: 35
                            ),
                            Text("Start Scanning", textAlign: TextAlign.center, style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 5,
                              fontWeight: FontWeight.w600
                            ),)
                          ],
                        ),
                      )
                    ),
                    Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.5)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApproveHoursPage()
                        ));
                      },
                      child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(
                              Icons.check_circle,
                              size: 35,
                            ),
                            Text("Approve Hours", textAlign: TextAlign.center, style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 5,
                              fontWeight: FontWeight.w600
                            ),),
                          ],
                        )
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.5)),
                    GestureDetector(
                      onTap: () {

                      },
                      child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget> [
                            Icon(
                              Icons.import_export,
                              size: 35
                            ),
                            Text("Export Data", textAlign: TextAlign.center, style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 5,
                              fontWeight: FontWeight.w600,
                            ),),
                          ]
                        )
                      )
                    ),
                    Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.5)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImportantDateMain()
                        ));
                      },
                      child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(
                              Icons.date_range,
                              size: 35,
                            ),
                            Text("Set Important Dates", textAlign: TextAlign.center, style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 5,
                              fontWeight: FontWeight.w600
                            ),),
                          ],
                        )
                      ),
                    ),
                  ],
              ))
            ],
          ),
        );
}
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
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScanningPage()
                        ));
                      },
                      child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(
                              Icons.photo_camera,
                              size: 35
                            ),
                            Text("Start Scanning", textAlign: TextAlign.center, style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical * 5,
                              fontWeight: FontWeight.w600
                            ),)
                          ],
                        ),
                      )
                    ),
                  ],
              ))
            ],
          ),
        );
  }
}