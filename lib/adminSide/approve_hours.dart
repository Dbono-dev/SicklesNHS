import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sickles_nhs_app/backend/push_notification.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:sickles_nhs_app/backend/currentQuarter.dart';

class ApproveHoursPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Stack(
          children: <Widget> [
            TopHalfViewStudentsPage(),
            Padding(
              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 18),
              child: Container(
                width: SizeConfig.blockSizeHorizontal * 100,
                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
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
                child: ApproveHoursMiddlePage()
              ),
            )
          ]
        ),
      ),
    );
  }
}

class ApproveHoursMiddlePage extends StatefulWidget {

  @override
  _ApproveHoursMiddlePageState createState() => _ApproveHoursMiddlePageState();
}

class _ApproveHoursMiddlePageState extends State<ApproveHoursMiddlePage> {
  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("Approving Hours").getDocuments();
    return qn.documents;
  }

  Future getMembers() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").getDocuments();
    return qn.documents;
  }
  
  List pastTitles = new List();
  List pastDates = new List();
  List pastHours = new List();
  String currentHours;
  double quarterHours;
  int x = 0;

  @override
  Widget build(BuildContext context) {
      return Container(
        height: SizeConfig.blockSizeVertical * 78,
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
            else if(snapshot.data.length == 0) {
              return Material(
                color: Colors.transparent,
                  child: Center(
                    child: Text("NO HOURS TO APPROVE", 
                    textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: SizeConfig.blockSizeHorizontal * 11,
                      ),
                    ),
                ),
              );
            }
            else {
              return Container(
                child: FutureBuilder(
                  future: getMembers(),
                  builder: (_, notTheSnapshot) {
                    if(notTheSnapshot.hasData) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: snapshot.data.length,
                        itemBuilder: (_, index) {
                          if(snapshot.data[index].data['complete'] == false && snapshot.data[index].data['save_submit'] == "submit") {
                            return Container(
                                margin: EdgeInsets.fromLTRB(0, SizeConfig.blockSizeVertical * 2.19, 0, 0),
                                child: Card(
                                  elevation: 8,
                                  margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 2, 0, SizeConfig.blockSizeHorizontal * 2, 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: ExpansionTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Material(
                                          color: Colors.transparent,
                                          child: Column(
                                            children: <Widget>[
                                              snapshot.data[index].data['date'] != null ? Text(snapshot.data[index].data['date'], style: TextStyle(fontSize: 12)) : Container(),
                                              Text(snapshot.data[index].data['hours'] + " hours", style: TextStyle(fontSize: 12))
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        IconButton(
                                          icon: Icon(Icons.check),
                                          color: Colors.green,
                                          onPressed: () async {
                                            DateFormat _format = new DateFormat("MM/dd/yyyy");
                                            String quarter = await CurrentQuarter(_format.parse(snapshot.data[index].data['date'])).getQuarter();

                                            for(int i = 0; i < notTheSnapshot.data.length; i++) {
                                                if(snapshot.data[index].data['uid'] == notTheSnapshot.data[i].data['uid']) {
                                                  if(notTheSnapshot.data[i].data['event title'] != null) {
                                                    pastTitles = notTheSnapshot.data[i].data['event title'];
                                                    pastDates = notTheSnapshot.data[i].data['event date'];
                                                    pastHours = notTheSnapshot.data[i].data['event hours'];
                                                  }
                                                  currentHours = notTheSnapshot.data[i].data['hours'].toString();
                                                  quarterHours = double.parse(notTheSnapshot.data[i].data[quarter].toString());
                                                }
                                              }
                                              
                                              pastTitles.add(snapshot.data[index].data['type']);
                                              pastDates.add(snapshot.data[index].data['date']);
                                              pastHours.add(snapshot.data[index].data['hours']);

                                            sendHoursRequestUpdate(double.parse(snapshot.data[index].data['hours']), snapshot.data[index].data['uid'].toString(), double.parse(currentHours));

                                            setState(() {
                                              sendEventToDatabase(pastTitles, pastDates, pastHours, snapshot.data[index].data['uid'].toString());
                                              sendHoursQuarterUpdate(snapshot.data[index].data['uid'].toString(), double.parse(snapshot.data[index].data['hours']), quarterHours, quarter);
                                              sendMessage("Hour Approval Update", "Your hours have been approved", context, snapshot.data[index].data['name']);
                                              sendUpdateComplete(snapshot.data[index].data['type'], snapshot.data[index].data['uid'].toString());
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.block),
                                          color: Colors.red,
                                          onPressed: () {
                                            setState(() {
                                              sendMessage("Hour Approval Update", "Your hours have been declined", context, snapshot.data[index].data['name']);
                                              sendUpdateDecline(snapshot.data[index].data['type'], snapshot.data[index].data['uid'].toString());
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                    leading: Text(snapshot.data[index].data['name'], style: TextStyle(fontSize: 12)),
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Text(snapshot.data[index].data['type'], textAlign: TextAlign.center,),
                                          Text("Location: " + snapshot.data[index].data['location'], textAlign: TextAlign.center,),
                                          Text("Name of Supervisor: " + snapshot.data[index].data['name of supervisor']),
                                          Text("Supervisor Email: " + snapshot.data[index].data['supervisor email']),
                                          Text("Supervisor Phone Number: " + snapshot.data[index].data['supervisor phone number']),
                                          Center(
                                            child: FadeInImage.memoryNetwork(
                                              placeholder: kTransparentImage,
                                              image: snapshot.data[index].data['url'].toString()
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                            else {
                              x++;
                              if(x == snapshot.data.length) {
                                return Material(
                                  color: Colors.white,
                                  child: Center(
                                    child: Text("NO HOURS TO APPROVE", 
                                    textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: SizeConfig.blockSizeHorizontal * 11,
                                      ),
                                    ),
                                ),
                              );
                            }
                            else {
                              return Container();
                            }
                          }
                        }
                      );
                    }
                    else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              );
            } 
          },
      ),
    );
  }
  
  Future sendEventToDatabase(List title, List date, List hours, String uid,) async {
    await DatabaseService(uid: uid).updateCompetedEvents(title, date, hours);
  }

  Future sendHoursRequestUpdate(double hours, String uid, double currentHours) async {
    await DatabaseService(uid: uid).updateHoursRequest(hours, currentHours);
  }

  Future sendUpdateComplete(String type, String uid) async {
    await DatabaseSubmitHours().updateCompleteness(type, true, uid);
  }

  Future sendUpdateDecline(String type, String uid) async {
    await DatabaseSubmitHours().updateCompleteness(type, false, uid);
  }

  Future sendHoursQuarterUpdate(String uid, double hours, double currentHours, String quarter) async {
    await DatabaseService(uid: uid).updateHoursByQuarter(hours, currentHours, quarter);
  }
  
  Future sendMessage(String title, String body, BuildContext context, toWho) async {
    await PushNotificationService().sendAndRetrieveMessage(title, body, context, toWho);
  }
}