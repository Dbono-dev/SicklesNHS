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
  String _firstDate = "";
  String _secondDate = "";
  String _thirdDate = "";
  String _forthDate = "";

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
                              return SetClubDates("new", "clubDates", "", "");
                            });
                          },
                        )
                      ),
                    )
                  ]
                ),
              Container(
                height: SizeConfig.blockSizeVertical * 27.5,
                width: SizeConfig.blockSizeHorizontal * 75,
                child: FutureBuilder(
                  future: getPosts(),
                  builder: (_, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      );
                    }
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                     if(snapshot.data[index].data['type'].toString() == "clubDates") {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),                        
                        child: Card(
                          elevation: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  showModalBottomSheet(context: context, builder: (BuildContext builder) {
                                    return SetClubDates("edit", "clubDates", snapshot.data[index].data['date'].toString(), "");
                                  });
                                }
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete
                                ),
                                onPressed: () {
                                  setState(() {
                                    deleteDateToDatabase(snapshot.data[index].data['type'].toString(), snapshot.data[index].data['inital date'].toString());
                                  });
                                }
                              )
                            ],
                          )
                        ),
                      );
                    }
                    else {
                      return Container();
                    }
                    }
                  );
                  },
                ),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text("Set End of Quarter", style: TextStyle(fontSize: 25),),
                Padding(padding: EdgeInsets.all(5)),
                /*Container(
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
                          return SetClubDates("new", "endOfQuarter", "");
                        });
                      },
                    )
                  ),
                ),*/
              ]
            ),
            Container(
                height: SizeConfig.blockSizeVertical * 33,
                width: SizeConfig.blockSizeHorizontal * 75,
                child: FutureBuilder(
                  future: getPosts(),
                  builder: (_, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      );
                    }
                    else {
                      for(int i = 0; i < snapshot.data.length; i++) {
                        if(snapshot.data[i].data['type'] == "endOfQuarter") {
                          if(snapshot.data[i].data['quarter'] == "First") {
                            _firstDate = snapshot.data[i].data['date'];
                          }
                          else if(snapshot.data[i].data['quarter'] == "Second") {
                            _secondDate = snapshot.data[i].data['date'];
                          }
                          else if(snapshot.data[i].data['quarter'] == "Third") {
                            _thirdDate = snapshot.data[i].data['date'];
                          }
                          else if(snapshot.data[i].data['quarter'] == "Fourth") {
                            _forthDate = snapshot.data[i].data['date'];
                          }
                        }
                      }
                      return Column(
                        children: <Widget>[
                          _endOfQuarterCards("First", _firstDate),
                          _endOfQuarterCards("Second", _secondDate),
                          _endOfQuarterCards("Third", _thirdDate),
                          _endOfQuarterCards("Fourth", _forthDate)
                        ],
                      );



                      /*return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      if(snapshot.data[index].data['type'].toString() == "endOfQuarter") {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),                        
                        child: Card(
                          elevation: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                snapshot.data[index].data['date'].toString(),
                                textAlign: TextAlign.center,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(context: context, builder: (BuildContext builder) {
                                    return SetClubDates("edit", "endOfQuarter" ,snapshot.data[index].data['date'].toString());
                                  });
                                }
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                ),
                                onPressed: () {
                                  setState(() {
                                    deleteDateToDatabase(snapshot.data[index].data['type'].toString(), snapshot.data[index].data['inital date'].toString());
                                  });
                                }
                              )
                            ],
                          )
                        ),
                      );
                      }
                      else {
                        return Container();
                      }
                      }
                  );*/
                    }
                      },
                  ),
                ),
              ],
            ),
          )
        ]
      ),
    );
  }

  Future sendDateToDatabase(String type, String date) async {
    await DatabaseImportantDates().setImportantDates(type, date);
  }

  Future editDateToDatabase(String type, String oldDate, String newDate) async {
    await DatabaseImportantDates().updateImportantDates(type, oldDate, newDate);
  }

  Future deleteDateToDatabase(String type, String date) async {
    await DatabaseImportantDates().deleteImportantDates(type, date);
  }

  Future sendEndOfQuarterDateToDatabase(String type, String date, String quarter) async {
    await DatabaseImportantDates().setEndOfQuarter(type, date, quarter);
  }


  Widget SetClubDates(String editOrNew, String type, String oldDate, String quarter) {
    return Container(
      height: SizeConfig.blockSizeVertical * 41,
      child: Column(
        children: <Widget>[
          FlatButton(
            onPressed: () {
              setState(() {
                if(type == "clubDates" && editOrNew == "new") {
                  sendDateToDatabase("clubDates", _date);
                }
                else if(type == "endOfQuarter") {
                  setState(() {
                    sendEndOfQuarterDateToDatabase(type, _date, quarter);                    
                  });
                }
                else {
                  editDateToDatabase("clubDates", oldDate, _date);
                }
              });
            },
            child: Text("DONE", style: TextStyle(color: Colors.green), textAlign: TextAlign.right,),
          ),
          Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            child: CupertinoDatePicker(
              initialDateTime: DateTime.now(),
              onDateTimeChanged: (DateTime newDate) {
                _date = newDate.toString().substring(5, 7) + "-" + newDate.toString().substring(8, 10) + "-" + newDate.toString().substring(0, 4);
              },
              mode: CupertinoDatePickerMode.date,
              maximumDate: new DateTime(2030, 12, 30)
            ),
          ),
        ],
      ),
    );
  }

  Widget _endOfQuarterCards(String number, String date) {
    if(date == "") {
      date = "No Date";
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),                        
      child: Card(
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(number + " Quarter"),
            Text(
              date,
              textAlign: TextAlign.center,
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
              ),
              onPressed: () {
                showModalBottomSheet(context: context, builder: (BuildContext builder) {
                  return SetClubDates("", "endOfQuarter" , date, number);//snapshot.data['date'].toString());
                });
              }
            ),
          ],
        )
      ),
    );
  }

}