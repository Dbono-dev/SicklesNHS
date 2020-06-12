import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'dart:convert';

class QRCodePage extends StatelessWidget {
QRCodePage ({Key key, this.title, this.name, this.type, this.uid, this.date}) : super (key: key);

final String title;
final String name;
final String type;
final String uid;
final String date;

Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      children: <Widget>[
        TopHalfViewStudentsPage(),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, SizeConfig.blockSizeVertical * 7),
        ),
        QRCodePageContent(title: title, name: name, type: type, uid: uid, date: date),
      ],
    ),
  );
}
}

class QRCodePageContent extends StatelessWidget {
QRCodePageContent ({Key key, this.title, this.name, this.type, this.uid, this.date}) : super (key: key);

final String title;
final String name;
final String type;
final String uid;
final String date;

Widget build(BuildContext context) {
  DateTime now = DateTime.now();
  String time = formatDate(now, [HH, ':', nn]);
  int updatedTime = int.parse(time.substring(0, 2));
  String minutes = time.substring(2, 5);
  String timeOfDay = " am";
  if(updatedTime > 12) {
    timeOfDay = " pm";
    updatedTime -= 12;
  }

  String theUpdatedTime = updatedTime.toString() + minutes;

  String theQrContent = title  + "/" + name + "/" + time + "/" + type + "/" + uid + "/" + date;
  String qrContent = "";

  List<int> theListOfInts = new List<int> ();

  for(int i = 0; i < theQrContent.length; i++) {
    var char = theQrContent[i];
    int temp = char.codeUnitAt(0) + 5;
    theListOfInts.add(temp);
    String theTemp = String.fromCharCode(temp);
    qrContent += theTemp;
  }


  return Container(
    height: SizeConfig.blockSizeVertical * 70,
    width: SizeConfig.blockSizeHorizontal * 100,
    child: Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.blockSizeHorizontal * 10,
          ),
          ),
          Text(date, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        QrImage(
          data: qrContent,
          version: QrVersions.auto,
          size: SizeConfig.blockSizeVertical * 45,
        ),
        Container(
          child: Column(
            children: <Widget>[
              Text(
                "Current Time",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              Text(
                theUpdatedTime + timeOfDay,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30
                  ),
                  ),
            ],
          ),
        )
      ],
    ),
  );
}
}