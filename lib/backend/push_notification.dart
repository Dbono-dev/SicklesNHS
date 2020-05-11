import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';


class PushNotificationService {

static final Client client = Client();

final String serverToken = "AAAA9shRjdo:APA91bHA80_mP4XBXY0dUXG87CdVKjcFX3fuCXft8CAVLq8v5HjT66slVysGB1-VNGaPv5sA4vYwBBNfjf1ncKHXZ6lhDhIvAgRKVD6LiKyqEtIt1KnpR5RlSlZWrbV0qUlOFRCYDCJy";

final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

Future<Response> sendAndRetrieveMessage(String title, String body)  {
  firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
  );

   client.post(
    'https://fcm.googleapis.com/fcm/send',
     headers: <String, String>{
       'Content-Type': 'application/json',
       'Authorization': 'key=$serverToken',
     },
     body: json.encode({
       'notification': {'title': title, 'body': body},
       'priority': 'high',
       'data': {
         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
         'id': '1',
         'status': 'done'
       },
       'to': 'topics/all',
     },
    ),
  );
}
}