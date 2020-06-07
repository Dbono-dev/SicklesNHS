import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';

class QRCodePage extends StatelessWidget {
QRCodePage ({Key key, this.title, this.name, this.type, this.date}) : super (key: key);

final String title;
final String name;
final String date;
final String type;

Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      children: <Widget>[
        TopHalfViewStudentsPage(),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, SizeConfig.blockSizeVertical * 10),
        ),
        QRCodePageContent(title: title, name: name, type: type, date: date),
      ],
    ),
  );
}
}

class QRCodePageContent extends StatelessWidget {
QRCodePageContent ({Key key, this.title, this.name, this.type, this.date}) : super (key: key);

final String title;
final String name;
final String type;
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
        QrImage(
          data: title  + "/" + name + "/" + time + "/" + type,
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

class BottomQRPage extends StatelessWidget {
  BottomQRPage ({Key key}) : super (key: key);


  @override
  Widget build(BuildContext context) {
    return Material(
            type: MaterialType.transparency,
            child: Container(
            height: 50,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                color: Colors.black,
                blurRadius: 15.0,
                spreadRadius: 2.0,
                offset: Offset(0, 10.0)
                )
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30)
              ),
              color: Colors.green,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("Testing", style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                )),
              ],
            ),
          ),
    );
  }
}