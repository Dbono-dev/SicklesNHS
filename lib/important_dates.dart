import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:sickles_nhs_app/view_students.dart';
import 'package:flutter/cupertino.dart';
import 'package:sickles_nhs_app/database.dart';

class ImportantDateMain extends StatefulWidget {
  @override
  _ImportantDateMainState createState() => _ImportantDateMainState();
}

class _ImportantDateMainState extends State<ImportantDateMain> {
  String _date;

    Future getPosts() async {
      var firestore = Firestore.instance;
      QuerySnapshot qn = await firestore.collection("Important Dates").getDocuments();
      return qn.documents;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(padding: EdgeInsets.all(10)),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [
                    Text("Set Club Dates", style: TextStyle(fontSize: 25),),
                    Padding(padding: EdgeInsets.all(5)),
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 35,
                      child: Card(
                        elevation: 8,
                        child: FlatButton(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget> [
                              Icon(
                                Icons.add_circle_outline,
                                size: 35,
                              ),
                              Text("Add", style: TextStyle(fontSize: 25),)
                            ]
                          ),
                          onPressed: () {
                            showModalBottomSheet(context: context, builder: (BuildContext builder) {
                              return ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                child: Container(
                                  height: MediaQuery.of(context).copyWith().size.height / 3,
                                  child: CupertinoDatePicker(
                                    initialDateTime: DateTime.now(),
                                    onDateTimeChanged: (DateTime newDate) {
                                      _date = newDate.toString().substring(5, 7) + "-" + newDate.toString().substring(8, 10) + "-" + newDate.toString().substring(0, 4);
                                      sendDateToDatabase("clubDates", _date);
                                    },
                                    mode: CupertinoDatePickerMode.date,
                                    maximumDate: new DateTime(2030, 12, 30)
                                  ),
                                ),
                              );
                            });
                          },
                        )
                      ),
                    )
                  ]
                ),
              Container(
                height: SizeConfig.blockSizeVertical * 27.5,
                child: FutureBuilder(
                  future: getPosts(),
                  builder: (_, snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      return Container(
                        width: SizeConfig.blockSizeHorizontal * 30,
                        child: Card(
                          elevation: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                snapshot.data[index].data['date'].toString(),
                                textAlign: TextAlign.center,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit
                                ),
                                onPressed: () {

                                }
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete
                                ),
                                onPressed: () {

                                }
                              )
                            ],
                          )
                        ),
                      );
                    }
                  );
                  },
                ),
              ),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text("Set End of Quarter", style: TextStyle(fontSize: 25),),
                Padding(padding: EdgeInsets.all(5)),
                Container(
                  width: SizeConfig.blockSizeHorizontal * 35,
                  child: Card(
                    elevation: 8,
                    child: FlatButton(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget> [
                          Icon(
                            Icons.add_circle_outline,
                            size: 35,
                          ),
                          Text("Add", style: TextStyle(fontSize: 25),)
                        ]
                      ),
                      onPressed: () {
                        showModalBottomSheet(context: context, builder: (BuildContext builder) {
                          return Container(
                            height: MediaQuery.of(context).copyWith().size.height / 3,
                            child: CupertinoDatePicker(
                              initialDateTime: DateTime.now(),
                              onDateTimeChanged: (DateTime newDate) {
                                _date = newDate.toString().substring(5, 7) + "/" + newDate.toString().substring(8, 10) + "/" + newDate.toString().substring(0, 4);
                              },
                              mode: CupertinoDatePickerMode.date,
                              maximumDate: new DateTime(2030, 12, 30)
                            ),
                          );
                        });
                      },
                    )
                  ),
                )
              ]
            ),
              ],
            ),
          )
        ]
      ),
    );
  }

  Future sendDateToDatabase(String type, String date) async {
    await DatabaseImportantDates().updateImportantDates(type, date);
  }
}