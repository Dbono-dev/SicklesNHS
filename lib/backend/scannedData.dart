import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sickles_nhs_app/backend/currentQuarter.dart';
import 'package:sickles_nhs_app/backend/database.dart';

class ScannedData {
  
  ScannedData({this.text, this.date});

  String text;
  final String date;
  String title;
  String name;
  String time;
  String type;
  String uid;
  String event;
  BuildContext context;
  String oldDate;
  List participates = new List();
  String theText = "";

  Future<List> resisterScanData() async {
    List<String> qrCodeItems = new List<String>(); 

    /*for(int i = 0; i < text.length; i++) {
      var char = text[i];
      int temp = char.codeUnitAt(0) - 5;
      String theTemp = String.fromCharCode(temp);
      theText += theTemp;
    }*/

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


    return qrCodeItems;
  }

  Future submitHours() async {  
    List<String> qrCodeItems = new List<String>(); 

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
      uid = qrCodeItems[4];
      oldDate = qrCodeItems[5];
      event = qrCodeItems[6];

      List titles = new List();
      List dates = new List();
      List hours = new List();

      double currentHours;
      double currentQuarterHours;
      int numClub;
      int numCommunity;

      DateFormat _format = new DateFormat("MM/dd/yyyy");
      String quarter = await CurrentQuarter(_format.parse(date)).getQuarter();
      print("got passed the get Quarter function");

      QuerySnapshot result2 = await Firestore.instance.collection("members").getDocuments();
        var snapshot2 = result2.documents;
        for (int i = 0; i < snapshot2.length; i++) {
          var a = snapshot2[i];
          if(a.data['uid'] == uid) {
            titles = a.data['event title'];
            dates = a.data['event date'];
            hours = a.data['event hours'];
            currentHours = a.data['hours'];
            currentQuarterHours = a.data[quarter];
            numClub = a.data['numClub'];
            numCommunity = a.data['num of community service events'];
          }
        }

      print(type);

      if(type == "Check In") {
        print("got here");
        if(title == "Club Meeting") {
          QuerySnapshot result = await Firestore.instance.collection("Important Dates").getDocuments();
          List<DocumentSnapshot> snapshot = result.documents;
          for (int i = 0; i < snapshot.length; i++) {
            var a = snapshot[i];
            if(a.data['type'] == "clubDates" && oldDate == a.data['date']) {
              participates = a.data['participates'];
            }
          }
          participates.add(uid);
          await DatabaseImportantDates().addParticipates(participates, "clubDates", oldDate);
          await DatabaseService(uid: uid).updateNumOfClub(numClub + 1);
        }
        else if(event == "Community Service Project") {
          titles.add(title);
          dates.add(date);
          hours.add("0");
          await DatabaseService(uid: uid).updateCompetedEvents(titles, dates, hours);
          await DatabaseService(uid: uid).updateCommunityServiceEvents(numCommunity + 1);
        }
        else {
          print("got here");
          await DatabaseQRCodeHours().submitPreHours(name, title, time, type, uid);
        }
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

        int startTimeHour = int.parse(oldTime.toString().substring(0, 2));
        int startTimeMinutes = int.parse(oldTime.toString().substring(3));
        double modifiedStartTimeMinutes;

        int endTimeHour = int.parse(time.toString().substring(0, 2));
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

        titles.add(title);
        dates.add(date);
        hours.add(differenceTime.toString());

        await DatabaseService(uid: uid).updateHoursByQuarter(differenceTime, currentQuarterHours, quarter);
        await DatabaseService(uid: uid).updateHoursRequest(differenceTime, currentHours);
        await DatabaseService(uid: uid).updateCompetedEvents(titles, dates, hours);
        await DatabaseQRCodeHours().deleteDoc(name, title);
      }
  }
}