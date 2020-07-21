import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PushNotificationService {

final String serverToken = "AAAA9shRjdo:APA91bHA80_mP4XBXY0dUXG87CdVKjcFX3fuCXft8CAVLq8v5HjT66slVysGB1-VNGaPv5sA4vYwBBNfjf1ncKHXZ6lhDhIvAgRKVD6LiKyqEtIt1KnpR5RlSlZWrbV0qUlOFRCYDCJy";

 Future<Map<String, dynamic>> sendAndRetrieveMessage(String title, String body, BuildContext context, String toWho) async {
  await http.post(
    'https://fcm.googleapis.com/fcm/send',
     headers: <String, String>{
       'Content-Type': 'application/json',
       'Authorization': 'key=$serverToken',
     },
     body: jsonEncode(
     <String, dynamic>{
       'notification': <String, dynamic>{
         'body': title,
         'title': body,
       },
       'priority': 'high',
       'data': <String, dynamic>{
         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
         'id': '1',
         'status': 'done'
       },
       'to': '/topics/$toWho',
     },
    ),
  );

  final Completer<Map<String, dynamic>> completer =
     Completer<Map<String, dynamic>>();

  return completer.future;
}
}