import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class ScanningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Spacer(),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget> [
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
              onPressed: () {
                //Navigator.push(context, 
                  //MaterialPageRoute(builder: (context) => QRCodeCamera()
                //));
                _scanBytes();
              },
            child: Text("Start Scanning", textAlign: TextAlign.center,
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

  Future _scanBytes() async {
    File file = await ImagePicker.pickImage(source: ImageSource.camera);
    Uint8List bytes = file.readAsBytesSync();
    String barcode = await scanner.scanBytes(bytes);
    print(barcode);
  }

/*class QRCodeCamera extends StatefulWidget {

  @override
  _QRCodeCameraState createState() => _QRCodeCameraState();
}

class _QRCodeCameraState extends State<QRCodeCamera> {
  GlobalKey qrKey = GlobalKey();

  var qrText = "";

  QRViewController controller;

    void _onQRViewCreate(QRViewController controller) {
      this.controller = controller;
      controller.scannedDataStream.listen((scanData) {
        setState(() {
          qrText = scanData;
        });
      });
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget> [
          Container(
            child: IconButton(
              alignment: Alignment.topLeft,
              icon: Icon(
                Icons.arrow_back,
                color: Colors.green,
              ),
              onPressed: () {
                Navigator.pop(context);
              }
            ),
          ),
          Expanded(
            flex: 5,
            child: Container()
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan result: $qrText'),
            )
          )
        ]
      )
    );
  }

    @override
    void dispose() {
      controller?.dispose();
      super.dispose();
    }
}
*/