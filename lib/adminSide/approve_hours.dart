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
        child: Column(
          children: <Widget> [
            TopHalfViewStudentsPage(),
            Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2)),
            ApproveHoursMiddlePage()
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
  int quarterHours;
  int x = 0;

  @override
  Widget build(BuildContext context) {
      return Container(
        height: SizeConfig.blockSizeVertical * 76,
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
                                child: GestureDetector(
                                  onTap: () {
                                    
                                  },
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
                                                Text(snapshot.data[index].data['type'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12),),
                                                Text(snapshot.data[index].data['date'],),
                                                Text(snapshot.data[index].data['hours'] + " hours",)
                                              ],
                                            ),
                                          ),
                                          Spacer(),
                                          IconButton(
                                            icon: Icon(Icons.check),
                                            color: Colors.green,
                                            onPressed: () async {
                                              DateFormat _format = new DateFormat("MM/dd/yyyy");
                                              String name = "";
                                              String quarter = await CurrentQuarter(_format.parse(snapshot.data[index].data['date'])).getQuarter();

                                              for(int i = 0; i < notTheSnapshot.data.length; i++) {
                                                  if(snapshot.data[index].data['uid'] == notTheSnapshot.data[i].data['uid']) {
                                                    if(notTheSnapshot.data[i].data['event title'] != null) {
                                                      pastTitles = notTheSnapshot.data[i].data['event title'];
                                                      pastDates = notTheSnapshot.data[i].data['event date'];
                                                      pastHours = notTheSnapshot.data[i].data['event hours'];
                                                    }
                                                    currentHours = notTheSnapshot.data[i].data['hours'].toString();
                                                    quarterHours = notTheSnapshot.data[i].data[quarter];
                                                  }
                                                }
                                                
                                                pastTitles.add(snapshot.data[index].data['type']);
                                                pastDates.add(snapshot.data[index].data['date']);
                                                pastHours.add(snapshot.data[index].data['hours']);

                                              sendHoursRequestUpdate(int.parse(snapshot.data[index].data['hours']), snapshot.data[index].data['uid'].toString(), int.parse(currentHours));

                                              setState(() {
                                                sendEventToDatabase(pastTitles, pastDates, pastHours, snapshot.data[index].data['uid'].toString());
                                                sendHoursQuarterUpdate(snapshot.data[index].data['uid'].toString(), int.parse(snapshot.data[index].data['hours']), quarterHours, quarter);
                                                sendMessage("Hour Approval Update", "Your hours have been approved", context, snapshot.data[index].data['name']);
                                                sendUpdateComplete(snapshot.data[index].data['type']);
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.block),
                                            color: Colors.red,
                                            onPressed: () {
                                              setState(() {
                                                sendMessage("Hour Approval Update", "Your hours have been declined", context, snapshot.data[index].data['name']);
                                                sendUpdateDecline(snapshot.data[index].data['type']);
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                      leading: Text(snapshot.data[index].data['name'], style: TextStyle(fontSize: 10),),
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Text("Location: " + snapshot.data[index].data['location']),
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
                                  )
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

  Future sendHoursRequestUpdate(int hours, String uid, int currentHours) async {
    await DatabaseService(uid: uid).updateHoursRequest(hours, currentHours);
  }

  Future sendUpdateComplete(String type) async {
    await DatabaseSubmitHours().updateCompleteness(type, true);
  }

  Future sendUpdateDecline(String type) async {
    await DatabaseSubmitHours().updateCompleteness(type, false);
  }

  Future sendHoursQuarterUpdate(String uid, int hours, int currentHours, String quarter) async {
    await DatabaseService(uid: uid).updateHoursByQuarter(hours, currentHours, quarter);
  }
  
  Future sendMessage(String title, String body, BuildContext context, toWho) async {
    await PushNotificationService().sendAndRetrieveMessage(title, body, context, toWho);
  }
}