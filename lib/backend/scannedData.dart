import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/backend/currentQuarter.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/user.dart';

class ScannedData {
  
  ScannedData({this.text, this.date, this.context});

  String text;
  final String date;
  List<String> qrCodeItems = new List<String>();
  String title;
  String name;
  String time;
  String type;
  BuildContext context;

  void resisterScanData() async {
    for(int i = 0; i < text.length; i++) {
      if(text.substring(0, i).contains("/")) {
        qrCodeItems.add(text.substring(0, i - 1));
        text = text.substring(i);
        i = 0;
      }
      else if(i == text.length - 1) {
        qrCodeItems.add(text);
      }
    }

    title = qrCodeItems[0];
    name = qrCodeItems[1];
    time = qrCodeItems[2];
    type = qrCodeItems[3];

    if(type == "Check In") {
      await DatabaseQRCodeHours().submitPreHours(name, title, time, type);
    }
    else {
      String oldTime;
      QuerySnapshot result = await Firestore.instance.collection("DatabaseQRCodeHours").getDocuments();
      List<DocumentSnapshot> snapshot = result.documents;
      for (int i = 0; i < snapshot.length; i++) {
        var a = snapshot[i];
        if(a.data['name'] == name && a.data['title'] == title) {
          oldTime = a.data['time'];
        }
      }

      double differenceTime;

      double startTimeHour = double.parse(oldTime.toString().substring(0, 2));
      int startTimeMinutes = int.parse(oldTime.toString().substring(3));
      double modifiedStartTimeMinutes;

      double endTimeHour = double.parse(oldTime.toString().substring(0, 2));
      int endTimeMinutes = int.parse(time.toString().substring(3));
      double modifiedEndTimeMinutes;

      if(startTimeMinutes == 0) {
        modifiedStartTimeMinutes = 0.0;
      }
      if(startTimeMinutes == 15) {
        modifiedStartTimeMinutes = 0.25;
      }
      if(startTimeMinutes == 30) {
        modifiedStartTimeMinutes = 0.5;
      }
      if(startTimeMinutes == 45) {
        modifiedStartTimeMinutes = 0.75;
      }

      if(endTimeMinutes == 0) {
        modifiedEndTimeMinutes = 0.0;
      }
      if(endTimeMinutes == 15) {
        modifiedEndTimeMinutes = 0.25;
      }
      if(endTimeMinutes == 30) {
        modifiedEndTimeMinutes = 0.5;
      }
      if(endTimeMinutes == 45) {
        modifiedEndTimeMinutes = 0.75;
      }
      
      double modifiedEndTime = endTimeHour + modifiedEndTimeMinutes;
      double modifiedStartTime = startTimeHour + modifiedStartTimeMinutes;

      differenceTime = modifiedEndTime - modifiedStartTime;

      final user = Provider.of<User>(context);
      String uid = user.uid;

      List titles = new List();
      List dates = new List();
      List hours = new List();

      int currentHours;
      int currentQuarterHours;

      DateFormat _format = new DateFormat("MM/dd/yyyy");
      String quarter = await CurrentQuarter(_format.parse(date)).getQuarter();

      QuerySnapshot result2 = await Firestore.instance.collection("DatabaseQRCodeHours").getDocuments();
      List<DocumentSnapshot> snapshot2 = result2.documents;
      for (int i = 0; i < snapshot2.length; i++) {
        var a = snapshot2[i];
        if(a.data['uid'] == uid) {
          titles = a.data['event title'];
          dates = a.data['event date'];
          hours = a.data['event hours'];
          currentHours = a.data['hours'];
          currentQuarterHours = a.data[quarter];
        }
      }

      titles.add(title);
      dates.add(date);
      hours.add(differenceTime.toString());

      await DatabaseService(uid: uid).updateHoursByQuarter(differenceTime.toInt(), currentQuarterHours, quarter);
      await DatabaseService(uid: uid).updateHoursRequest(differenceTime.toInt(), currentHours);
      await DatabaseService(uid: uid).updateCompetedEvents(titles, dates, hours);
      await DatabaseQRCodeHours().deleteDoc(name, title);
    }
  }
}