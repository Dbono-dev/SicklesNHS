import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/push_notification.dart';
import 'package:sickles_nhs_app/view_students.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:sickles_nhs_app/database.dart';
import 'package:transparent_image/transparent_image.dart';

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

  int x = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical * 76,
      child: FutureBuilder(
        future: getPosts(),
        builder: (_, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
            );
          }
          else if(snapshot.data.length == 0) {
            return Material(
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
          else{
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, index) {
                if(snapshot.data[index].data['complete'] == true) {
                  x++;
                  if(x == snapshot.data.length - 1) {
                    return Material(
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
                }
                if(snapshot.data[index].data['complete'] == false) {
                  return Container(
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        
                      },
                      child: Card(
                        elevation: 8,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Material(
                                child: Column(
                                  children: <Widget>[
                                    Text(snapshot.data[index].data['type'],),
                                    Text(snapshot.data[index].data['date'],),
                                    Text(snapshot.data[index].data['hours'] + " hours",)
                                  ],
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.check),
                                color: Colors.green,
                                onPressed: () {
                                  setState(() {
                                    var list = new List<String>(3);
                                    list[0] = snapshot.data[index].data['type'];
                                    list[1] = snapshot.data[index].data['date'];
                                    list[2] = snapshot.data[index].data['hours'];
                                    sendEventToDatabase(list, snapshot.data[index].data['uid'].toString());
                                    sendHoursRequestUpdate(int.parse(list[2]), snapshot.data[index].data['uid'].toString());
                                    sendMessage("Hour Approval Update", "Your hours have been approved");
                                    sendDeleteHourRequest(snapshot.data[index].data['type']);
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.block),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    sendDeleteHourRequest(snapshot.data[index].data['type']);
                                    sendMessage("Hour Approval Update", "Your hours have been declined");
                                  });
                                },
                              )
                            ],
                          ),
                          leading: Text(snapshot.data[index].data['name']),
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
              }
            );
          } 
        },
      ),
    );
  }
  
  Future sendEventToDatabase(List<String> event, String uid) async {
    await DatabaseService(uid: uid).updateCompetedEvents(event);
  }

  Future sendHoursRequestUpdate(int hours, String uid) async {
    await DatabaseService(uid: uid).updateHoursRequest(hours);
  }

  Future sendDeleteHourRequest(String type) async {
    await DatabaseSubmitHours().deleteCompleteness(type);
  }
  
  Future sendMessage(String title, String body) async {
    await PushNotificationService().sendAndRetrieveMessage(title, body);
  }
}