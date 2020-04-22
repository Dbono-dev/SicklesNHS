import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/add_new_hours.dart';
import 'package:sickles_nhs_app/database.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:sickles_nhs_app/user.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/settings_page.dart';
import 'package:sickles_nhs_app/messages_page.dart';
import 'package:sickles_nhs_app/leaderboard.dart';

class AccountProfile extends StatelessWidget {
  AccountProfile({Key key, this.posts, this.type, this.name, this.uid, this.hours}) : super (key: key);

  final DocumentSnapshot posts;
  final String type;
  final String name;
  final String uid;
  final int hours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
          children: <Widget>[
            TopHalfAccountProfile(type: type, uid: uid, name: name, hours: hours,),
            Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 3),),
            MiddleAccountProfile(type: type, post: posts),
          ],
        )
    );
  }
}

class TopHalfAccountProfile extends StatelessWidget {
  TopHalfAccountProfile({Key key, this.type, this.uid, this.name, this.hours}) : super (key: key);

  final String type;
  final String uid;
  final String name;
  final int hours;

  String adjustedTime = (DateTime(DateTime.now().year, DateTime.now().month, (DateTime.now().day + 1), DateTime.now().minute, DateTime.now().second)).toString();

  @override
  Widget build(BuildContext context) {
  Widget icons() {
    if(type == "admin") {
      return Row(
        children: <Widget>[
          IconButton(
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
                       DatabaseService(uid: uid).updateUserPermissions(2, "05/20/21");
                     },
                     child: Text('Elevate to Officer Permanently')
                     ),
                   CupertinoActionSheetAction(
                     onPressed: () {
                      DatabaseService(uid: uid).updateUserPermissions(2, adjustedTime);
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
          ),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 0.25),),
          IconButton(
            icon: Icon(Icons.edit),
            color: Colors.white,
            iconSize: 60,
            onPressed: () {
              
            },
          ),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 0.25),),          
        ],
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
              MaterialPageRoute(builder: (context) => AddNewHours(name: name, uid: uid, hours: hours,)));
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
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 0.25),),
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
                //Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),),
                Spacer(),
                icons(),                
              ],
            ),
          ),
    );
  }
}

class MiddleAccountProfile extends StatelessWidget {
  MiddleAccountProfile({Key key, this.type, this.post}) : super (key: key);

  final String type;
  DocumentSnapshot post;
  List completedEvents = new List();
  String _events;

  Future getCompletedHours(String uid) async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("members").getDocuments();
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
            return recentActivity(post.data['first name'], post.data['last name'], post.data['grade'], post.data['uid'], post.data['hours'].toString());
          }
          if(type == "student") {
            return recentActivity(userData.firstName, userData.lastName, userData.grade, user.uid, userData.hours.toString());
          }
          else {
            return CircularProgressIndicator();
          }
        }
        else {
          return Container();
        }
      }
    );
  }

  Widget recentActivity(String firstName, String lastName, String grade, String uid, String hours) {
    Color _theColor = Colors.white;
    Color _theTextColor = Colors.black;

    List<String> title = new List<String> ();
    List<String> date = new List<String> ();
    List<String> theHours = new List<String> ();

    if(int.parse(hours) >= 6) {
      _theColor = Colors.green;
      _theTextColor = Colors.white;
    }

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
            child: Text(firstName.substring(0, 1) + lastName.substring(0, 1), style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.blockSizeHorizontal * 15
            ),),
          ),
          ),
          Padding(padding: EdgeInsets.all(4),),
          Material(child: Text(firstName + " " + lastName, style: TextStyle(fontSize: 35),)),
          Padding(padding: EdgeInsets.all(1),),
          Material(child: Text(grade + "th Grade", style: TextStyle(fontSize: 20),)),
          Padding(padding: EdgeInsets.all(7),),

          FutureBuilder(
            future: getCompletedHours(uid),
            builder: (_, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                );
              }
              else {
                String howManyEvents;
                for(int theIndex = 0; theIndex < snapshot.data.length; theIndex++) {
                  if(snapshot.data[theIndex].data['first name'] + snapshot.data[theIndex].data['last name'] == firstName + lastName) {
                    howManyEvents = snapshot.data[theIndex].data['event title'];

                    for(int i = 0; i < howManyEvents.length; i++) {
                      if(howManyEvents.substring(0, i).contains("-")) {
                        title.add(howManyEvents.substring(0, i - 1));
                        howManyEvents = howManyEvents.substring(i);
                        i = 0;
                      }
                      else if(i == howManyEvents.length - 1) {
                        title.add(howManyEvents);
                      }
                    }
                  }
                }

                return Column(
                children: <Widget>[
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
                              color: _theColor,
                              child: Align(alignment: Alignment.center, child: Text(hours.toString() + " Hours", style: TextStyle(fontSize: 20, color: _theTextColor), textAlign: TextAlign.center,)),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 8,
                        child: Container(
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.blockSizeHorizontal * 25,
                            child: Material(
                            child: Align(alignment: Alignment.center, child: Text(title.length.toString() + " Events", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 8,
                        child: Container(
                          height: SizeConfig.blockSizeVertical * 7,
                          width: SizeConfig.blockSizeHorizontal * 25,
                            child: Material(
                            child: Align(alignment: Alignment.center, child: Text("0 Projects", style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
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
                        future: getCompletedHours(uid),
                        builder: (_, snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          else {
                            String theEventDate;
                            String theEventHours;

                            for(int theIndex = 0; theIndex < snapshot.data.length; theIndex++) {
                              if(snapshot.data[theIndex].data['first name'] + snapshot.data[theIndex].data['last name'] == firstName + lastName) {
                                theEventDate = snapshot.data[theIndex].data['event date'];
                                theEventHours = snapshot.data[theIndex].data['event hours'];

                                /*for(int i = 0; i < theEventTitle.length; i++) {
                                  if(theEventTitle.substring(0, i).contains("-")) {
                                    title.add(theEventTitle.substring(0, i - 1));
                                    theEventTitle = theEventTitle.substring(i);
                                    i = 0;
                                  }
                                  else if(i == theEventTitle.length - 1) {
                                    title.add(theEventTitle);
                                  }
                                }*/

                                for(int i = 0; i < theEventDate.length; i++) {
                                  if(theEventDate.substring(0, i).contains("-")) {
                                    date.add(theEventDate.substring(0, i - 1));
                                    theEventDate = theEventDate.substring(i);
                                    i = 0;
                                  }
                                  else if(i == theEventDate.length - 1) {
                                    date.add(theEventDate);
                                  }
                                }

                                for(int i = 0; i <= theEventHours.length; i++) {
                                  if(theEventHours.substring(0, i).contains("-")) {
                                    theHours.add(theEventHours.substring(0, i - 1));
                                    theEventHours = theEventHours.substring(i);
                                    i = 0;
                                  }
                                  else if(i == theEventHours.length) {
                                    theHours.add(theEventHours);
                                  }
                                }
                              }
                            }
                            if(title.length == 0) {
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
                              return Container(
                                width: SizeConfig.blockSizeHorizontal * 92.5,
                                child: ListView.builder(
                                  itemCount: title.length,
                                  itemBuilder: (_, index) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                                      child: AccountProfileCards(
                                        title: title[index],
                                        date: date[index],
                                        hours: theHours[index]
                                      ),
                                    );
                                  }
                                ),
                              );
                            }
                          }
                        },      
                      ) 
                  )
                ],
              );
              }
          }
          )
        ],
      ),
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
        height: SizeConfig.blockSizeVertical * 6,
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