import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'dart:io';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sickles_nhs_app/backend/message.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/user.dart';

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          TopHalfViewStudentsPage(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
            child: Card(
              elevation: 10,
              child: ListTile(
                leading: Icon(Icons.assignment),
                title: Text("View Newsletter"),
              ),
            ),
          ),
          Container(height: SizeConfig.blockSizeVertical * 65, child: MessagesMiddlePage())
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

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}