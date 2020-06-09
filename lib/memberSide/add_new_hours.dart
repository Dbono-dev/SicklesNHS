import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:signature/signature.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddNewHours extends StatelessWidget {
  AddNewHours({Key key, this.name, this.uid, this.hours}) : super (key: key);

  final String name;
  final String uid;
  final int hours;

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.white,
      body: Container(
        height: SizeConfig.blockSizeVertical * 100,
        width: SizeConfig.blockSizeHorizontal * 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget> [
            TopHalfViewStudentsPage(),
            Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 1)),
            AddNewHoursMiddle(name: name, uid: uid, hours: hours),
          ]
        ),
      ),
    );
  }
}

class AddNewHoursMiddle extends StatefulWidget {
  AddNewHoursMiddle({Key key, this.name, this.uid, this.hours}) : super (key: key);

  final String name;
  final String uid;
  final int hours;

  @override
  _AddNewHoursMiddleState createState() => _AddNewHoursMiddleState();
}

class _AddNewHoursMiddleState extends State<AddNewHoursMiddle> {

  DateTime newDateTime () {
    int theCurrentTime = DateTime.now().minute;
    DateTime theNewDateTime = DateTime.now();

    while(theCurrentTime % 10 != 0) {
      theCurrentTime += 1;
    }

    DateTime thenewDate = new DateTime(theNewDateTime.year, theNewDateTime.month, theNewDateTime.day, theNewDateTime.hour, theCurrentTime, theNewDateTime.second);
    return thenewDate;
  }

  final SignatureController _controller = SignatureController(penStrokeWidth: 3, penColor: Colors.green);
  String _typeOfActivity;
  String _location;
  String _hours;
  String _nameOfSup;
  String _supPhone;
  String _emailSup;
  String _date;
  final _fourthformKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical * 78,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Material(
          color: Colors.white,
          child: Form(
            key: _fourthformKey,
            child: SingleChildScrollView(
              child: Column(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        hintText: 'Type of Activity',
                      ),
                        onChanged: (val) => _typeOfActivity = (val),
                        initialValue: _typeOfActivity,
                        validator: (value) {
                          if(value.isEmpty) {
                            return 'Enter text';
                          }
                          return null;
                        },
                      ),
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 2, 0.0, 0.0)),
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        hintText: 'Location',
                      ),
                        onChanged: (val) => _location = (val),
                        initialValue: _location,
                        validator: (value) {
                          if(value.isEmpty) {
                            return 'Enter text';
                          }
                          return null;
                        },
                      ),
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 2, 0.0, 0.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: SizeConfig.blockSizeHorizontal * 30,
                        child: OutlineButton(
                        hoverColor: Colors.green,
                        highlightColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
                        borderSide: BorderSide(color: Colors.green, style: BorderStyle.solid, width: 3),
                        child: Text("Date"),
                        onPressed: () {
                          showModalBottomSheet(context: context, builder: (BuildContext builder) {
                            return Container(
                              height: MediaQuery.of(context).copyWith().size.height / 3,
                              child: CupertinoDatePicker(
                                initialDateTime: newDateTime(),
                                onDateTimeChanged: (DateTime newDate) {
                                  _date = newDate.toString().substring(5, 7) + "/" + newDate.toString().substring(8, 10) + "/" + newDate.toString().substring(0, 4);
                                },
                                mode: CupertinoDatePickerMode.date,
                                maximumDate: new DateTime(2030, 12, 30)
                              ),
                            );
                          });
                        },
                    ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 2, 0.0, 0.0)),
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal * 35,
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            hintText: 'Hours',
                          ),
                            onChanged: (val) => _hours = (val),
                            initialValue: _hours,
                            validator: (value) {
                              if(value.isEmpty) {
                                return 'Enter number';
                              }
                              try {
                                int.parse(value);
                              }
                              catch(e) {
                                return 'Enter number';
                              }
                              return null;
                            },
                          ),
                        )
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 2, 0.0, 0.0)),
                  Container(
                    width: SizeConfig.blockSizeHorizontal * 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.green,
                        width: 1
                      )
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("Supervisor Signature", style: TextStyle(
                              color: Colors.green,
                              fontSize: SizeConfig.blockSizeHorizontal * 5
                            ),),
                            IconButton(
                              icon: Icon(Icons.refresh),
                              color: Colors.green,
                              onPressed: () {
                                setState(() {
                                  _controller.clear();
                                });
                              },
                            )
                          ],
                        ),
                        Signature(
                          controller: _controller,
                          height: SizeConfig.blockSizeVertical * 20,
                          width: SizeConfig.blockSizeHorizontal * 90,
                          backgroundColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 2, 0.0, 0.0)),
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        hintText: 'Name Of Supervisor',
                      ),
                        onChanged: (val) => _nameOfSup = (val),
                        initialValue: _nameOfSup,
                        validator: (value) {
                          if(value.isEmpty) {
                            return 'Enter text';
                          }
                          return null;
                        },
                      ),
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 2, 0.0, 0.0)),
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        hintText: 'Supervisor Phone Number',
                      ),
                        onChanged: (val) => _supPhone = (val),
                        initialValue: _supPhone,
                        validator: (value) {
                          if(value.isEmpty) {
                            return 'Enter Phone Number';
                          }
                          return null;
                        },
                      ),
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.blockSizeVertical * 2, 0.0, 0.0)),
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        hintText: 'Contact Email of Supervisor',
                      ),
                        onChanged: (val) => _emailSup = (val),
                        initialValue: _emailSup,
                        validator: (value) {
                          if(value.isEmpty) {
                            return 'Enter email';
                          }
                          return null;
                        },
                      ),
                    )
                  ),
                  Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 1)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 25, 0, SizeConfig.blockSizeHorizontal * 25, 0),
                    child: RaisedButton(
                      elevation: 10,
                      color: Colors.white,
                      onPressed: () async {
                        final form = _fourthformKey.currentState;
                            form.save();
                            if(form.validate() && _controller.isNotEmpty) {
                              try {
                                var signture = await _controller.toPngBytes();
                                final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(_typeOfActivity + widget.name + _location + '.jpg');
                                final StorageUploadTask task = firebaseStorageRef.putData(signture);
                                var url = await firebaseStorageRef.getDownloadURL();

                                dynamic result = sendEventToDatabase(_typeOfActivity, _location, _hours, _nameOfSup, _supPhone, _emailSup, _date, widget.name, url, widget.uid, widget.hours, "save");

                                if(result == null) {
                                  print("Fill in all the forms.");
                                }
                                if(result != null) {
                                  setState(() {
                                    _controller.clear();
                                    _fourthformKey.currentState.reset();
                                  });
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Saved Service Hour Form"),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    )
                                  );
                                }
                              }
                              catch (e) {
                                return CircularProgressIndicator();
                              }
                        } else {
                          return Container();
                        }
                      },
                      child: Text("Save Service Hour Form", textAlign: TextAlign.center),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2.5),),
                  Builder(
                    builder: (context) {
                      return Material(
                      type: MaterialType.transparency,
                      child: Container(
                      height: 49.0,
                      width: SizeConfig.blockSizeHorizontal * 100,
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(
                          color: Colors.black,
                          blurRadius: 25.0,
                          spreadRadius: 2.0,
                          offset: Offset(0, -5.0)
                          )
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)
                        ),
                        color: Colors.green,
                      ),
                      child: GestureDetector(
                            onTap: () async {
                            final form = _fourthformKey.currentState;
                            form.save();
                            if(form.validate() && _controller.isNotEmpty) {
                              try {
                                var signture = await _controller.toPngBytes();
                                final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(_typeOfActivity + widget.name + _location + '.jpg');
                                final StorageUploadTask task = firebaseStorageRef.putData(signture);
                                var url = await firebaseStorageRef.getDownloadURL();

                                dynamic result = sendEventToDatabase(_typeOfActivity, _location, _hours, _nameOfSup, _supPhone, _emailSup, _date, widget.name, url, widget.uid, widget.hours, "submit");

                                if(result == null) {
                                  print("Fill in all the forms.");
                                }
                                if(result != null) {
                                  setState(() {
                                    _controller.clear();
                                    _fourthformKey.currentState.reset();
                                  });
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Submitted Service Hour Form"),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    )
                                  );
                                }
                              }
                              catch (e) {
                                return CircularProgressIndicator();
                              }
                        } else {
                          return Container();
                        }
                            },
                          child: Center(
                            child: Text("Submit", style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                            )),
                                ),
                              ),
                      ));
                    },
                  )
              ],
              )
             ),
          )
        ),
      ),
    );
  }

  Future sendEventToDatabase(String type, String location, String hours, String nameOfSup, String supPhone, String emailSup, String date, String name, var url, String uid, int currentHours, String saveSubmit) async {
    await DatabaseSubmitHours().updateSubmitHours(type, location, hours, nameOfSup, supPhone, emailSup, date, name, false, url, uid, currentHours, saveSubmit);
  }
}
