import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/memberSide/account_profile.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/currentQuarter.dart';

class ViewStudents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget> [
            TopHalfViewStudentsPage(),
            Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 1)),
            TopMiddleViewStudentPage(),
            MiddleViewStudentsPage(),
          ]
        )
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
              height: SizeConfig.blockSizeVertical * 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)
                ),
                boxShadow: [BoxShadow(
                  color: Colors.black,
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 5.0)
                  )
                ],
                color: Colors.green,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    iconSize: 60,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 30),
                  ),
                  Container(
                    child: FloatingActionButton(
                      heroTag: text == null ? "" : text,
                      backgroundColor: Colors.grey,
                      elevation: 8,
                      onPressed: () {
                        Navigator.push(context, 
                          MaterialPageRoute(builder: (context) => AccountProfile(type: "student",)
                          ));
                      },
                      child: Text(userData.firstName.substring(0, 1) + userData.lastName.substring(0, 1), style: TextStyle(
                        color: Colors.white,
                        fontSize: 35
                      ),),
                    ),
                  )
                ],
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
  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    int yes = 0;
    int no = 0;

    String currentQuarter = "";

    Future getQuarter() async {
      currentQuarter = await CurrentQuarter(DateTime.now()).currentQuarter();
    }

    return Container(
      child: FutureBuilder(
        future: getPosts(),
        builder: (_, snapshot2) {
          if(snapshot2.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.green),);
          }
          else {
            return FutureBuilder(
              future: getQuarter(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.green),);
                }
                else {
                  for(int i = 0; i < snapshot2.data.length; i++) {
                    if(snapshot2.data[i].data[currentQuarter] >= 6) {
                      yes = yes + 1;
                    }
                    else { 
                      no = no + 1;
                    }
                  }
                  return Card(
                    child: Column(
                      children: <Widget>[
                        Text("Current Status of this Quarter"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(Icons.check, color: Colors.green,),
                            Text("Completed: " + yes.toString()),
                            Icon(Icons.close, color: Colors.red,),
                            Text("Not Completed: " + no.toString())
                          ],
                        ),
                      ],
                    ),
                  );
                }
              }
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


  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical * 70.5,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget> [
                          Text("10th Grade:"),
                          Checkbox(
                            activeColor: Colors.green,
                            value: firstCheck,
                            onChanged: (newValue) {
                              setState(() {
                                firstCheck = newValue;
                              });
                            },
                          ),
                          Text("11th Grade:"),
                          Checkbox(
                            activeColor: Colors.green,
                            value: secondCheck,
                            onChanged: (theNewValue) {
                              setState(() {
                                secondCheck = theNewValue;
                              });
                            },
                          ),
                          Text("12th Grade:"),
                          Checkbox(
                            activeColor: Colors.green,
                            value: thirdCheck,
                            onChanged: (theNewValue2) {
                              setState(() {
                                thirdCheck = theNewValue2;
                              });
                            },
                          )
                        ]
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
                      height: SizeConfig.blockSizeVertical * 59,
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: snapshot.data.length,
                        itemBuilder: (_, index) {
                          if(search != "") {
                            if(snapshot.data[index].data['first name'].toString().contains(search) || snapshot.data[index].data['last name'].toString().contains(search) || (snapshot.data[index].data["first name"] + " " + snapshot.data[index].data["last name"]).toString().contains(search)) {
                              return TheViewStudents(snapshot.data[index], context);
                            }
                            else {
                              return Container();
                            }
                          }
                          else if(firstCheck == true) {
                            if(int.parse(snapshot.data[index].data['grade']) == 10) {
                              return TheViewStudents(snapshot.data[index], context);
                            }
                            else {
                              return Container();
                            } 
                          }
                          else if(secondCheck == true) {
                            if(int.parse(snapshot.data[index].data["grade"]) == 11) {
                              return TheViewStudents(snapshot.data[index], context);
                            }
                            else {
                              return Container();
                            }
                          }
                          else if(thirdCheck == true) {
                            if(int.parse(snapshot.data[index].data['grade']) == 12) {
                              return TheViewStudents(snapshot.data[index], context);
                            }
                            else {
                              return Container();
                            }
                          }
                          else {
                            return TheViewStudents(snapshot.data[index], context);
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

Widget TheViewStudents(DocumentSnapshot snapshot, BuildContext context) {
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