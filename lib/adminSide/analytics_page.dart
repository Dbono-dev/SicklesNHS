import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/custom_painter.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';

class AnalyticsPage extends StatefulWidget {

  AnalyticsPage({this.snapshot, this.currentQuarter});

  final AsyncSnapshot<dynamic> snapshot;
  final String currentQuarter;

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PageController _pageController;
  Color left = Colors.white;
  Color right = Colors.white;
  Color middle = Colors.black;
  @override
  Widget build(BuildContext context) {
    double totalHours = 0;
    double requiredHours = 0;
    double completedChapterProjects = 0;
    double combination = 0;
    double combinationEleventh = 0;
    double combinationTwelve = 0;
    double eleventh = 0;
    double twelfth = 0;
    int totalEleventh = 0;
    int totalTwelfth = 0;
    double chapterProjectsEleventh = 0;
    double chapterProjectsTwelfth = 0;
    bool paidDues = false;
    int paidDuesTotal = 0;
    int paidDuesEleventh = 0;
    int paidDuesTwelve = 0;
    int totalMembers = 0;

    for(int i = 0; i < widget.snapshot.data.length; i++) {
      paidDues = false;
      DocumentSnapshot doc = widget.snapshot.data[i];
      double hours = double.parse(doc.data['hours'].toString());
      double quarterHours = double.parse(doc.data[widget.currentQuarter].toString());
      int projects = doc.data['num of community service events'];
      int grade = int.tryParse(doc.data['grade']) != null ? int.parse(doc.data['grade']) : 0;
      int permissions = doc.data['permissions'];
      if(doc.data['dues'] != null && doc.data['dues'].length >= 1) {
        paidDues = true;
      }
      if(permissions == 2) {
        totalMembers += 1;
        totalHours += hours;
        completedChapterProjects += projects;
        if(paidDues == true) {
          paidDuesTotal += 1;
        }
        if(grade == 11) {
          chapterProjectsEleventh += projects;
          if(paidDues == true) {
            paidDuesEleventh += 1;
          }
        }
        if(grade == 12) {
          chapterProjectsTwelfth += projects;
          if(paidDues == true) {
            paidDuesTwelve += 1;
          }
        }
        if(widget.currentQuarter == "secondQuarter") {
          if(quarterHours >= 3) {
            requiredHours += 1;
            if(projects >= 1) {
              combination += 1;
            }
            if(grade == 11) {
              eleventh += 1;
            }
            else if (grade == 12) {
              twelfth += 1;
            }
            else {

            }
            if(grade == 11 && projects >= 1) {
              combinationEleventh += 1;
            }
            else if(grade == 12 && projects >= 1) {
              combinationTwelve += 1;
            }
          }
        }
        else {
          if(quarterHours >= 6) {
            requiredHours += 1;
            if(projects >= 1) {
              combination += 1;
            }
            if(grade == 11) {
              eleventh += 1;
            }
            else if (grade == 12) {
              twelfth += 1;
            }
            else {
              
            }
            if(grade == 11 && projects >= 1) {
              combinationEleventh += 1;
            }
            else if(grade == 12 && projects >= 1) {
              combinationTwelve += 1;
            }
          }
        }

        if(grade == 11) {
          totalEleventh += 1;
        }
        else if(grade == 12) {
          totalTwelfth += 1;
        }
      }
      
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          TopHalfViewStudentsPage(),
          Padding(
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 18),
            child: Container(
              width: SizeConfig.blockSizeHorizontal * 100,
              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
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
              child: Container(
                height: SizeConfig.blockSizeVertical * 80,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: totalHours.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 52, letterSpacing: 2.5, color: Colors.black),
                          children: <TextSpan> [
                            TextSpan(
                              text: "\nTOTAL HOURS",
                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, letterSpacing: 0)
                            )
                          ]
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _buildMenuBar(context)
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 60,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) {
                            if(i == 0) {
                              setState(() {
                                middle = Colors.white;
                                right = Colors.white;
                                left = Colors.black;
                              });
                            }
                            else if(i == 1) {
                              setState(() {
                                middle = Colors.black;
                                right = Colors.white;
                                left = Colors.white;
                              });
                            }
                            else if(i == 2) {
                              setState(() {
                                right = Colors.black;
                                left = Colors.white;
                                middle = Colors.white;
                              });
                            }
                          },
                          children: <Widget> [
                            ConstrainedBox(
                              constraints: BoxConstraints.expand(),
                              child: theBody(eleventh, totalEleventh, chapterProjectsEleventh, combinationEleventh, paidDuesEleventh)
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints.expand(),
                              child: theBody(requiredHours, totalMembers, completedChapterProjects, combination, paidDuesTotal)
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints.expand(),
                              child: theBody(twelfth, totalTwelfth, chapterProjectsTwelfth, combinationTwelve, paidDuesTwelve)
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      height: 50,
      width: 375,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.green
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              onPressed: _onSignInButtonPress,
              child: Text("11th Grade", style: TextStyle(color: left,))
              ),
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: __onMiddleButtonPressed,
              child: Text("All", style: TextStyle(color: middle,))
              ),
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: _onSignUpButtonPress,
              child: Text("12th Grade", style: TextStyle(color: right,))
              )
          ],
        ),
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController.animateToPage(2, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void __onMiddleButtonPressed() {
    _pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  Widget theBody(double requiredHours, int totalMembers, double completedChapterProjects, double combination, int paidDues) {
    return Container(
      height: SizeConfig.blockSizeVertical * 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              justTheText("COMPLETED\nREQUIRED HOURS"),
              justTheCircle(double.parse((requiredHours / totalMembers).toStringAsFixed(3))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              justTheText("COMPLETED\nCHAPTER PROJECTS"),
              justTheCircle(double.parse((completedChapterProjects / totalMembers).toStringAsFixed(3))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              justTheText("COMPLETED HOURS +\nCHAPTER PROJECT"),
              justTheCircle(double.parse((combination / totalMembers).toStringAsFixed(3))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              justTheText("PAID\nDUES"),
              justTheCircle(double.parse((paidDues / totalMembers).toStringAsFixed(3))),
            ],
          ),
          bottomText(totalMembers.toString(), " TOTAL MEMBERS")
        ],
      ),
    );
  }

  Widget justTheText(String text) {
    return Container(
      width: SizeConfig.blockSizeHorizontal * 25,
      child: Text(text, style: TextStyle(fontSize: 16), textAlign: TextAlign.center)
    );
  }

  Widget justTheCircle(double theDoubleNumber) {
    String theText;
    try {
      theText = (theDoubleNumber * 100).toString().substring(0, 4);
    }
    catch (e) {
      theText = (theDoubleNumber * 100).toString().substring(0, 3);
    }
    return Container(
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), offset: Offset(2, 4), blurRadius: 4, spreadRadius: 0)]),
      child: CircularPercentIndicator(
        backgroundColor: Colors.white,
        progressColor: Colors.green,
        radius: SizeConfig.blockSizeVertical * 12,
        lineWidth: 5,
        startAngle: 180,
        percent: theDoubleNumber,
        center: Text(theText + "%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.blockSizeVertical * 2.5),),
      ),
    );
  }

  Widget circleText(String text, double theDoubleNumber) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(text, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
          Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), offset: Offset(2, 4), blurRadius: 4, spreadRadius: 0)]),
            child: CircularPercentIndicator(
              backgroundColor: Colors.white,
              progressColor: Colors.green,
              radius: SizeConfig.blockSizeVertical * 12,
              lineWidth: 5,
              startAngle: 180,
              percent: theDoubleNumber,
              center: Text((theDoubleNumber * 100).toString().substring(0, 4) + "%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.blockSizeVertical * 2.5),),
            ),
          )
        ],
      ),
    );
  }

  Widget gradeCircles(String text, double theDoubleNumber) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), offset: Offset(2, 4), blurRadius: 4, spreadRadius: 0)]),
            child: CircularPercentIndicator(
              backgroundColor: Colors.white,
              progressColor: Colors.green,
              radius: SizeConfig.blockSizeVertical * 12,
              lineWidth: 5,
              startAngle: 180,
              percent: theDoubleNumber,
              center: Text((theDoubleNumber * 100).toString().substring(0, 4) + "%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.blockSizeVertical * 2.5),),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1)),
          Text(text, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget bottomText(String number, String backingText) {
    return RichText(
      text: TextSpan(
        text: number,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
        children: <TextSpan> [
          TextSpan(
            text: backingText,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 12)
          )
        ]
      ), 
    );
  }
}