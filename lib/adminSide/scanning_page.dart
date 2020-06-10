import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/scannedData.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';

class ScanningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2),),
          ScanningPageBody()
        ]
      ),
    );
  }
}

class ScanningPageBody extends StatefulWidget {
  @override
  _ScanningPageBodyState createState() => _ScanningPageBodyState();
}

class _ScanningPageBodyState extends State<ScanningPageBody> {

  String qrCodeResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical * 76,
      child: Column(
        children: <Widget> [
          Card(
            elevation: 10,
            child: ListTile(
              title: Text(qrCodeResult == null ? "" : qrCodeResult),
            )
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                elevation: 10,
                color: Colors.white,
                onPressed: () {

                },
                child: Text("Save"),
              ),
              RaisedButton(
                elevation: 10,
                color: Colors.white,
                onPressed: () {

                },
                child: Text("Submit"),
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
                print(result.rawContent);
                String name = await ScannedData(text: result.rawContent, date: "06/17/20").resisterScanData();
                setState(() {
                  qrCodeResult = name;
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