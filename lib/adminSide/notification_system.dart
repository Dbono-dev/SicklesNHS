import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/push_notification.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/globals.dart' as global;

class Notifications extends StatelessWidget {

  Notifications({this.officerSponsor});

  final String officerSponsor;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: SizeConfig.blockSizeVertical * 100,
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
                  child: MiddlePageNotification(officerSponsor)
                ),
              ),
            ]
          ),
      ),
    );
  }
}

  enum Options {all, specificEvent, specificPerson, specificGroup}

  enum SpecificGroup {members, officers, admin, justToDylan}

class MiddlePageNotification extends StatefulWidget {

  MiddlePageNotification(this.officerSponsor);

  final String officerSponsor;

  @override
  _MiddlePageNotificationState createState() => _MiddlePageNotificationState();
}

class _MiddlePageNotificationState extends State<MiddlePageNotification> {

  final _fourthformKey = GlobalKey<FormState>();
  String _title;
  String _body;

  Options _character = Options.all;
  SpecificGroup _selection = SpecificGroup.members;

  @override
  Widget build(BuildContext context) {
    String search = "";

    Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").getDocuments();
    return qn.documents;
  }

   Future getEvents() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("events").getDocuments();
    return qn.documents;
  }

    return SingleChildScrollView( 
      child: Container(
        height: SizeConfig.blockSizeVertical * 78,
        child: Scaffold(
          body: Form(
            key: _fourthformKey,
            child: ListView(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextFormField(
                      onSaved: (value) => _title = value,
                      validator: (val) => val.isEmpty ? 'Enter a Title' : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))
                        ),
                        hintText: "Title"
                      ),
                    ),
                  ),
                Padding(padding: EdgeInsets.all(0)),
                Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextFormField(
                      onSaved: (value) => _body = value,
                      validator: (val) => val.isEmpty ? 'Enter a Message' : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))
                        ),
                        hintText: "Body of Message"
                      ),
                      maxLines: 5,
                      minLines: 4,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                  child: Column(
                    children: <Widget> [
                      widget.officerSponsor == "sponsor" ? ListTile(
                        title: const Text('All'),
                        leading: Radio(
                          value: Options.all,
                          activeColor: Colors.green,
                          groupValue: _character,
                          onChanged: (Options value) {
                            setState(() { _character = value; });
                          },
                        ),
                      ) : Container(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: const Text('Specific Event'),
                              leading: Radio(
                                value: Options.specificEvent,
                                groupValue: _character,
                                activeColor: Colors.green,
                                onChanged: (Options value) {
                                  setState(() { _character = value; });
                                },
                              ),
                            ),
                          ),
                          Text(global.selectedEvent),
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: EdgeInsets.all(50),
                                    child: Container(
                                      child: Card(
                                        child: Column(
                                          children: <Widget> [
                                            Center(child: ListTile(title: Text("EVENTS"))),
                                            Expanded(
                                              child: FutureBuilder(
                                                future: getEvents(),
                                                builder: (_, snapshot) {
                                                if(snapshot.connectionState == ConnectionState.waiting) {
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.green)
                                                    )
                                                  );
                                                }
                                                else {
                                                  return Material(
                                                    child: Container(
                                                      height: SizeConfig.blockSizeVertical * 59,
                                                      child: ListView.builder(
                                                        itemCount: snapshot.data.length,
                                                        itemBuilder: (_, index) {
                                                          if(snapshot.data.length == 0) {
                                                            return Center(child: Text("No Events"),);
                                                          }
                                                          else {
                                                            return GestureDetector(
                                                              onTap: () { 
                                                                String tempText = "";
                                                                for(int a = 0; a < snapshot.data[index].data["title"].toString().length; a++) {
                                                                  if(snapshot.data[index].data["title"].toString().substring(a, a + 1) != " ") {
                                                                    tempText += snapshot.data[index].data["title"].toString().substring(a, a + 1);
                                                                  }
                                                                }
                                                                global.selectedEvent = tempText;
                                                                Navigator.of(context).pop();
                                                                setState(() {
                                                                  
                                                                });
                                                              },
                                                              child: ListTile(
                                                                title: Text(snapshot.data[index].data["title"].toString())
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      )
                                                    )
                                                  );
                                                }
                                                }),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("CANCEL")
                                                ),
                                                
                                              ],
                                            ),
                                          ]
                                        ),
                                      )
                                    ),
                                  );
                                }
                              );
                            }
                          )
                        ],
                      ),
                      widget.officerSponsor == "sponsor" ? Row(
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: const Text('Specific Group'),
                              leading: Radio(
                                value: Options.specificGroup,
                                groupValue: _character,
                                activeColor: Colors.green,
                                onChanged: (Options value) {
                                  setState(() { _character = value; });
                                },
                              ),
                            ),
                          ),
                          Text(global.selectedGroup),
                          PopupMenuButton<SpecificGroup>(
                            icon: Icon(Icons.more_vert),
                            onSelected: (SpecificGroup result) { 
                              setState(() {
                                  _selection = result;
                                  if(_selection == SpecificGroup.members) {
                                    global.selectedGroup = "Members";
                                  }
                                  if(_selection == SpecificGroup.officers) {
                                    global.selectedGroup = "Officers";
                                  }
                                  if(_selection == SpecificGroup.admin) {
                                    global.selectedGroup = "Sponsors";
                                  }
                                  if(_selection == SpecificGroup.justToDylan) {
                                    global.selectedGroup = "Dylan";
                                  }
                                });
                              },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<SpecificGroup>>[
                              const CheckedPopupMenuItem<SpecificGroup>(
                                value: SpecificGroup.members,
                                child: Text('Members'),
                              ),
                              const CheckedPopupMenuItem<SpecificGroup>(
                                value: SpecificGroup.officers,
                                child: Text('Officers'),
                              ),
                              const CheckedPopupMenuItem<SpecificGroup>(
                                value: SpecificGroup.admin,
                                child: Text('Sponsors'),
                              ),
                              const CheckedPopupMenuItem<SpecificGroup>(
                                value: SpecificGroup.justToDylan,
                                child: Text('Just to Dylan/Development Team'),
                              ),
                            ],
                          )
                        ],
                      ) : Container(),
                      widget.officerSponsor == "sponsor" ? Row(
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: const Text('Specific Person'),
                              leading: Radio(
                                value: Options.specificPerson,
                                groupValue: _character,
                                activeColor: Colors.green,
                                onChanged: (Options value) {
                                  setState(() { _character = value; });
                                },
                              ),
                            ),
                          ),
                          Text(global.selectedPerson),
                          Material(
                            child: IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Padding(
                                          padding: const EdgeInsets.all(50),
                                          child: Container(
                                            height: SizeConfig.blockSizeVertical * 70,
                                            width: SizeConfig.blockSizeHorizontal * 70,
                                            child: Card(
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    child: TextFormField(
                                                      initialValue: search,
                                                      decoration: InputDecoration(
                                                        hintText: "Search",
                                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.green)),
                                                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green), borderRadius: BorderRadius.circular(30)),
                                                        prefixIcon: Icon(Icons.search, color: Colors.green,),
                                                      ),
                                                      onChanged: (text) {
                                                        setState(() {
                                                          search = text;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: FutureBuilder(
                                                      future: getPosts(),
                                                      builder: (_, snapshot) {
                                                      if(snapshot.connectionState == ConnectionState.waiting) {
                                                        return Center(
                                                          child: CircularProgressIndicator(
                                                            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green)
                                                          )
                                                        );
                                                      }
                                                      else {
                                                        return Material(
                                                          child: Container(
                                                            height: SizeConfig.blockSizeVertical * 59,
                                                            child: ListView.builder(
                                                              itemCount: snapshot.data.length,
                                                              itemBuilder: (_, index) {
                                                                if(search != "") {
                                                                  if(snapshot.data[index].data['first name'].toString().contains(search) || snapshot.data[index].data['last name'].toString().contains(search) || (snapshot.data[index].data["first name"] + " " + snapshot.data[index].data["last name"]).toString().contains(search)) {
                                                                    return personCards(snapshot.data[index], context);
                                                                  }
                                                                  else {
                                                                    return Container();
                                                                  }
                                                                }
                                                                else {
                                                                  return personCards(snapshot.data[index], context);
                                                                }
                                                              }
                                                            )
                                                          )
                                                        );
                                                      }
                                                      }),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: <Widget>[
                                                      FlatButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Text("CANCEL")
                                                      ),
                                                      FlatButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Text("DONE")
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                );
                              }
                            ),
                          )
                        ],
                      ) : Container(),
                    ]
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: widget.officerSponsor == "officer" ? SizeConfig.blockSizeVertical * 31 : SizeConfig.blockSizeVertical * 6),),
                Material(
                  type: MaterialType.transparency,
                  child: Container(
                  height: SizeConfig.blockSizeVertical * 7,
                  width: SizeConfig.blockSizeHorizontal * 100,
                  decoration: BoxDecoration(
                    boxShadow: [BoxShadow(
                      color: Colors.black,
                      blurRadius: 25.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, -5.0)
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                    ),
                    color: Colors.green,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      var result = _fourthformKey.currentState;
                      result.save();
                      if(result.validate()) {
                        try {
                          String toWho = "";
                          if(_character == Options.all) {
                            toWho = "all";
                          }
                          if(_character == Options.specificEvent) {
                            toWho = global.selectedEvent;
                          }
                          if(_character == Options.specificGroup) {
                            toWho = global.selectedGroup;
                          }
                          if(_character == Options.specificPerson) {
                            toWho = global.selectedPerson;
                          }
                          var result = await MessageDatabase().addMessage(_title, _body, toWho);
                          final response = await PushNotificationService().sendAndRetrieveMessage(
                            _title, _body, context, toWho
                          );
                          setState(() {
                            _fourthformKey.currentState.reset();
                            _title = "";
                            _body = "";
                            global.selectedEvent = "";
                            global.selectedGroup = "";
                            global.selectedPerson = "";
                            _character = Options.all;
                          });   
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Submitted Notification"),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            )
                          );
                        }
                        catch (e) {
                          return CircularProgressIndicator();
                        } 
                      }
                    },
                  child: Center(
                    child: Text("Send", style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                    )),
                        ),
                      ),
                  ))
              ],
            )
          ),
        ),
          ),
    );
  }

  Future sendMessage(String title, String body, BuildContext context, String toWho) async {
    await PushNotificationService().sendAndRetrieveMessage(title, body, context, toWho);
  }

  Widget personCards(DocumentSnapshot snapshot, BuildContext context) {
    return GestureDetector(
      onTap: () {
        global.selectedPerson = snapshot.data["first name"] + " " + snapshot.data["last name"];
        Navigator.of(context).pop();
        setState(() {
          
        });
      },
      child: Container(
        width: SizeConfig.blockSizeHorizontal * 75,
          child: Card(
            color: Colors.white,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: Row(
                children: <Widget> [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(snapshot.data["first name"] + " " + snapshot.data["last name"], style: TextStyle(
                          color: Colors.green,
                          fontSize: 25
                        ),),
                        Text("Hours: " + snapshot.data["hours"].toString() + "\t Grade: " + snapshot.data["grade"], style: TextStyle(color: Colors.black),)
                    ],  
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward, size: 35,),
                ]
              ),
            )
        )
      ),
    );
  }
}
