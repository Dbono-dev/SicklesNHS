import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future initialise() async {
    if(Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        return AlertDialog(
          content: ListTile(
            title: Text(message['notification']['title']),
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      }
    );
  }

  // Replace with server token from firebase console settings.
final String serverToken = 'AAAA9shRjdo:APA91bHA80_mP4XBXY0dUXG87CdVKjcFX3fuCXft8CAVLq8v5HjT66slVysGB1-VNGaPv5sA4vYwBBNfjf1ncKHXZ6lhDhIvAgRKVD6LiKyqEtIt1KnpR5RlSlZWrbV0qUlOFRCYDCJy';
final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

Future<Map<String, dynamic>> sendAndRetrieveMessage(String title, String body) async {
  await firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
  );

  await http.post(
    'https://fcm.googleapis.com/fcm/send',
     headers: <String, String>{
       'Content-Type': 'application/json',
       'Authorization': 'key=$serverToken',
     },
     body: jsonEncode(
     <String, dynamic>{
       'notification': <String, dynamic>{
         'body': body,
         'title': title
       },
       'priority': 'high',
       'data': <String, dynamic>{
         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
         'id': '1',
         'status': 'done'
       },
       'to': await firebaseMessaging.getToken(),
     },
    ),
  );

  final Completer<Map<String, dynamic>> completer =
     Completer<Map<String, dynamic>>();

  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      completer.complete(message);
    },
  );

  return completer.future;
}
}