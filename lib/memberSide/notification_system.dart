import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/push_notification.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';

class Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
          children: <Widget> [
            TopHalfViewStudentsPage(),
            Padding(padding: EdgeInsets.all(20)),
            MiddlePageNotification(),
          ]
        )
    );
  }
}

class MiddlePageNotification extends StatefulWidget {
  @override
  _MiddlePageNotificationState createState() => _MiddlePageNotificationState();
}

  enum Options { all, specificEvent, specificPerson, specificGroup }

  enum SpecificGroup {members, officers, admin, justToDylan}

class _MiddlePageNotificationState extends State<MiddlePageNotification> {

  void intState() {
    //PushNotificationService().initialise();
  }

  final _fourthformKey = GlobalKey<FormState>();
  String _title;
  String _body;

  Options _character = Options.all;
  SpecificGroup _selection = SpecificGroup.members;

  @override
  Widget build(BuildContext context) {

    bool whosChecked = false;
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

    return Container(
      height: SizeConfig.blockSizeVertical * 74.1,
      child: Material(
        child: Form(
          key: _fourthformKey,
          child: Column(
            children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextFormField(
                    onSaved: (value) => _title = value,
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      hintText: "Body of Message"
                    ),
                    maxLines: 8,
                    minLines: 5,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                child: Column(
                  children: <Widget> [
                    ListTile(
                      title: const Text('All'),
                      leading: Radio(
                        value: Options.all,
                        activeColor: Colors.green,
                        groupValue: _character,
                        onChanged: (Options value) {
                          setState(() { _character = value; });
                        },
                      ),
                    ),
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
                                                          return ListTile(
                                                            title: Text(snapshot.data[index].data["title"].toString())
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
                                              FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("DONE")
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
                    Row(
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
                        PopupMenuButton<SpecificGroup>(
                          onSelected: (SpecificGroup result) { setState(() { _selection = result; }); },
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
                    ),
                    Row(
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
                                                                  return TheViewStudents(snapshot.data[index], context);
                                                                }
                                                                else {
                                                                  return Container();
                                                                }
                                                              }
                                                              else {
                                                                return TheViewStudents(snapshot.data[index], context);
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
                    ),
                  ]
                ),
              ),
              Spacer(),
              Material(
                type: MaterialType.transparency,
                child: Container(
                height: 49.0,
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
                    _fourthformKey.currentState.save();
                    print("works");
                    final response = await PushNotificationService().sendAndRetrieveMessage(
                      _title, _body
                    );
                    _fourthformKey.currentState.reset();
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
    );
  }

  Future sendMessage(String title, String body) async {
    await PushNotificationService().sendAndRetrieveMessage(title, body);
  }
}
