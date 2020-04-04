import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:sickles_nhs_app/view_students.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
                Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => QRCodeCamera()
                ));
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

class QRCodeCamera extends StatefulWidget {

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
            child: QRView(
              onQRViewCreated: _onQRViewCreate,
              overlay: QrScannerOverlayShape(
                borderRadius: 10,
                borderColor: Colors.green,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300
              ),
              key: qrKey,
            ),
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