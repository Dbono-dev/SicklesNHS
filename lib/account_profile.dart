import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/add_new_hours.dart';
import 'package:sickles_nhs_app/database.dart';
import 'package:sickles_nhs_app/event.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:sickles_nhs_app/user.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/settings_page.dart';
import 'package:sickles_nhs_app/messages_page.dart';
import 'package:sickles_nhs_app/leaderboard.dart';

class AccountProfile extends StatelessWidget {
  AccountProfile({Key key, this.posts, this.type, this.name}) : super (key: key);

  final DocumentSnapshot posts;
  final String type;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
          children: <Widget>[
            TopHalfAccountProfile(type: type, posts: posts, name: name),
            Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 3),),
            MiddleAccountProfile(type: type, post: posts),
          ],
        )
    );
  }
}

class TopHalfAccountProfile extends StatelessWidget {
  TopHalfAccountProfile({Key key, this.type, this.posts, this.name}) : super (key: key);

  final String type;
  final DocumentSnapshot posts;
  final String name;

  String adjustedTime = (DateTime(DateTime.now().year, DateTime.now().month, (DateTime.now().day + 1), DateTime.now().minute, DateTime.now().second)).toString();

  @override
  Widget build(BuildContext context) {
  Widget icons() {
    if(type == "admin") {
      return IconButton(
        icon: Icon(Icons.more_horiz),
        color: Colors.white,
        iconSize: 75,
        onPressed: () {
          //Navigator.push(context, 
           // MaterialPageRoute(builder: (context) => MessagesPage()
           // ));
           final act = CupertinoActionSheet(
             title: Text('Elevate Privileges'),
             actions: <Widget>[
               CupertinoActionSheetAction(
                 onPressed: () {
                   DatabaseService(uid: "").updateUserPermissions(2, "05/20/21");
                 },
                 child: Text('Elevate to Officer Permanently')
                 ),
               CupertinoActionSheetAction(
                 onPressed: () {
                  DatabaseService(uid: "r70s5x7XCbfLNp88RRXtUvCue042").updateUserPermissions(2, adjustedTime);
                 },
                 child: Text('Elevate to Officer for a day')
                )
             ],
             cancelButton: CupertinoActionSheetAction(
               onPressed: () {
                 Navigator.pop(context);
               },
               child: Text("Cancel")
               ),
           );
           showCupertinoModalPopup(context: context, builder: (BuildContext context) => act);
        },
      );
    }
    if(type == "student") {
      return Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            color: Colors.white,
            iconSize: 60,
            onPressed: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddNewHours(name: name, post: posts)));
            }
          ),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 0.25)),
          IconButton(
            icon: Icon(Icons.format_list_numbered),
            color: Colors.white,
            iconSize: 60,
            onPressed: () {
              Navigator.push(context, 
                MaterialPageRoute(builder: (context) => Leaderboard())
              );
            }
          ),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 0.25)),
          IconButton(
            icon: Icon(Icons.inbox),
            color: Colors.white,
            iconSize: 60,
            onPressed: () {
              Navigator.push(context, 
                MaterialPageRoute(builder: (context) => MessagesPage()
                ));
            },
          ),
        ],
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
                  iconSize: SizeConfig.blockSizeVertical * 8,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
                ),
                icons(),
                Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 0.25)),
                Container(
                  child: IconButton(
                    icon: Icon(Icons.settings),
                    color: Colors.white,
                    iconSize: 60,
                    onPressed: () {
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => SettingsPage()
                        ));
                    },
                  )
                ),
              ],
            ),
          ),
    );
  }
}

class MiddleAccountProfile extends StatelessWidget {
  MiddleAccountProfile({Key key, this.type, this.post}) : super (key: key);

  final items = Event.getEvents();
  final String type;
  DocumentSnapshot post;

  Future getCompletedHours() async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("Approving Hours").getDocuments();
    return qn.documents;
  }

  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
          if(type == "admin") {
            return Container(
              child: Column(
                children: <Widget>[
                  Container(
                    width: SizeConfig.blockSizeHorizontal * 25,
                    height: 100,
                    child: FloatingActionButton(
                    backgroundColor: Colors.green,
                    elevation: 8,
                    onPressed: () {},
                    child: Text(post.data["first name"].substring(0, 1) + post.data['last name'].substring(0, 1), style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.blockSizeHorizontal * 15
                    ),),
                  ),
                  ),
                  Padding(padding: EdgeInsets.all(4),),
                  Material(child: Text(post.data["first name"] + " " + post.data["last name"], style: TextStyle(fontSize: 35),)),
                  Padding(padding: EdgeInsets.all(1),),
                  Material(child: Text(post.data["grade"] + "th Grade", style: TextStyle(fontSize: 20),)),
                  Padding(padding: EdgeInsets.all(7),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Card(
                        elevation: 8,
                        child: Container(
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.blockSizeHorizontal * 25,
                            child: Material(
                            child: Align(alignment: Alignment.center, child: Text(post.data["hours"] + " Hours", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 8,
                        child: Container(
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.blockSizeHorizontal * 25,
                            child: Material(
                            child: Align(alignment: Alignment.center, child: Text("3 Events", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 8,
                        child: Container(
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.blockSizeHorizontal * 25,
                            child: Material(
                            child: Align(alignment: Alignment.center, child: Text("2 Projects", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
                          ),
                        ),
                      )
                    ],
                    ),
                    Padding(padding: EdgeInsets.all(5),),
                    Material(child: Text("Recent Activity", style: TextStyle(fontSize: 20),),),
                    Container(
                      height: SizeConfig.blockSizeVertical * 33.4,
                        child: FutureBuilder(
                          future: getCompletedHours(),
                          builder: (_, snapshot) {
                            if(snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if(snapshot.data.length == 0) {
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
                              itemCount: snapshot.data.length,
                              itemBuilder: (_, index) {
                              if(snapshot.data[index].data['name'].toString().contains(post.data['first name'].toString() + post.data['last name'].toString()) && snapshot.data[index].data['complete'] == true) {
                                return AccountProfileCards(
                                  title: snapshot.data[index].data['type'],
                                  date: snapshot.data[index].data['date'],
                                  hours: snapshot.data[index].data['hours']
                                );
                              }
                              },
                            ); 
                            }
                          },      
                        ) 
                    )
                ],
              ),
            );
          }
          if(type == "student") {
          return Container(
          child: Column(
            children: <Widget>[
              Container(
                width: SizeConfig.blockSizeHorizontal * 25,
                height: 100,
                child: FloatingActionButton(
                backgroundColor: Colors.green,
                elevation: 8,
                onPressed: () {},
                child: Text(userData.firstName.substring(0, 1) + userData.lastName.substring(0, 1), style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.blockSizeHorizontal * 15
                ),),
              ),
              ),
              Padding(padding: EdgeInsets.all(4),),
              Material(child: Text(userData.firstName + " " + userData.lastName, style: TextStyle(fontSize: 35),)),
              Padding(padding: EdgeInsets.all(1),),
              Material(child: Text(userData.grade + "th Grade", style: TextStyle(fontSize: 20),)),
              Padding(padding: EdgeInsets.all(7),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Card(
                    elevation: 8,
                    child: Container(
                      height: SizeConfig.blockSizeVertical * 7,
                      width: SizeConfig.blockSizeHorizontal * 25,
                        child: Material(
                        child: Align(alignment: Alignment.center, child: Text("5 Hours", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8,
                    child: Container(
                      height: SizeConfig.blockSizeVertical * 7,
                      width: SizeConfig.blockSizeHorizontal * 25,
                        child: Material(
                        child: Align(alignment: Alignment.center, child: Text("3 Events", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8,
                    child: Container(
                      height: SizeConfig.blockSizeVertical * 7,
                      width: SizeConfig.blockSizeHorizontal * 25,
                        child: Material(
                        child: Align(alignment: Alignment.center, child: Text("2 Projects", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
                      ),
                    ),
                  )
                ],
                ),
                Padding(padding: EdgeInsets.all(5),),
                Material(child: Text("Recent Activity", style: TextStyle(fontSize: 20),),),
                Container(
                      height: SizeConfig.blockSizeVertical * 33.4,
                        child: FutureBuilder(
                          future: getCompletedHours(),
                          builder: (_, snapshot) {
                            if(snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if(snapshot.data.length == 0) {
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
                              itemCount: snapshot.data.length,
                              itemBuilder: (_, index) {
                              if((snapshot.data[index].data['name']).toString().contains(userData.firstName + userData.lastName) && snapshot.data[index].data['complete'] == true) {
                                return AccountProfileCards(
                                  title: snapshot.data[index].data['type'],
                                  date: snapshot.data[index].data['date'],
                                  hours: snapshot.data[index].data['hours']
                                );
                              }
                              },
                            ); 
                            }
                          },      
                        ) 
                    )
            ],
          ),
        );
          }
          else {
            return CircularProgressIndicator();
          }
        } else {
          return Container();
        }
        
      }
    );
  }
}

class AccountProfileCards extends StatelessWidget {
  AccountProfileCards({Key key, this.title, this.date, this.hours}) : super (key: key);

  final String title;
  final String date;
  final String hours;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: SizeConfig.blockSizeVertical * 5,
        width: SizeConfig.blockSizeHorizontal * 75,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(title, style: TextStyle(fontSize: 20),),
                  Text(date, style: TextStyle(fontSize: 20),),
                  Text("+" + hours, style: TextStyle(color: Colors.green, fontSize: 20),)
                ],
              ),
            ),
        ),
      ),
    );
  }
}