import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/home_page.dart';
import 'package:sickles_nhs_app/login_screen.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'dart:io' show Platform;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

class Wrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
        
    if(user == null) {
      return LoginScreen();
    }
    else {
      return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            final FirebaseMessaging _fcm = FirebaseMessaging();
            UserData userData = snapshot.data;
            if(Platform.isIOS) {
              _fcm.requestNotificationPermissions(IosNotificationSettings(
                  sound: true, badge: true, alert: true, provisional: false
              ));
            }
            _fcm.subscribeToTopic('all');
            print(userData.firstName + userData.lastName);
            _fcm.subscribeToTopic(userData.firstName + userData.lastName);
            for(int i = 0; i < userData.eventTitleSignedUp.length; i++) {
              String tempText = "";
              for(int a = 0; a < userData.eventTitleSignedUp[i].length; a++) {
                if(userData.eventTitleSignedUp[i].substring(a, a + 1) != " ") {
                  tempText += userData.eventTitleSignedUp[i].substring(a, a + 1);
                }
              }
              _fcm.subscribeToTopic(tempText);
            }
            if(userData.permissions == 1) {
              _fcm.subscribeToTopic('members');
            }
            if(userData.permissions == 2) {
              _fcm.subscribeToTopic('officers');
            }
            if(userData.permissions == 0) {
              _fcm.subscribeToTopic('sponsors');
            }

            _fcm.getToken();

            _fcm.configure(
              onMessage: (Map<String, dynamic> message) async {
                print('onMessage: $message');
                final notification = message['notification'];
              },
              onLaunch: (Map<String, dynamic> message) async {
                print('onMessage: $message');
                final notification = message['notification'];
              },
              onBackgroundMessage: myBackgroundMessageHandler,
              onResume: (Map<String, dynamic> message) async {
                print('onMessage: $message');
                final notification = message['notification'];
              }
            );
            return TheOpeningPage(userData: snapshot.data);
          }
          else {
            return Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: SizeConfig.blockSizeHorizontal * 100,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("SICKLES NHS", style: TextStyle(color: Colors.green, fontSize: 45)),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.green),
                      ),
                      Text("Please make sure your app is the most updated version!", style: TextStyle(color: Colors.green, fontSize: 25), textAlign: TextAlign.center)
                    ],
                  ),
                ),
              ),
            );
          }
        },
      );
    }
  }
}