import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickles_nhs_app/adminSide/scanning_page.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/scannedData.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';

class ViewSavedScanningSessions extends StatefulWidget {

  ViewSavedScanningSessions({this.uid});

  final String uid;

  @override
  _ViewSavedScanningSessionsState createState() => _ViewSavedScanningSessionsState();
}

class _ViewSavedScanningSessionsState extends State<ViewSavedScanningSessions> {
  List theList = new List();
  SharedPreferences sharedPreferences;

  Future getSavedEvents() async {
    sharedPreferences = await SharedPreferences.getInstance();
    theList = sharedPreferences.getStringList('scannedData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: FutureBuilder(
          future: getSavedEvents(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            else {
              return Column(
                children: <Widget>[
                  TopHalfViewStudentsPage(),
                  Padding(
                    padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        child: theList == null || theList.length == 0 ? Text("NO SAVED SCANNING SESSIONS", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 40), textAlign: TextAlign.center,) : 
                        Container(
                          height: SizeConfig.blockSizeVertical * 70,
                          child: ListView.builder(
                            itemCount: theList.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (_, index) {
                              return savedScanningSessionCards(theList[index], context, index);
                            }
                          ),
                        )
                      ),
                    ),
                  )
                ],
              );
            }
          }
        ),
      ),
    );
  }

  Widget savedScanningSessionCards(String data, BuildContext context, int index) {

    List<String> qrCodeItems = new List<String>(); 
    List theScanUID = new List();
    List theScanName = new List();
    List theScanDate = new List();
    List theScanTime = new List();
    List theScanTitle = new List();
    List theScanType = new List();
    List theScanEvent = new List();

    for(int i = 0; i < data.length; i++) {
      if(data.substring(0, i).contains("/")) {
        qrCodeItems.add(data.substring(0, i - 1));
        data = data.substring(i);
        i = 0;
      }
      else if(i == data.length - 1) {
        qrCodeItems.add(data);
      }
    }

    String date = qrCodeItems[2];
    String name = qrCodeItems[3];

    for(int i = 0; i < qrCodeItems.length; i++) {
      theScanUID.add(qrCodeItems[i + 1]);
      theScanName.add(qrCodeItems[i]); 
      theScanDate.add(qrCodeItems[i + 2]);
      theScanTime.add(qrCodeItems[i + 5]);
      theScanTitle.add(qrCodeItems[i + 3]);
      theScanType.add(qrCodeItems[i + 4]);
      theScanEvent.add(qrCodeItems[i + 6]);
      qrCodeItems.removeRange(0, 6);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Card(
        elevation: 10,
        child: ListTile(
          title: Text(name + " " + date, textAlign: TextAlign.center,),
          trailing: SizedBox(
            width: SizeConfig.blockSizeHorizontal * 47,
            child: Row(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScanningPage(widget.uid, theScanDate: theScanDate, theScanEvent: theScanEvent, theScanName: theScanName, theScanTime: theScanTime, theScanTitle: theScanTitle, theScanType: theScanType, theScanUID: theScanUID)));
                  }, 
                  child: Text("Edit", style: TextStyle(color: Colors.green))
                ),
                Builder(
                  builder: (context) {
                    return FlatButton(
                      onPressed: () async {
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text("Submitting..."),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                        ));
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
                          theList.removeAt(index);
                          sharedPreferences.setStringList('scannedData', theList);
                        });
                      }, 
                      child: Text("Submit", style: TextStyle(color: Colors.green))
                    );
                  }
                )
              ],
            ),
          )
        )
      ),
    );
  }
}