import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/auth_service.dart';
import 'package:sickles_nhs_app/backend/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'dart:io' show Platform;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    final FirebaseMessaging _fcm = FirebaseMessaging();

    @override
    void initState() {
      if(Platform.isIOS) {
        _fcm.requestNotificationPermissions(IosNotificationSettings());
      }

      _fcm.getToken();

      _fcm.subscribeToTopic('all');

      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('onMessage: $message');
          final notification = message['notification'];
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('onMessage: $message');
          final notification = message['notification'];
        },
        onBackgroundMessage: (Map<String, dynamic> message) async {
          if(message.containsKey('data')) {
            final dynamic data = message['data'];
          }
          if(message.containsKey('notification')) {
            final dynamic notification = message['notification'];
          }
        },
        onResume: (Map<String, dynamic> message) async {
          print('onMessage: $message');
          final notification = message['notification'];
        }
      );
    }
    
    return StreamProvider<User>.value(
      value: AuthService().user,
        child: MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.green,
            accentColor: Colors.green
          ),
          debugShowCheckedModeBanner: false,
          home: Wrapper(),
      ),
    ); 
  }
}