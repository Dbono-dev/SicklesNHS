import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/currentQuarter.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/home_page.dart';
import 'package:sickles_nhs_app/memberSide/create_new_event_options.dart';
import 'package:sickles_nhs_app/memberSide/send_images.dart';
import 'package:sickles_nhs_app/memberSide/settings_page.dart';
import 'package:sickles_nhs_app/memberSide/messages_page.dart';
import 'package:sickles_nhs_app/memberSide/leaderboard.dart';
import 'package:intl/intl.dart';
import 'package:sickles_nhs_app/backend/globals.dart' as global;

class AccountProfile extends StatefulWidget {
  AccountProfile({Key key, this.posts, this.type, this.name, this.uid}) : super (key: key);

  final DocumentSnapshot posts;
  final String type;
  final String name;
  final String uid;

  @override
  _AccountProfileState createState() => _AccountProfileState();
}

class _AccountProfileState extends State<AccountProfile> {
  bool editing;
  String adjustedTime = (DateTime(DateTime.now().year, DateTime.now().month, (DateTime.now().day + 1), DateTime.now().minute, DateTime.now().second)).toString();
  List completedEvents = new List();

  String newHour;
  String currentQuarter;

  Future getCompletedHours(String uid) async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("members").getDocuments();
    currentQuarter = await CurrentQuarter(DateTime.now()).currentQuarter();
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
      body: Container(
        height: SizeConfig.blockSizeVertical * 100,
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
                       DatabaseService(uid: widget.uid).updateUserPermissions(1, "05/20/2021");
                     },
                     child: Text('Elevate to Officer Permanently')
                     ),
                   CupertinoActionSheetAction(
                     onPressed: () {
                      DatabaseService(uid: widget.uid).updateUserPermissions(1, adjustedTime);
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
          iconsForTopAccountProfile(Icons.add_circle_outline, CreateNewHoursOptionsPage(tile1: "Create New Service Hour Form", tile2: "View Saved Service Hour Forms", tile3: "View Submitted Service Hour Forms", uid: widget.uid,)),
          iconsForTopAccountProfile(Icons.format_list_numbered, Leaderboard()),
          iconsForTopAccountProfile(Icons.image, SendImages(name: widget.name,)),
          iconsForTopAccountProfile(Icons.inbox, MessagesPage()),
          iconsForTopAccountProfile(Icons.settings, SettingsPage())
        ],
      );
    }
    else {
      return Container();
    }
  }

  Widget iconsForTopAccountProfile(IconData icon, Widget location) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, SizeConfig.blockSizeHorizontal * 0.05, 0),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 40,
        onPressed: () {
          Navigator.push(context, 
            MaterialPageRoute(builder: (context) => location)
          );
        }
      ),
    );
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => TheOpeningPage()));
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
            return recentActivity(widget.posts.data['first name'], widget.posts.data['last name'], widget.posts.data['grade'], widget.posts.data['uid'], widget.posts.data['hours'].toString(), widget.posts['firstQuarter'].toString(), widget.posts['secondQuarter'].toString(), widget.posts['thirdQuarter'].toString(), widget.posts['fourthQuarter'].toString(), widget.posts['numClub'], widget.posts['num of community service events']);
          }
          if(widget.type == "student") {
            return recentActivity(userData.firstName, userData.lastName, userData.grade, user.uid, userData.hours.toString(), userData.firstQuarter.toString(), userData.secondQuarter.toString(), userData.thirdQuarter.toString(), userData.fourthQuarter.toString(), userData.numClub, userData.numOfCommunityServiceEvents);
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

  Widget recentActivity(String firstName, String lastName, String grade, String uid, String hours, String q1Hours, String q2Hours, String q3Hours, String q4Hours, int numClub, int numOfCommunityServiceEvents) {
    Color _theColor = Colors.white;
    Color _theTextColor = Colors.black;
    Color _chapterProjectColor = Colors.transparent;
    Color _chapterProjectTextColor = Colors.black;

    List title = new List ();
    List date = new List ();
    List theHours = new List ();
    List<DateTime> thenewDate = new List<DateTime>();
    String currentQuarterHours;

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

    return Container(
      height: SizeConfig.blockSizeVertical * 74,
      child: Column(
        children: <Widget>[
          Container(
            width: SizeConfig.blockSizeHorizontal * 25,
            height: SizeConfig.blockSizeVertical * 18,
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              elevation: 8,
              onPressed: () {},
              child: Text(firstName.substring(0, 1) + lastName.substring(0, 1), style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.blockSizeHorizontal * 12.5
              ),
             ),
           ),
          ),
          Padding(padding: EdgeInsets.all(4),),
          Material(
            color: Colors.transparent,
            child: editing != true ? Text(
              firstName + " " + lastName, style: TextStyle(fontSize: 35),
              ) : SizedBox(
                height: SizeConfig.blockSizeVertical * 5,
                width: SizeConfig.blockSizeHorizontal * 65,
                child: TextFormField(
                  style: TextStyle(fontSize: 35),
                  textAlign: TextAlign.center,
                  initialValue: firstName + " " + lastName,
            ),
              )
          ),
          Padding(padding: EdgeInsets.all(1),),
          int.tryParse(grade) == null ? Material(
            color: Colors.transparent,
            child: Text(grade, style: TextStyle(fontSize: 20),),)
            : Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                editing == true ? SizedBox(
                  height: SizeConfig.blockSizeVertical * 5,
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

                    if(date != null) {
                      for(int i = 0; i < date.length; i++) {
                        thenewDate.add(format.parse(date[i]));
                      }
                    }
                  }
                }
                
                void hoursTile(String quarters, String quartersHours, int numOfHoursForThatQuarter) {
                  if(currentQuarter == quarters) {
                    currentQuarterHours = quartersHours;
                    if(double.parse(quartersHours) >= numOfHoursForThatQuarter) {
                      _theColor = Colors.green;
                      _theTextColor = Colors.white;
                    }
                  }
                }

                Future chapterProjectTile(theHours, date, hours) async {
                  List<DocumentSnapshot> quarterHours = await getQuarterHours();
                  if(theHours.length != 0) {
                    for(int i = 0; i < quarterHours.length; i++) {
                      if(quarterHours[i].data['type'] == "endOfQuarter" && quarterHours[i].data['quarter'] == "Start of School") {
                        startOfSchool = secondFormat.parse(quarterHours[i].data['date']);
                      }
                      if(quarterHours[i].data['type'] == "endOfQuarter" && quarterHours[i].data['quarter'] == "First") {
                        firstQuarter = secondFormat.parse(quarterHours[i].data['date']);
                      }
                      if(quarterHours[i].data['type'] == "endOfQuarter" && quarterHours[i].data['quarter'] == "Second") {
                        secondQuarter = secondFormat.parse(quarterHours[i].data['date']);
                      }
                      if(quarterHours[i].data['type'] == "endOfQuarter" && quarterHours[i].data['quarter'] == "Third") {
                        thirdQuarter = secondFormat.parse(quarterHours[i].data['date']);
                      }
                      if(quarterHours[i].data['type'] == "endOfQuarter" && quarterHours[i].data['quarter'] == "Fourth") {
                        forthQuarter = secondFormat.parse(quarterHours[i].data['date']);
                      }
                    }
                    bool firstOrSecond;
                    if(DateTime.now().isBefore(secondQuarter) && DateTime.now().isAfter(startOfSchool)) {
                      firstOrSecond = true;
                    }
                    else if (DateTime.now().isBefore(forthQuarter) && DateTime.now().isAfter(secondQuarter)) {
                      firstOrSecond = false;
                    }
                    else {

                    }
                    
                    for(int i = 0; i < theHours.length; i++) {
                      if(double.parse(theHours[i]) == 0) {
                        if(format.parse(date[i]).isBefore(secondQuarter) && format.parse(date[i]).isAfter(startOfSchool) && firstOrSecond == true) {
                          _chapterProjectColor = Colors.green;
                          _chapterProjectTextColor = Colors.white;
                        }
                        else if(format.parse(date[i]).isBefore(forthQuarter) && format.parse(date[i]).isAfter(secondQuarter) && firstOrSecond == false) {
                          _chapterProjectColor = Colors.green;
                          _chapterProjectTextColor = Colors.white;
                        }
                        else {

                        }
                      }
                    }
                  }
                  
                }

                hoursTile("firstQuarter", q1Hours, 0);
                hoursTile("secondQuarter", q2Hours, 3);
                hoursTile("thirdQuarter", q3Hours, 6);
                hoursTile("fourthQuarter", q4Hours, 6);

                return FutureBuilder(
                  future: chapterProjectTile(theHours, date, hours),
                  builder: (context, snapshot) {
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
                                    padding: EdgeInsets.fromLTRB(0, SizeConfig.blockSizeVertical * 10, 0, SizeConfig.blockSizeVertical * 10),
                                    child: AlertDialog(
                                      title: Text("Hours"),
                                      content: Column(
                                        children: <Widget> [
                                          ListTile(title: Text("Quarter 1: " + q1Hours), trailing: double.parse(q1Hours) >= 0 ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.close, color: Colors.red,),),
                                          ListTile(title: Text("Quarter 2: " + q2Hours), trailing: double.parse(q2Hours) >= 3 ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.close, color: Colors.red,)),
                                          ListTile(title: Text("Quarter 3: " + q3Hours), trailing: double.parse(q3Hours) >= 6 ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.close, color: Colors.red,)),
                                          ListTile(title: Text("Quarter 4: " + q4Hours), trailing: double.parse(q4Hours) >= 6 ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.close, color: Colors.red,)),
                                          ListTile(title: Text("Total: " + hours, style: TextStyle(fontWeight: FontWeight.bold)),),
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
                                    child: Align(alignment: Alignment.center, child: Text(currentQuarterHours.toString() + " Hours", style: TextStyle(fontSize: 20, color: _theTextColor), textAlign: TextAlign.center,)),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              QuerySnapshot qn = await Firestore.instance.collection('Important Dates').getDocuments();
                              var result = qn.documents;
                              List<Widget> clubDates = new List<Widget>();
                              if(qn.documents.length == 4) {
                                for(int i = 0; i < result.length; i++) {
                                  DocumentSnapshot theResult = result[i];
                                  if(theResult.data['type'] == "clubDates") {
                                    if(widget.type == "admin") {
                                      clubDates.add(
                                        Container(
                                          width: SizeConfig.blockSizeHorizontal * 80,
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: SizeConfig.blockSizeHorizontal * 45,
                                                child: ListTile(
                                                  title: Text(theResult['date'].toString()),
                                                  trailing: theResult.data['participates'].contains(uid) ? Icon(Icons.check, color: Colors.green) : Icon(Icons.close, color: Colors.red),
                                                ),
                                              ),
                                              RaisedButton(
                                                elevation: 10,
                                                color: Colors.white,
                                                onPressed: () async {
                                                  List participatesList = new List();
                                                  participatesList = theResult.data['participates'];
                                                  if(theResult.data['participates'].contains(uid)) {
                                                    participatesList.remove(uid);
                                                    await DatabaseImportantDates().addParticipates(participatesList, theResult.data['type'], theResult.data['inital date']);
                                                    await DatabaseService(uid: uid).updateNumOfClub(numClub - 1);
                                                    setState(() {
                                                      
                                                    });
                                                    super.setState(() { });
                                                  }
                                                  else {
                                                    participatesList.add(uid);
                                                    await DatabaseImportantDates().addParticipates(participatesList, theResult.data['type'], theResult.data['inital date']);
                                                    await DatabaseService(uid: uid).updateNumOfClub(numClub + 1);
                                                    setState(() {
                                                      
                                                    });
                                                  }
                                                },
                                                child: Text("Change", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                                              )
                                            ],
                                          ),
                                        )
                                      );
                                    }
                                    else {
                                      clubDates.add(
                                        Container(
                                          width: SizeConfig.blockSizeHorizontal * 45,
                                          child: ListTile(
                                            title: Text(theResult['date'].toString()),
                                            trailing: theResult.data['participates'].contains(uid) ? Icon(Icons.check, color: Colors.green) : Icon(Icons.close, color: Colors.red),
                                          ),
                                        )
                                      );
                                    }
                                  }
                                }
                              }
                              else {
                                clubDates.add(
                                  Text("No Club Meetings")
                                );
                              }

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Club Meeting Attendence"),
                                    content: Container(
                                      height: SizeConfig.blockSizeVertical * 40,
                                      child: Column(
                                        children: clubDates,
                                      )
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Done", style: TextStyle(color: Colors.green),),
                                      )
                                    ],
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
                                    color: Colors.transparent,
                                  child: Align(alignment: Alignment.center, child: Text(numClub.toString() + " Meetings", style: TextStyle(fontSize: 15), textAlign: TextAlign.center,)),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              List<Widget> chapterProjects = new List<Widget>();
                              int getsOne = 0;
                              for(int i = 0; i < theHours.length; i++) {
                                if(double.parse(theHours[i]) == 0) {
                                  getsOne++;
                                  chapterProjects.add(Container(
                                    width: SizeConfig.blockSizeHorizontal * 65,
                                    child: ListTile(
                                      title: Text(title[i].toString()),
                                      trailing: Icon(Icons.check, color: Colors.green),
                                    ),
                                  ));
                                }
                                else {
                                  if(getsOne == 0) {
                                    chapterProjects.add(
                                      Text("No Chapter Projects", textAlign: TextAlign.center),
                                    );
                                  }
                                  else {

                                  }
                                }
                              }
                              if(theHours.length == 0) {
                                chapterProjects.add(
                                  Text("No Chapter Projects", textAlign: TextAlign.center),
                                );
                              }

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Chapter Projects"),
                                    content: Container(
                                      height: SizeConfig.blockSizeVertical * 40,
                                      child: Column(
                                        children: chapterProjects,
                                      )
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Done", style: TextStyle(color: Colors.green),),
                                      )
                                    ],
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
                                  color: _chapterProjectColor,
                                  child: Align(alignment: Alignment.center, child: Text(numOfCommunityServiceEvents.toString() + " Projects", style: TextStyle(fontSize: 20, color: _chapterProjectTextColor), textAlign: TextAlign.center,)),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
              Padding(padding: EdgeInsets.all(5),),
              Material(
                    color: Colors.transparent,
                    child: Text("Recent Activity", 
                    style: TextStyle(fontSize: 20),
                    ),)
              ,
              Container(
                    height: SizeConfig.blockSizeVertical * 27,
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
                          if(title.length == 0) {
                            return Center(
                              child: Text("NO EVENTS", style: TextStyle(color: Colors.green, fontSize: 40)),
                            );
                          }
                          else {
                            return ListView.builder(
                              itemCount: title.length,
                              itemBuilder: (_, index) {
                                if(thenewDate[index].isAfter(startOfSchool) && thenewDate[index].isBefore(firstQuarter)) {
                                  if(thefirstQuarter == true) {
                                    return Column(
                                      children: <Widget>[
                                        accountProfileCards(
                                          title: title[index],
                                          date: date[index].toString().substring(0, 10),
                                          hours: theHours[index],
                                              editing: editing,
                                              index: index
                                        ),
                                      ],
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
                                    return Column(
                                      children: <Widget>[
                                        accountProfileCards(
                                          title: title[index],
                                          date: date[index].toString().substring(0, 10),
                                          hours: theHours[index],
                                          editing: editing,
                                          index: index
                                        ),
                                      ],
                                    );
                                  }
                                  else {
                                    thesecondQuarter = true;
                                    return Column(
                                      children: <Widget>[
                                        quarterPages("Second"),
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
                                    return Column(
                                      children: <Widget>[
                                        accountProfileCards(
                                          title: title[index],
                                          date: date[index].toString().substring(0, 10),
                                          hours: theHours[index],
                                          editing: editing,
                                          index: index
                                        ),
                                      ],
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
                                    return Column(
                                      children: <Widget>[
                                        accountProfileCards(
                                          title: title[index],
                                          date: date[index].toString().substring(0, 10),
                                          hours: theHours[index],
                                          editing: editing,
                                          index: index
                                        ),
                                      ],
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
                          }
                        },
                      ),  
                    )
              ],
            );
                  }
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
      color: Colors.transparent,
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
      color: Colors.transparent,
      child: Container(
        height: SizeConfig.blockSizeVertical * 8,
        width: SizeConfig.blockSizeHorizontal * 90,
        child: Card(
          color: double.parse(hours) == 0 ? Colors.yellow[400] : Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: SizeConfig.blockSizeHorizontal * 40,
                    child: Text(title, style: TextStyle(fontSize: 15), textAlign: TextAlign.center,)
                  ),
                  Padding(padding: EdgeInsets.all(2)),
                  Text(date, style: TextStyle(fontSize: 20),),
                  endOfHoursCard(editing, hours, index),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget endOfHoursCard(bool editing, String hours, int index) {
    if(double.parse(hours) == 0) {
      return Icon(Icons.check, color: Colors.green, size: 25,);
    }
    else if(editing == true) {
      return SizedBox(
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
      );
    }
    else {
      return Text(
        "+" + hours,
        style: TextStyle(color: Colors.green, fontSize: 20),
      );
    }
  }
