import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/home_page.dart';
import 'package:sickles_nhs_app/memberSide/account_profile.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/currentQuarter.dart';

class ViewStudents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: SizeConfig.blockSizeVertical * 100,
          child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: <Widget> [
                  TopHalfViewStudentsPage(),
                  Padding(
                    padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(000000).withOpacity(0.25),
                            offset: Offset(0, -2),
                            blurRadius: 15,
                            spreadRadius: 5
                          )
                        ]
                      ),
                      child: Column(
                        children: [
                          TopMiddleViewStudentPage(),
                          MiddleViewStudentsPage(),
                        ],
                      ),
                    ),
                  ),
                ]
              )
          ),
        ),
      ),
    );
  }
}

class TopHalfViewStudentsPage extends StatelessWidget {
  TopHalfViewStudentsPage({Key key, this.text}) : super (key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          UserData userData = snapshot.data;
            return Material(
              child: Container(
              height: SizeConfig.blockSizeVertical * 22.5,
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      iconSize: 60,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TheOpeningPage()));
                      },
                    ),
                  ],
                ),
              ),
            ),
      );
        }
        else {
          return Container();
        }
      });
  }
}

class TopMiddleViewStudentPage extends StatelessWidget {

  String currentQuarter = "";

  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").getDocuments();
    currentQuarter = await CurrentQuarter(DateTime.now()).currentQuarter();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    int yes = 0;
    int no = 0;

    return Container(
      child: FutureBuilder(
        future: getPosts(),
        builder: (_, snapshot2) {
          if(snapshot2.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.green),);
          }
          else {
            for(int i = 0; i < snapshot2.data.length; i++) {
              if(int.tryParse(snapshot2.data[i].data['grade']) == null || snapshot2.data[i].data['permissions'] == 1 || snapshot2.data[i].data['permissions'] == 0) {

              }
              else {
                if(currentQuarter == "secondQuarter") {
                  if(snapshot2.data[i].data[currentQuarter] >= 3) {
                    yes = yes + 1;
                  }
                  else { 
                    no = no + 1;
                  }
                }
                else {
                  if(snapshot2.data[i].data[currentQuarter] >= 6) {
                    yes = yes + 1;
                  }
                  else { 
                    no = no + 1;
                  }
                }
              }
            }
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
              child: Column(
                children: <Widget>[
                  Text("Current Status of this Quarter", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(Icons.check, color: Colors.green,),
                      RichText(
                        text: TextSpan(
                          text: "Completed: ",
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                          children: <TextSpan> [
                            TextSpan(
                              text: yes.toString(),
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)
                            )
                          ]
                        ), 
                      ),
                      Icon(Icons.close, color: Colors.red,),
                      RichText(
                        text: TextSpan(
                          text: "Not Completed: ",
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                          children: <TextSpan> [
                            TextSpan(
                              text: no.toString(),
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)
                            )
                          ]
                        ), 
                      )
                    ],
                  ),
                ],
              ),
            );
          }
        },
      )
    );
  }
}

class MiddleViewStudentsPage extends StatefulWidget {

  @override
  _MiddleViewStudentsPageState createState() => _MiddleViewStudentsPageState();
}

class _MiddleViewStudentsPageState extends State<MiddleViewStudentsPage> {
  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").getDocuments();
    return qn.documents;
  }

  String search = "";
  bool firstCheck = false;
  bool secondCheck = false;
  bool thirdCheck = false;

  List<String> checks = new List<String>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical * 69.75,
      child: Column(
        children: <Widget>[
          Container(
            child: TextFormField(
              initialValue: search,
              decoration: InputDecoration(
                hintText: "Search",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.green)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green), borderRadius: BorderRadius.circular(30)),
                prefixIcon: Icon(Icons.search, color: Colors.green,),
              ),
              onChanged: (text) {
                setState(() {
                  search = text;
                });
              },
            ),
          ),
          Container(
            child: Card(
              elevation: 8,
              margin: EdgeInsets.fromLTRB(SizeConfig.blockSizeHorizontal * 2.43, 0, SizeConfig.blockSizeHorizontal * 2.43, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
              ),
              child: ExpansionTile(
                title: Text("Filter"),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text("Grade:"),
                      Container(
                        width: SizeConfig.blockSizeHorizontal * 95,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget> [
                            Text("10th Grade:", style: TextStyle(fontSize: 12.5),),
                            Checkbox(
                              activeColor: Colors.green,
                              value: firstCheck,
                              onChanged: (newValue) {
                                if(checks.length == 0 || firstCheck == true) {
                                  setState(() {
                                    if(firstCheck == true) {
                                      checks.remove("firstCheck");
                                      firstCheck = newValue;
                                    }
                                    else {
                                      checks.add("firstCheck");
                                      firstCheck = newValue;
                                    }
                                  });
                                }
                              },
                            ),
                            Text("11th Grade:", style: TextStyle(fontSize: 12.5),),
                            Checkbox(
                              activeColor: Colors.green,
                              value: secondCheck,
                              onChanged: (theNewValue) {
                                if(checks.length == 0 || secondCheck == true) {
                                  setState(() {
                                    if(secondCheck == true) {
                                      checks.remove("secondCheck");
                                      secondCheck = theNewValue;
                                    }
                                    else {
                                      checks.add("secondCheck");
                                      secondCheck = theNewValue;
                                    }
                                  });
                                }
                              },
                            ),
                            Text("12th Grade:", style: TextStyle(fontSize: 12.5),),
                            Checkbox(
                              activeColor: Colors.green,
                              value: thirdCheck,
                              onChanged: (theNewValue2) {
                                if(checks.length == 0 || thirdCheck == true) {
                                  setState(() {
                                    if(thirdCheck == true) {
                                      checks.remove("thirdCheck");
                                      thirdCheck = theNewValue2;
                                    }
                                    else {
                                      checks.add("thirdCheck");
                                      thirdCheck = theNewValue2;
                                    }
                                  });
                                }
                              },
                            )
                          ]
                        ),
                      ),
                    ],
                  )
                ],
              )
            ),
          ),
          Padding(padding: EdgeInsets.all(5)),
          Expanded(
            child: Container(
              child: FutureBuilder(
                future: getPosts(),
                builder: (_, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.green)
                    )
                  );
                }
                else {
                  return Material(
                    child: Container(
                      height: SizeConfig.blockSizeVertical * 57,
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: snapshot.data.length,
                        itemBuilder: (_, index) {
                          if(int.tryParse(snapshot.data[index].data['grade']) == null) {
                            return Container();
                          }
                          else if(search != "") {
                            if(snapshot.data[index].data['first name'].toString().contains(search) || snapshot.data[index].data['last name'].toString().contains(search) || (snapshot.data[index].data["first name"] + " " + snapshot.data[index].data["last name"]).toString().contains(search)) {
                              return theViewStudents(snapshot.data[index], context);
                            }
                            else {
                              return Container();
                            }
                          }
                          else if(firstCheck == true) {
                            if(int.parse(snapshot.data[index].data['grade']) == 10) {
                              return theViewStudents(snapshot.data[index], context);
                            }
                            else {
                              return Container();
                            } 
                          }
                          else if(secondCheck == true) {
                            if(int.parse(snapshot.data[index].data["grade"]) == 11) {
                              return theViewStudents(snapshot.data[index], context);
                            }
                            else {
                              return Container();
                            }
                          }
                          else if(thirdCheck == true) {
                            if(int.parse(snapshot.data[index].data['grade']) == 12) {
                              return theViewStudents(snapshot.data[index], context);
                            }
                            else {
                              return Container();
                            }
                          }
                          else {
                            return theViewStudents(snapshot.data[index], context);
                          }
                        },
                      ),
                    ),
                  );
                }
              }
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget theViewStudents(DocumentSnapshot snapshot, BuildContext context) {
    Color backgroundColor;
    Color fontColorOne;
    Color fontColorTwo;

    if(snapshot.data['hours'] >= 6) {
      backgroundColor = Colors.green;
      fontColorOne = Colors.white;
      fontColorTwo = Colors.white;
    }
    else {
      backgroundColor = Colors.white;
      fontColorOne = Colors.green;
      fontColorTwo = Colors.black;
    }


    return GestureDetector(
      onTap: () {
        Navigator.push(context, 
        MaterialPageRoute(builder: (context) => AccountProfile(posts: snapshot, type: "admin")
        ));
      },
        child: Container(
        width: SizeConfig.blockSizeHorizontal * 75,
          child: Card(
            color: backgroundColor,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: Row(
                children: <Widget> [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(snapshot.data["first name"] + " " + snapshot.data["last name"], style: TextStyle(
                          color: fontColorOne,
                          fontSize: 25
                        ),),
                        Text("Hours: " + snapshot.data["hours"].toString() + "\t Grade: " + snapshot.data["grade"], style: TextStyle(color: fontColorTwo),)
                    ],  
                  ),
                  Spacer(),
                  IconButton(
                        icon: Icon(Icons.arrow_forward),
                        iconSize: 35,
                        onPressed: () {
                          Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => AccountProfile(posts: snapshot, type: "admin",)
                          ));
                        },
                      )
                ]
              ),
            )
        )),
    );
  }