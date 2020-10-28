import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickles_nhs_app/backend/scannedData.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:flutter/services.dart';

class ScanningPage extends StatelessWidget {

  ScanningPage(this.uid, {this.theScanUID, this.theScanName, this.theScanDate, this.theScanTime, this.theScanTitle, this.theScanType, this.theScanEvent});

  final String uid;
  final List theScanUID;
  final List theScanName;
  final List theScanDate;
  final List theScanTime;
  final List theScanTitle;
  final List theScanType;
  final List theScanEvent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2),),
          ScanningPageBody(uid: uid, theScanDate: theScanDate, theScanEvent: theScanEvent, theScanName: theScanName, theScanTime: theScanTime, theScanTitle: theScanTitle, theScanType: theScanType, theScanUID: theScanUID,)
        ]
      ),
    );
  }
}

class ScanningPageBody extends StatefulWidget {

  ScanningPageBody({this.uid, this.theScanUID, this.theScanName, this.theScanDate, this.theScanTime, this.theScanTitle, this.theScanType, this.theScanEvent});

  final String uid;
  final List theScanUID;
  final List theScanName;
  final List theScanDate;
  final List theScanTime;
  final List theScanTitle;
  final List theScanType;
  final List theScanEvent;

  @override
  _ScanningPageBodyState createState() => _ScanningPageBodyState();
}

class _ScanningPageBodyState extends State<ScanningPageBody> {

  String qrCodeResult;
  List theScanUID = new List();
  List theScanName = new List();
  List theScanDate = new List();
  List theScanTime = new List();
  List theScanTitle = new List();
  List theScanType = new List();
  List theScanEvent = new List();

  @override
  Widget build(BuildContext context) {
    if(widget.theScanUID != null) {
      theScanUID = widget.theScanUID;
      theScanName = widget.theScanName;
      theScanDate = widget.theScanDate;
      theScanTime = widget.theScanTime;
      theScanTitle = widget.theScanTitle;
      theScanType = widget.theScanType;
      theScanEvent = widget.theScanEvent;
    }

    return Container(
      height: SizeConfig.blockSizeVertical * 76,
      child: Column(
        children: <Widget> [
          Container(
            height: SizeConfig.blockSizeVertical * 55, //Was Previosly at 55
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: theScanUID.length,
              itemBuilder: (_, index) {
                return Card(
                  elevation: 10,
                  child: ListTile(
                    title: Text(theScanName[index]),
                    trailing: Text(theScanDate[index] + " @ " + theScanTime[index]),
                  )
                );
              }
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Builder(
                builder: (context) {
                  return RaisedButton(
                    elevation: 10,
                    color: Colors.white,
                    onPressed: () async {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Saving..."),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        )
                      );
                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      List<String> largeStringList = new List<String>();
                      if(sharedPreferences.getStringList("scannedData") != null) {
                        largeStringList = sharedPreferences.getStringList("scannedData");
                      }

                      String stringList = "";
                      for(int i = 0; i < theScanName.length; i++) {
                        stringList += (theScanName[i]);
                        stringList += "/" + (theScanUID[i]);
                        stringList += "/" + (theScanDate[i]);
                        stringList += "/" + (theScanTitle[i]);
                        stringList += "/" + (theScanType[i]);
                        stringList += "/" + theScanTime[i];
                        stringList += "/" + (theScanEvent[i]) + "/";
                      }
                      largeStringList.add(stringList);
                      await sharedPreferences.setStringList("scannedData", largeStringList);
                      setState(() {
                        theScanType.clear();
                        theScanUID.clear();
                        theScanName.clear();
                        theScanDate.clear();
                        theScanTime.clear();
                        theScanTitle.clear();
                        theScanType.clear();
                        theScanEvent.clear();
                      });
                    },
                    child: Text("Save"),
                  );
                }
              ),
              Builder(
                builder: (context) {
                  return RaisedButton(
                    elevation: 10,
                    color: Colors.white,
                    onPressed: () async {
                      if(theScanName.isNotEmpty) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Submitting..."),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          )
                        );
                        for(int i = 0; i < theScanUID.length; i++) {
                          String text = "";
                          text += theScanTitle[i];
                          text += "/" + theScanName[i];
                          text += "/" + theScanTime[i];
                          text += "/" + theScanType[i];
                          text += "/" + theScanUID[i];
                          text += "/" + theScanDate[i];
                          text += "/" + theScanEvent[i];
                          await ScannedData(text: text, date: DateTime.now().month.toString() + "/" + DateTime.now().day.toString() + "/" + DateTime.now().year.toString()).submitHours();
                        }
                        setState(() {
                          theScanType.clear();
                          theScanUID.clear();
                          theScanName.clear();
                          theScanDate.clear();
                          theScanTime.clear();
                          theScanTitle.clear();
                          theScanType.clear();
                          theScanEvent.clear();
                        });
                      }
                    },
                    child: Text("Submit"),
                  );
                }
              )
            ],
          ),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.5),),
          Material(
            type: MaterialType.transparency,
            child: Container(
            height: 50,
            width: SizeConfig.blockSizeHorizontal * 100,
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
            child: FlatButton(
              onPressed: () async {
                var result = await BarcodeScanner.scan();
                HapticFeedback.vibrate();
                List theListOfData = await ScannedData(text: result.rawContent, date: DateTime.now().month.toString() + "-" + DateTime.now().day.toString() + "-" + DateTime.now().year.toString()).resisterScanData();
                setState(() {
                  theScanUID.add(theListOfData[4]);
                  theScanName.add(theListOfData[1]); 
                  theScanDate.add(theListOfData[5]);
                  theScanTime.add(theListOfData[2]);
                  theScanTitle.add(theListOfData[0]);
                  theScanType.add(theListOfData[3]);
                  theScanEvent.add(theListOfData[6]);
                });
              },
            child: Text("Scan", textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                )),
            ),
          ),
          )
        ]
      ),
    );
  }
}