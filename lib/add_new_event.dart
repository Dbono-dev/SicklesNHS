import 'dart:io';
import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickles_nhs_app/database.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:sickles_nhs_app/view_students.dart';

  
  class AddNewEvent extends StatefulWidget {
    @override
    _AddNewEventState createState() => _AddNewEventState();
  }
  
  class _AddNewEventState extends State<AddNewEvent> {
    @override
    Widget build(BuildContext context) {
      return Stack (
        children: <Widget>[
          Container(
            height: SizeConfig.blockSizeVertical * 100,
            width: SizeConfig.blockSizeHorizontal * 100,
            color: Colors.white,
          ),
          Column(
            children: <Widget> [
              TopHalfViewStudentsPage(),
              Padding(padding: EdgeInsets.fromLTRB(0.0, 15, 0, 0)),
              MiddleNewEventPage(),
            ]
          )
        ],
      );
    }
  }

class Options {
  const Options(this.id, this.name);
  final String name;
  final int id;
}

class MiddleNewEventPage extends StatefulWidget {

  @override
  _MiddleNewEventPageState createState() => _MiddleNewEventPageState();
}

class _MiddleNewEventPageState extends State<MiddleNewEventPage> {
  String _title;

  String _description;
  int _startTime;
  int _startTimeMinutes;
  int _endTime;
  int _endTimeMinutes;
  String _address;
  String _date;
  String _max;
  String _type = "";
  String fileSelect = "No File Selected";
  File image;
  var _photoUrl;
  StorageReference firebaseStorageRef;
  var listOfDates = new List<DateTime> ();
  DateTime startDate = new DateTime.now();

  Future getImage(String eventTitle) async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      fileSelect = "File Selected";
    });

    firebaseStorageRef = FirebaseStorage.instance.ref().child(eventTitle + '.jpg');
    final StorageUploadTask task = firebaseStorageRef.putFile(tempImage);
  }

  DateTime newDateTime () {
    int theCurrentTime = DateTime.now().minute;
    DateTime theNewDateTime = DateTime.now();

    while(theCurrentTime % 15 != 0) {
      theCurrentTime += 1;
    }

    DateTime thenewDate = new DateTime(theNewDateTime.year, theNewDateTime.month, theNewDateTime.day, theNewDateTime.hour, theCurrentTime, theNewDateTime.second);
    return thenewDate;
  }

  bool communityServiceEventValue = false;
  bool serviceEventValue = false;

  @override
  Widget build(BuildContext context) {
    final _thirdformKey = GlobalKey<FormState>();
    Options selectedOption;
    String select = "Select";
    String theDate = "Date";

    List<Options> users = <Options> [
      Options(0, "Weekly"),
      Options(1, "Every Other Week"),
      Options(2, "Monthly"),
      Options(3, "Every Other Month")
    ];

    return Container(
      color: Colors.transparent,
      height: SizeConfig.blockSizeVertical * 77.8,
      child: Scaffold(
        body: Form(
          key: _thirdformKey,
          child: ListView(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget> [
                  Material(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Title',
                      ),
                        onChanged: (val) => _title = (val),
                        initialValue: _title,
                      ),
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
                  Material(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Description",
                          border: OutlineInputBorder()
                        ),
                        minLines: 3,
                        maxLines: 6,
                        onChanged: (val) => _description = (val),
                        initialValue: _description,
                      ),
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, 5, 0.0, 00)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget> [
                      OutlineButton(
                        hoverColor: Colors.green,
                        highlightColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
                        borderSide: BorderSide(color: Colors.green, style: BorderStyle.solid, width: 3),
                        child: Text(theDate),
                        onPressed: () async {
                          DateTime newDateTime = await showRoundedDatePicker(
                            context: context,
                            initialDate: startDate,
                            lastDate: DateTime(DateTime.now().year + 1),
                            borderRadius: 16,
                            theme: ThemeData(primarySwatch: Colors.green),
                            textActionButton: "Add More Dates",
                          );
                        },
                      ),
                      OutlineButton(
                        hoverColor: Colors.green,
                        highlightColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
                        borderSide: BorderSide(color: Colors.green, style: BorderStyle.solid, width: 3),
                    child: Text("Start Time"),
                    onPressed: () {
                      showModalBottomSheet(
                            context: context,
                            builder: (BuildContext builder) {
                              return Container(
                                  height: MediaQuery.of(context).copyWith().size.height / 3,
                                  child: CupertinoDatePicker(
                                    initialDateTime: newDateTime(),
                                    onDateTimeChanged: (DateTime newdate) {
                                      _startTime = newdate.hour;
                                      _startTimeMinutes = newdate.minute;
                                    },
                                    use24hFormat: false,
                                    maximumDate: new DateTime(2030, 12, 30),
                                    minimumYear: 2020,
                                    maximumYear: 2030,
                                    minuteInterval: 15,
                                    mode: CupertinoDatePickerMode.time,
                              ));
                            });
                    },
                  ),
                      OutlineButton(
                        color: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
                        borderSide: BorderSide(color: Colors.green, style: BorderStyle.solid, width: 3),
                        child: Text("End Time"),
                        onPressed: () {
                          showModalBottomSheet(
                                context: context,
                                builder: (BuildContext builder) {
                                  return Container(
                                      height: MediaQuery.of(context).copyWith().size.height / 3,
                                      child: CupertinoDatePicker(
                                        initialDateTime: newDateTime() ,
                                        onDateTimeChanged: (DateTime newdate) {
                                          _endTime = newdate.hour;
                                          _endTimeMinutes = newdate.minute;
                                        },
                                        use24hFormat: false,
                                        maximumDate: new DateTime(2030, 12, 30),
                                        minimumYear: 2020,
                                        maximumYear: 2030,
                                        minuteInterval: 15,
                                        mode: CupertinoDatePickerMode.time,
                                  ));
                                });
                        },
                      ),
                    ]
                  ),
                  Material(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text("If a repetetive event: "),
                        DropdownButton<Options>(
                          hint: Text(select),
                          value: selectedOption,
                          onChanged: (Options value) {
                            setState(() {
                              selectedOption = value;
                              select = value.toString();
                            });
                          },
                          items: users.map((Options user) {
                            return DropdownMenuItem<Options>(
                              value: user,
                              child: Text(user.name)
                            );
                          }
                          
                          ).toList(),
                          )
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, 5, 0.0, 0.0)),
                  Material(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Address/Location",
                          border: OutlineInputBorder()
                      ),
                        onChanged: (val) => _address = val,
                        initialValue: _address,
                      ),
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, 5, 0, 0)),
                  Material(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        onChanged: (val) => _max = val,
                        initialValue: _max,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Max Number Of Participants",
                          border: OutlineInputBorder()
                      ),                      
                      ),
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 2, 0.0, 0.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton(
                        backgroundColor: Colors.green,
                        elevation: 8,
                        onPressed: () {
                          getImage(_title);
                        },
                        child: Icon(
                          Icons.photo_library,
                          size: 25,
                        )
                      ),
                      Material(child: Text(fileSelect, style: TextStyle(fontSize: 20),))
                    ],
                  ),
                ]
              ),
              Material(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget> [
                    Checkbox(
                      value: serviceEventValue,
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      onChanged: (newValue) {
                        setState(() {
                          serviceEventValue = newValue;                        
                        });
                      }
                    ),
                    Text("Service Event"),
                    Checkbox(
                      value: communityServiceEventValue,
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      onChanged: (theNewValue) {
                        setState(() {
                          communityServiceEventValue = theNewValue;
                        });
                      }
                    ),
                    Text("Community Service Project")
                  ]
                ),
              ),
              Padding(padding: EdgeInsets.all(5),),
              Material(
                type: MaterialType.transparency,
                child: Container(
                height: SizeConfig.blockSizeVertical * 7,
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
                    Builder(
                      builder: (context) {
                        return FlatButton(
                          child: Text("Create Event", style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          )),
                          onPressed: () async {
                            print("clicked");
                            if(communityServiceEventValue == true) {
                              _type = "Community Service Project";
                            }
                            if(serviceEventValue == true) {
                              _type = "Service Event";
                            }
                            final form = _thirdformKey.currentState;
                            form.save();
                            if(form.validate()) {
                              try {
                                _photoUrl = await firebaseStorageRef.getDownloadURL();
                                _date = newDateTime.toString().substring(5, 7) + "/" + newDateTime.toString().substring(8, 10) + "/" + newDateTime.toString().substring(0, 4);
                                dynamic result = sendEventToDatabase(_title, _description, _startTime, _endTime, _date, _photoUrl, _max, _address, _type, _startTimeMinutes, _endTimeMinutes);
                                if(result == null) {
                                  print("Fill in all the forms.");
                                }
                                if(result != null) {
                                  setState(() {
                                    _thirdformKey.currentState.reset();
                                    _title = "";
                                    _description = "";
                                    _address = "";
                                    _max = "";
                                    communityServiceEventValue = false;
                                    serviceEventValue = false;
                                  });
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Event Created"),
                                      backgroundColor: Colors.green,
                                      elevation: 8,
                                      duration: Duration(seconds: 3),
                                    )
                                  );
                                }
                              }
                              catch (e) {
                                return CircularProgressIndicator();
                              }
                            } 
                            else {
                              return Container();
                            }}
                        );
                      },
                    ),
                  ],
                ),
              ),
              )
            ],
          )
        ),
      ),
    );
  }

  Future sendEventToDatabase(String title, String description, int startTime, int endTime, String date, var photoUrl, String maxParticipates, String address, String type, int startTimeMinutes, int endTimeMinutes) async {
  await DatabaseEvent().updateEvents(title, description, startTime, endTime, date, photoUrl, maxParticipates, address, type, startTimeMinutes, endTimeMinutes);
}
}