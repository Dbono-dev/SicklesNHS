import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sickles_nhs_app/adminSide/message.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          TopHalfViewStudentsPage(),
          Container(height: SizeConfig.blockSizeVertical * 80, child: MessagesMiddlePage())
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
  final FirebaseMessaging _fcm = FirebaseMessaging();

  final List<Message> messages = [];

  void initState() {
    if(Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.getToken();

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
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    children: messages.map(buildMessage).toList(),
  );

  Widget buildMessage(Message message) => ListTile(
    title: Text(message.title),
    subtitle: Text(message.body),
  );
}