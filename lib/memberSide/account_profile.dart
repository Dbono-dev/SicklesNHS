import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/memberSide/add_new_hours.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/memberSide/create_new_event_options.dart';
import 'package:sickles_nhs_app/memberSide/settings_page.dart';
import 'package:sickles_nhs_app/backend/messages_page.dart';
import 'package:sickles_nhs_app/memberSide/leaderboard.dart';
import 'package:intl/intl.dart';
import 'package:sickles_nhs_app/backend/globals.dart' as global;

class AccountProfile extends StatefulWidget {
  AccountProfile({Key key, this.posts, this.type, this.name, this.uid, this.hours}) : super (key: key);

  final DocumentSnapshot posts;
  final String type;
  final String name;
  final String uid;
  final int hours;

  @override
  _AccountProfileState createState() => _AccountProfileState();
}

class _AccountProfileState extends State<AccountProfile> {
  bool editing;
  String adjustedTime = (DateTime(DateTime.now().year, DateTime.now().month, (DateTime.now().day + 1), DateTime.now().minute, DateTime.now().second)).toString();
  List completedEvents = new List();

  String newHour;

  Future getCompletedHours(String uid) async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("members").getDocuments();
    return qn.documents;
  }

  Future getQuarterHours() async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("Important Dates").getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              topHalfOfAccountProfile(context),
              Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 3),),
              middleAcountProfilePage(context)
            ],
          ),
      )
    );
  }

  Widget icons(BuildContext context) {
    if(widget.type == "admin") {
      return Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            color: Colors.white,
            iconSize: 75,
            onPressed: () {
               final act = CupertinoActionSheet(
                 title: Text('Elevate Privileges'),
                 actions: <Widget>[
                   CupertinoActionSheetAction(
                     onPressed: () {
                       DatabaseService(uid: widget.uid).updateUserPermissions(2, "05/20/21");
                     },
                     child: Text('Elevate to Officer Permanently')
                     ),
                   CupertinoActionSheetAction(
                     onPressed: () {
                      DatabaseService(uid: widget.uid).updateUserPermissions(2, adjustedTime);
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
          editing != true ? IconButton(
            icon: Icon(Icons.edit),
            color: Colors.white,
            iconSize: 60,
            onPressed: () {
              setState(() {
                editing = true;
              });
            },
          ) : Container(),
          Padding(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 0.25),
            child: editing == true ? RaisedButton(
              onPressed: () async {
                List eventHoursList = new List();
                eventHoursList = widget.posts.data['event hours'];
                for(int i = 0; i < global.theMap.length; i++) {
                  eventHoursList[i] = global.theMap[i];
                }
                await DatabaseService(uid: widget.posts.data['uid']).updateCompetedEvents(widget.posts.data['event title'], widget.posts.data['event date'], eventHoursList);
                setState(() {
                  editing = false;
                });
              },
              elevation: 8,
              color: Colors.white,
              child: Text("SAVE"),
            ) : Container(),
          ),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 0.5),),          
        ],
      );
    }
    if(widget.type == "student") {
      return Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            color: Colors.white,
            iconSize: 60,
            onPressed: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateNewHoursOptionsPage()));
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

  Widget topHalfOfAccountProfile(BuildContext context) {
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
                Spacer(),
                icons(context),                
              ],
            ),
          ),
    );
  }

  Widget middleAcountProfilePage(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
          if(widget.type == "admin") {
            return recentActivity(widget.posts.data['first name'], widget.posts.data['last name'], widget.posts.data['grade'], widget.posts.data['uid'], widget.posts.data['hours'].toString(), widget.posts['firstQuarter'].toString(), widget.posts['secondQuarter'].toString(), widget.posts['thirdQuarter'].toString(), widget.posts['fourthQuarter'].toString());
          }
          if(widget.type == "student") {
            return recentActivity(userData.firstName, userData.lastName, userData.grade, user.uid, userData.hours.toString(), userData.firstQuarter.toString(), userData.secondQuarter.toString(), userData.thirdQuarter.toString(), userData.fourthQuarter.toString());
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

  Widget recentActivity(String firstName, String lastName, String grade, String uid, String hours, String q1Hours, String q2Hours, String q3Hours, String q4Hours) {
    Color _theColor = Colors.white;
    Color _theTextColor = Colors.black;

    List title = new List ();
    List date = new List ();
    List theHours = new List ();
    List<DateTime> thenewDate = new List<DateTime>();

    DateTime startOfSchool;
    DateTime firstQuarter;
    DateTime secondQuarter;
    DateTime thirdQuarter;
    DateTime forthQuarter;
    bool thefirstQuarter = false;
    bool thesecondQuarter = false;
    bool thethirdQuarter = false;
    bool theforthQuarter = false;
    DateFormat format = new DateFormat("MM/dd/yyyy");
    DateFormat secondFormat = new DateFormat("MM-dd-yyyy");

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
          Material(
            child: editing != true ? Text(
              firstName + " " + lastName, style: TextStyle(fontSize: 35),
              ) : SizedBox(
                width: SizeConfig.blockSizeHorizontal * 65,
                child: TextFormField(
                  style: TextStyle(fontSize: 35),
                  textAlign: TextAlign.center,
                  initialValue: firstName + " " + lastName,
            ),
              )
          ),
          Padding(padding: EdgeInsets.all(1),),
          Material(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                editing == true ? SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 7.5,
                  child: TextFormField(
                    initialValue: grade,
                    keyboardType: TextInputType.number,
                  ),
                ) : Text(grade, style: TextStyle(fontSize: 20)),
                Text(
                  "th Grade", style: TextStyle(fontSize: 20),
                ),
              ],
            )
          ),
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
                for(int theIndex = 0; theIndex < snapshot.data.length; theIndex++) {
                  if(snapshot.data[theIndex].data['first name'] + snapshot.data[theIndex].data['last name'] == firstName + lastName) {
                    title = snapshot.data[theIndex].data['event title'];
                    date = snapshot.data[theIndex].data['event date'];
                    theHours = snapshot.data[theIndex].data['event hours'];

                    for(int i = 0; i < date.length; i++) {
                      thenewDate.add(format.parse(date[i]));
                    }
                    /*if(howManyEvents == "" || howManyEvents == null) {

                    }
                    else {
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
                    }*/
                  }
                }

                return Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Padding(
                                padding: EdgeInsets.fromLTRB(0, SizeConfig.blockSizeVertical * 15, 0, SizeConfig.blockSizeVertical * 15),
                                child: AlertDialog(
                                  title: Text("Hours"),
                                  content: Column(
                                    children: <Widget> [
                                      ListTile(title: Text("Quarter 1: " + q1Hours), trailing: int.parse(q1Hours) >= 6 ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.close, color: Colors.red,),),
                                      ListTile(title: Text("Quarter 2: " + q2Hours), trailing: int.parse(q2Hours) >= 6 ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.close, color: Colors.red,)),
                                      ListTile(title: Text("Quarter 3: " + q3Hours), trailing: int.parse(q3Hours) >= 6 ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.close, color: Colors.red,)),
                                      ListTile(title: Text("Quarter 4: " + q4Hours), trailing: int.parse(q4Hours) >= 6 ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.close, color: Colors.red,)),
                                    ]
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("DONE", style: TextStyle(color: Colors.green),),
                                    )
                                  ],
                                ),
                              );
                            }
                          );
                        },
                        child: Card(
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
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.green),
                              ),
                            );
                          }
                          else {
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
                                child: FutureBuilder(
                                  future: getQuarterHours(),
                                  builder: (_, quarterHours) {
                                    if(quarterHours.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Colors.green),
                                      ));
                                    }
                                    else {
                                      for(int i = 0; i < quarterHours.data.length; i++) {
                                        if(quarterHours.data[i].data['type'] == "endOfQuarter" && quarterHours.data[i].data['quarter'] == "Start of School") {
                                          startOfSchool = secondFormat.parse(quarterHours.data[i].data['date']);
                                        }
                                        if(quarterHours.data[i].data['type'] == "endOfQuarter" && quarterHours.data[i].data['quarter'] == "First") {
                                          firstQuarter = secondFormat.parse(quarterHours.data[i].data['date']);
                                        }
                                        if(quarterHours.data[i].data['type'] == "endOfQuarter" && quarterHours.data[i].data['quarter'] == "Second") {
                                          secondQuarter = secondFormat.parse(quarterHours.data[i].data['date']);
                                        }
                                        if(quarterHours.data[i].data['type'] == "endOfQuarter" && quarterHours.data[i].data['quarter'] == "Third") {
                                          thirdQuarter = secondFormat.parse(quarterHours.data[i].data['date']);
                                        }
                                        if(quarterHours.data[i].data['type'] == "endOfQuarter" && quarterHours.data[i].data['quarter'] == "Fourth") {
                                          forthQuarter = secondFormat.parse(quarterHours.data[i].data['date']);
                                        }
                                      }
                                    }
                                    return ListView.builder(
                                      itemCount: title.length,
                                      itemBuilder: (_, index) {
                                        if(thenewDate[index].isAfter(startOfSchool) && thenewDate[index].isBefore(firstQuarter)) {
                                          if(thefirstQuarter == true) {
                                            return accountProfileCards(
                                              title: title[index],
                                              date: date[index].toString().substring(0, 10),
                                              hours: theHours[index],
                                                  editing: editing,
                                                  index: index
                                            );
                                          }
                                          else {
                                            thefirstQuarter = true;
                                            return Column(
                                              children: <Widget>[
                                                quarterPages("First"),
                                                accountProfileCards(
                                                  title: title[index],
                                                  date: date[index].toString().substring(0, 10),
                                                  hours: theHours[index],
                                                  editing: editing,
                                                  index: index
                                                )
                                              ],
                                            );
                                          }
                                        }
                                        if(thenewDate[index].isAfter(firstQuarter) && thenewDate[index].isBefore(secondQuarter)) {
                                          if(thesecondQuarter == true) {
                                            return accountProfileCards(
                                              title: title[index],
                                              date: date[index].toString().substring(0, 10),
                                              hours: theHours[index],
                                              editing: editing,
                                              index: index
                                            );
                                          }
                                          else {
                                            thesecondQuarter = true;
                                            return Column(
                                              children: <Widget>[
                                                quarterPages("Third"),
                                                accountProfileCards(
                                                  title: title[index],
                                                  date: date[index].toString().substring(0, 10),
                                                  hours: theHours[index],
                                                  editing: editing,
                                                  index: index
                                                )
                                              ],
                                            );
                                          }
                                        }
                                        if(thenewDate[index].isAfter(secondQuarter) && thenewDate[index].isBefore(thirdQuarter)) {
                                          if(thethirdQuarter == true) {
                                            return accountProfileCards(
                                              title: title[index],
                                              date: date[index].toString().substring(0, 10),
                                              hours: theHours[index],
                                                  editing: editing,
                                                  index: index
                                            );
                                          }
                                          else {
                                            thethirdQuarter = true;
                                            return Column(
                                              children: <Widget>[
                                                quarterPages("Third"),
                                                accountProfileCards(
                                                  title: title[index],
                                                  date: date[index].toString().substring(0, 10),
                                                  hours: theHours[index],
                                                  editing: editing,
                                                  index: index
                                                )
                                              ],
                                            );
                                          }
                                        }
                                        if(thenewDate[index].isAfter(thirdQuarter) && thenewDate[index].isBefore(forthQuarter)) {
                                          if(theforthQuarter == true) {
                                            return accountProfileCards(
                                              title: title[index],
                                              date: date[index].toString().substring(0, 10),
                                              hours: theHours[index],
                                              editing: editing,
                                              index: index
                                            );
                                          }
                                          else {
                                            theforthQuarter = true;
                                            return Column(
                                              children: <Widget>[
                                                quarterPages("Fourth"),
                                                accountProfileCards(
                                                  title: title[index],
                                                  date: date[index].toString().substring(0, 10),
                                                  hours: theHours[index],
                                                  editing: editing,
                                                  index: index
                                                )
                                              ],
                                            );
                                          }
                                        }
                                      }
                                    );
                                  },
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

  Widget quarterPages(String quarter) {
    return Material(
      child: Container(
        height: SizeConfig.blockSizeVertical * 6,
        width: SizeConfig.blockSizeHorizontal * 90,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
            child: Align(
              alignment: Alignment.center,
              child: Text(quarter + " Quarter", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            )
        )
      )
    );
  }


Widget accountProfileCards({Key key, String title, String date, String hours, bool editing, int index}) {
    return Material(
      child: Container(
        height: SizeConfig.blockSizeVertical * 6,
        width: SizeConfig.blockSizeHorizontal * 90,
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
                  editing == true ? SizedBox(
                    width: SizeConfig.blockSizeHorizontal * 7.5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                      child: Form(
                        child: TextFormField(
                          onChanged: (val) {
                            Map<int, String> details = {index: val.toString()};
                            global.theMap = details;
                          },
                          initialValue: hours,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ) : Text("+" + hours, style: TextStyle(color: Colors.green, fontSize: 20),)
                ],
              ),
            ),
        ),
      ),
    );
  }
