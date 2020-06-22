import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';

  
  class AddNewEvent extends StatefulWidget {
    AddNewEvent({this.title, this.description, this.startTime, this.startTimeMinutes, this.endTime, this.endTimeMinutes, this.address, this.date, this.max, this.type, this.fileSelect});

    String title;
    String description;
    int startTime;
    int startTimeMinutes;
    int endTime;
    int endTimeMinutes;
    String address;
    String date;
    String max;
    String type;
    String fileSelect;

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
              Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 2, 0, 0)),
              MiddleNewEventPage(title: widget.title, description: widget.description, startTime: widget.startTime, startTimeMinutes: widget.startTimeMinutes, endTime: widget.endTime, endTimeMinutes: widget.endTimeMinutes, address: widget.address, date: widget.date, max: widget.max, type: widget.type,),
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

  MiddleNewEventPage({this.title, this.description, this.startTime, this.startTimeMinutes, this.endTime, this.endTimeMinutes, this.address, this.date, this.max, this.type, this.fileSelect});

  String title;
  String description;
  int startTime;
  int startTimeMinutes;
  int endTime;
  int endTimeMinutes;
  String address;
  String date;
  String max;
  String type;
  String fileSelect;
  

  @override
  _MiddleNewEventPageState createState() => _MiddleNewEventPageState();
}

class _MiddleNewEventPageState extends State<MiddleNewEventPage> {
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

  int selectedValue;
  int secondSelectedValue;
  String typeOfDate = "";
  String doesNotRepeat;
  String doesNotEnd = "Does Not End";
  DateTime onDate;  
  String theDate;
  DateTime _newDateTime;
  String theStartTime;
  String theEndTime;
  String _title;
  String _description;
  int _startTime;
  int _startTimeMinutes;
  int _endTime;
  int _endTimeMinutes;
  String _address;
  String _date;
  String _max;

  @override
  Widget build(BuildContext context) {
    final _thirdformKey = GlobalKey<FormState>();
    String _bottomText = "Create Event";

    String _type = widget.type;

    if(_type == "Community Service Project") {
      communityServiceEventValue = true;
    }
    else if(_type == "Service Event") {
      serviceEventValue = true;
    }
    else {
      
    }

    if(onDate != null) {
      doesNotEnd = "Until " + onDate.toString().substring(0, 10);
    }

    if(theStartTime == null) {
      theStartTime = "Start Time";
    }

    if(theEndTime == null) {
      theEndTime = "End Time";
    }

    if(secondSelectedValue == 0) {
      typeOfDate = "days";
    }
    if(secondSelectedValue == 1) {
      typeOfDate = "weeks";
    }
    if(secondSelectedValue == 2) {
      typeOfDate = "months";
    }
    if(secondSelectedValue == 3) {
      typeOfDate = "years";
    }

    if(onDate != null) {
      theDate = " until " + onDate.month.toString() + "/" + onDate.day.toString() + "/" + onDate.year.toString();
    }
    else {
      theDate = "";
    }

    if(selectedValue == null && secondSelectedValue == null) {
      doesNotRepeat = "Does Not Repeat";
    }
    else {
      doesNotRepeat = "Repeats every " + selectedValue.toString() + " " + typeOfDate + theDate;
    }

    if(widget.title != null) {
      _title = widget.title;
      _bottomText = "Save Event";
      _description = widget.description;
      _startTime = widget.startTime;
      _startTimeMinutes = widget.startTimeMinutes;
      _endTime = widget.endTime;
      _endTimeMinutes = widget.endTimeMinutes;
      _address = widget.address;
      _date = widget.date;
      _max = widget.max;
    }

    if(_startTime != null) {
      theStartTime = _startTime.toString() + ":" + _startTimeMinutes.toString();
    }

    if(_endTime != null) {
      theEndTime = _endTime.toString() + ":" + _endTimeMinutes.toString();
    }

    String startingDate;
    startingDate = _newDateTime == null ? "Date" : _newDateTime.month.toString() + "/" + _newDateTime.day.toString() + "/" + _newDateTime.year.toString();
    //startingDate = _date == null || _date.toString().length > 10 ? "Date" : _date;

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
                      padding: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 4.8, 0, SizeConfig.blockSizeHorizontal * 4.8, 0),
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
                  Padding(padding: EdgeInsets.fromLTRB(0, SizeConfig.blockSizeVertical * 0.73, 0, 0)),
                  Material(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 4.8, 0, SizeConfig.blockSizeHorizontal * 4.8, 0),
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
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 0.73, 0.0, 00)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget> [
                      OutlineButton(
                        hoverColor: Colors.green,
                        highlightColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
                        borderSide: BorderSide(color: Colors.green, style: BorderStyle.solid, width: 3),
                        child: Text(startingDate),
                        onPressed: () async {
                          _newDateTime = await showRoundedDatePicker(
                            context: context,
                            initialDate: startDate,
                            lastDate: DateTime(DateTime.now().year + 1),
                            borderRadius: 16,
                            theme: ThemeData(primarySwatch: Colors.green),
                          );
                          setState(() {
                            startingDate = _newDateTime.month.toString() + "/" + _newDateTime.day.toString() + "/" + _newDateTime.year.toString();
                          });
                        },
                      ),
                      OutlineButton(
                        hoverColor: Colors.green,
                        highlightColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
                        borderSide: BorderSide(color: Colors.green, style: BorderStyle.solid, width: 3),
                    child: Text(theStartTime),
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
                                  theStartTime = _startTime.toString() + ":" + _startTimeMinutes.toString();
                                  setState(() {
                                    
                                  });
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
                        child: Text(theEndTime),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext builder) {
                              return Container(
                                  height: MediaQuery.of(context).copyWith().size.height / 3,
                                  child: CupertinoDatePicker(
                                    initialDateTime: newDateTime(),
                                    onDateTimeChanged: (DateTime newdate) {
                                      _endTime = newdate.hour;
                                      _endTimeMinutes = newdate.minute;
                                      theEndTime = _endTime.toString() + ":" + _endTimeMinutes.toString();
                                      setState(() {
                                        
                                      });
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
                    child: RaisedButton(
                      color: Colors.white,
                      elevation: 8,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25))
                          ),
                          builder: (BuildContext builder) {
                                return Container(
                                  height: SizeConfig.blockSizeVertical * 33,
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: CupertinoPicker(
                                                backgroundColor: Colors.white,
                                                itemExtent: 28,
                                                onSelectedItemChanged: (value) {
                                                  setState(() {
                                                    selectedValue = value;
                                                  });
                                                },
                                                children: [
                                                  Text("0"),
                                                  Text("1"),
                                                  Text("2"),
                                                  Text("3"),
                                                  Text("4"),
                                                  Text("5"),
                                                  Text("6"),
                                                  Text("7"),
                                                  Text("8"),
                                                  Text("9"),
                                                  Text("10"),
                                                ]),
                                            ),
                                            Expanded(
                                              child: CupertinoPicker(
                                                backgroundColor: Colors.white,
                                                itemExtent: 32,
                                                onSelectedItemChanged: (value) {
                                                  setState(() {
                                                    secondSelectedValue = value;
                                                  });
                                                },
                                                children: [
                                                  Text("days"),
                                                  Text("weeks"),
                                                  Text("months"),
                                                  Text("years")
                                                ]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: SizeConfig.blockSizeVertical * 33,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget> [
                                                    FlatButton(
                                                      child: Text("On a date"),
                                                      onPressed: () async {
                                                        onDate = await showRoundedDatePicker(
                                                            context: context,
                                                            initialDate: startDate,
                                                            lastDate: DateTime(DateTime.now().year + 1),
                                                            borderRadius: 16,
                                                            theme: ThemeData(primarySwatch: Colors.green),
                                                          );
                                                        setState(() {
                                                          
                                                        });
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text("After number of occurrences"),
                                                      onPressed: () {

                                                      },
                                                    )
                                                  ]
                                                ),
                                              );
                                            }
                                          );
                                        },
                                        child: Container(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              FlatButton.icon(
                                                onPressed: () {
                                                  
                                                },
                                                icon: Icon(Icons.compare_arrows),
                                                label: Text(doesNotEnd)
                                              ),
                                              Icon(Icons.arrow_forward_ios)
                                            ],
                                          )
                                        ),
                                      )
                                    ],
                                  ),
                                );
                          });
                      },
                      child: Text(doesNotRepeat)
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 0.73, 0.0, 0.0)),
                  Material(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 4.8, 0, SizeConfig.blockSizeHorizontal * 4.8, 0),
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
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 0.73, 0, 0)),
                  Material(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 4.8, 0, SizeConfig.blockSizeHorizontal * 4.8, 0),
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
              Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 0.73),),
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
                          child: Text(_bottomText, style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          )),
                          onPressed: () async {
                            print("clicked");
                            final form = _thirdformKey.currentState;
                            form.save();

                            if(communityServiceEventValue == true) {
                              _type = "Community Service Project";
                            }
                            if(serviceEventValue == true) {
                              _type = "Service Event";
                            }
                            if(doesNotRepeat != "Does Not Repeat" && theDate != null) {
                              if(typeOfDate == "days") {
                                DateTime tempDateTime = _newDateTime;
                                _date = _newDateTime.toString().substring(5, 7) + "/" + _newDateTime.toString().substring(8, 10) + "/" + _newDateTime.toString().substring(0, 4);
                                for(int i = 1; i < 999; i++) {
                                  if(tempDateTime.isAfter(onDate) || tempDateTime.isAtSameMomentAs(onDate)) {
                                    break;
                                  }
                                  else {
                                    tempDateTime = new DateTime(_newDateTime.year, _newDateTime.month, _newDateTime.day + (selectedValue * i));
                                    if(tempDateTime.isAfter(onDate)) {
                                      break;
                                    }
                                    else {
                                      _date = _date + "-" + tempDateTime.toString().substring(5, 7) + "/" + tempDateTime.toString().substring(8, 10) + "/" + tempDateTime.toString().substring(0, 4);
                                    }
                                  }
                                }
                              }
                              if(typeOfDate == "weeks") {
                                DateTime tempDateTime = _newDateTime;
                                _date = _newDateTime.toString().substring(5, 7) + "/" + _newDateTime.toString().substring(8, 10) + "/" + _newDateTime.toString().substring(0, 4);
                                for(int i = 1; i < 999; i++) {
                                  if(tempDateTime.isAfter(onDate) || tempDateTime.isAtSameMomentAs(onDate)) {
                                    break;
                                  }
                                  else {
                                    tempDateTime = new DateTime(_newDateTime.year, _newDateTime.month, _newDateTime.day + ((selectedValue * 7) * i));
                                    if(tempDateTime.isAfter(onDate)) {
                                      break;
                                    }
                                    else {
                                      _date = _date + "-" + tempDateTime.toString().substring(5, 7) + "/" + tempDateTime.toString().substring(8, 10) + "/" + tempDateTime.toString().substring(0, 4);
                                    }
                                  }
                                }
                              }
                              if(typeOfDate == "months") {
                                DateTime tempDateTime = _newDateTime;
                                _date = _newDateTime.toString().substring(5, 7) + "/" + _newDateTime.toString().substring(8, 10) + "/" + _newDateTime.toString().substring(0, 4);
                                for(int i = 1; i < 999; i++) {
                                  if(tempDateTime.isAfter(onDate) || tempDateTime.isAtSameMomentAs(onDate)) {
                                    break;
                                  }
                                  else {
                                    tempDateTime = new DateTime(_newDateTime.year, _newDateTime.month + (selectedValue * i), _newDateTime.day);
                                    if(tempDateTime.isAfter(onDate)) {
                                      break;
                                    }
                                    else {
                                      _date = _date + "-" + tempDateTime.toString().substring(5, 7) + "/" + tempDateTime.toString().substring(8, 10) + "/" + tempDateTime.toString().substring(0, 4);
                                    }
                                  }
                                }
                              }
                              if(typeOfDate == "years") {
                                DateTime tempDateTime = _newDateTime;
                                _date = _newDateTime.toString().substring(5, 7) + "/" + _newDateTime.toString().substring(8, 10) + "/" + _newDateTime.toString().substring(0, 4);
                                for(int i = 1; i < 999; i++) {
                                  if(tempDateTime.isAfter(onDate) || tempDateTime.isAtSameMomentAs(onDate)) {
                                    break;
                                  }
                                  else {
                                    tempDateTime = new DateTime(_newDateTime.year + (selectedValue * i), _newDateTime.month, _newDateTime.day);
                                    if(tempDateTime.isAfter(onDate)) {
                                      break;
                                    }
                                    else {
                                      _date = _date + "-" + tempDateTime.toString().substring(5, 7) + "/" + tempDateTime.toString().substring(8, 10) + "/" + tempDateTime.toString().substring(0, 4);
                                    }
                                  }
                                }
                              }
                            }
                            else {
                              _date = _newDateTime.toString().substring(5, 7) + "/" + _newDateTime.toString().substring(8, 10) + "/" + _newDateTime.toString().substring(0, 4);
                            }

                            if(form.validate()) {
                              try {
                                try {
                                  _photoUrl = await firebaseStorageRef.getDownloadURL();
                                }
                                catch (e) {
                                  
                                }
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
                                    startingDate = "";
                                    theEndTime = "";
                                    theStartTime = "";
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
                              print("failed");
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