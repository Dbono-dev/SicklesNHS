import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'dart:io';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sickles_nhs_app/backend/message.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'package:sickles_nhs_app/memberSide/PDFScreen.dart';

class MessagesPage extends StatefulWidget {

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  Future getNewsLetters() async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("newsletter").getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          TopHalfViewStudentsPage(),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Most Recent Newsletters"),
                    content: FutureBuilder(
                      future: getNewsLetters(),
                      builder: (_, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.green),
                            ),
                          );
                        }
                        else {
                          String pathPDF = "";
                          String pdfUrl = "";

                          return Container(
                            height: SizeConfig.blockSizeVertical * 59,
                            width: SizeConfig.safeBlockHorizontal * 75,
                            child: ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (_, index) {
                                DateTime dateTime = DateTime.tryParse(snapshot.data[index].data['dateTime']);
                                return GestureDetector(
                                  onTap: () async {
                                    await LaunchFile.loadFromFirebase(context, snapshot.data[index].data['dateTime']).then((url) => LaunchFile.createFileFromPdfUrl(url, snapshot.data[index].data['dateTime']).then((f) => setState(() {
                                    if(f is File) {
                                      pathPDF = f.path;
                                    } else if(url is Uri) {
                                      pdfUrl = url.toString();
                                    }
                                  })));
                                  setState(() {
                                    LaunchFile.launchPDF(context, dateTime.month.toString() + "/" + dateTime.day.toString() + "/" + dateTime.year.toString() + " Newsletter", pathPDF, pdfUrl);
                                  });
                                  },
                                  child: Container(
                                    width: SizeConfig.safeBlockHorizontal * 75,
                                    child: Card(
                                      elevation: 10,
                                      child: ListTile(
                                        title: Text(dateTime.month.toString() + "/" + dateTime.day.toString() + "/" + dateTime.year.toString()),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("DONE", style: TextStyle(color: Colors.green))
                      )
                    ],
                  );
                }
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
              child: Card(
                elevation: 10,
                child: ListTile(
                  leading: Icon(Icons.assignment),
                  title: Text("View Newsletters"),
                ),
              ),
            ),
          ),
          Expanded(child: MessagesMiddlePage())
        ],
      ),
    );
  }
}

class MessagesMiddlePage extends StatefulWidget {
  @override
  _MessagesMiddlePageState createState() => _MessagesMiddlePageState();
}

class _MessagesMiddlePageState extends State<MessagesMiddlePage> {
  //final FirebaseMessaging _fcm = FirebaseMessaging();

  final List<Message> messages = [];

  @override
  void initState() {
    if(Platform.isIOS) {
      //_fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    /*_fcm.getToken();

    _fcm.subscribeToTopic('all');

    super.initState();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        final notification = message['notification'];
        setState(() {
          messages.add(Message(title: notification['title'], body: notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        final notification = message['notification'];
        setState(() {
          messages.add(Message(title: notification['title'], body: notification['body']));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        final notification = message['notification'];
        setState(() {
          messages.add(Message(title: notification['title'], body: notification['body']));
        });
      }
    );*/
  }

  Future getMessages() async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("messages").getDocuments();
    return qn.documents;
  }

  StorageReference firebaseStorageRef;
  File theFiles;
  String theFilePath = "";

  Future<File> getImage() async {
    theFiles = await FilePicker.getFile();
    return theFiles;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
 
    return Container(
      child: StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            UserData userData = snapshot.data;
            return FutureBuilder(
              future: getMessages(),
              builder: (_, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.green),
                    ),
                  );
                }
                else {
                  return Container(
                    height: SizeConfig.blockSizeVertical * 60,
                    child: Column(
                      children: <Widget>[
                        userData.permissions == 0 || userData.permissions == 2 ? Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Upload Document"),
                                    content: StatefulBuilder(
                                      builder: (context, setState) {
                                        return Container(
                                          height: SizeConfig.blockSizeVertical * 35,
                                          child: Column(
                                            children: <Widget>[
                                              OutlineButton(
                                                hoverColor: Theme.of(context).primaryColor,
                                                highlightColor: Theme.of(context).primaryColor,
                                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
                                                borderSide: BorderSide(color: Theme.of(context).primaryColor, style: BorderStyle.solid, width: 3),
                                                child: Text("Select Document"),
                                                onPressed: () async {
                                                  File theFile = await getImage();
                                                  setState(() {
                                                    theFilePath = theFile.path;
                                                  });
                                                },
                                              ),
                                              Center(child: Text(theFilePath))
                                            ],
                                          ),
                                        );
                                      }
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text("CANCEL")
                                      ),
                                      FlatButton(
                                        onPressed: () async {
                                          String dateTime = DateTime.now().toString();
                                          firebaseStorageRef = FirebaseStorage.instance.ref().child(dateTime + '.pdf');
                                          final StorageUploadTask task = firebaseStorageRef.putFile(theFiles);

                                          var url = await (await task.onComplete).ref.getDownloadURL();

                                          await NewsLetterData().addURL(dateTime, url.toString());

                                          theFilePath = "";
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("SUBMIT")
                                      )
                                    ],
                                  );
                                }
                              );
                            },
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                leading: Icon(Icons.file_upload),
                                title: Text("Upload a Newsletter"),
                              ),
                            ),
                          ),
                        ) : Container(),
                        Container(
                          height: SizeConfig.blockSizeVertical * 57,
                          child: ListView.builder(
                            padding: EdgeInsets.all(0),
                            itemCount: snapshot.data.length,
                            itemBuilder: (_, index) {
                              if(snapshot.data[index].data['toWho'] == "all") {
                                return messageCards(snapshot.data[index].data['title'], snapshot.data[index].data['message'], snapshot.data[index].data['dateTime']);
                              }
                              else if(snapshot.data[index].data['toWho'] == "Members" && userData.permissions == 1) {
                                return messageCards(snapshot.data[index].data['title'], snapshot.data[index].data['message'], snapshot.data[index].data['dateTime']);
                              }
                              else if(snapshot.data[index].data['toWho'] == "Officers" && userData.permissions == 2) {
                                return messageCards(snapshot.data[index].data['title'], snapshot.data[index].data['message'], snapshot.data[index].data['dateTime']);
                              }
                              else if(snapshot.data[index].data['toWho'] == "Sponsors" && userData.permissions == 0) {
                                return messageCards(snapshot.data[index].data['title'], snapshot.data[index].data['message'], snapshot.data[index].data['dateTime']);
                              }
                              else if(snapshot.data[index].data['toWho'] == "Dylan" && userData.firstName == "Dylan" && userData.lastName == "Bono") {
                                return messageCards(snapshot.data[index].data['title'], snapshot.data[index].data['message'], snapshot.data[index].data['dateTime']);
                              }
                              else if(snapshot.data[index].data['toWho'] == userData.firstName + " " + userData.lastName) {
                                return messageCards(snapshot.data[index].data['title'], snapshot.data[index].data['message'], snapshot.data[index].data['dateTime']);
                              }
                              else {
                                List signedUpEvents = new List();
                                signedUpEvents = userData.eventTitleSignedUp;
                                for(int i = 0; i < signedUpEvents.length; i++) {
                                  if(snapshot.data[index].data['toWho'] == signedUpEvents[i]) {
                                    return messageCards(snapshot.data[index].data['title'], snapshot.data[index].data['message'], snapshot.data[index].data['dateTime']);
                                  }
                                  else {
                                    return Container();
                                  }
                                }
                                return Container();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
          else {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.green),
            );
          }
        }
      ),
    );
  }

  Widget messageCards(String title, String message, Timestamp dateTime) {
    int seconds = dateTime.seconds;
    DateTime thedateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Card(
        elevation: 10,
        child: ListTile(
          title: Column(
            children: <Widget>[
              Text(title, style: TextStyle(fontSize: 25),),
              Text(message, textAlign: TextAlign.center,)
            ],
          ),
          trailing: Text(thedateTime.month.toString() + "/" + thedateTime.day.toString() + "/" + thedateTime.year.toString() + " @ " + thedateTime.hour.toString() + ":" + thedateTime.minute.toString()),
        ),
      ),
    );
  }
}

class LaunchFile {
  static void launchPDF(BuildContext context, String title, String pdfPath, String pdfUrl) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PDFScreen(title, pdfPath, pdfUrl)));
  }

  static Future<dynamic> loadFromFirebase(BuildContext context, String url) async {
    return await FirebaseStorage.instance.ref().child(url + ".pdf").getDownloadURL();
  }

  static Future<dynamic> createFileFromPdfUrl(dynamic url, String date) async {
    final filename = '$date.pdf';
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
}