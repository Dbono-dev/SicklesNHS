import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';

class AnalyticsPage extends StatelessWidget {

  AnalyticsPage({this.snapshot, this.currentQuarter});

  final AsyncSnapshot<dynamic> snapshot;
  final String currentQuarter;

  @override
  Widget build(BuildContext context) {
    double totalHours = 0;
    double requiredHours = 0;
    double completedChapterProjects = 0;
    double combination = 0;
    double eleventh = 0;
    double twelfth = 0;
    int totalEleventh = 0;
    int totalTwelfth = 0;
    double paidDues;
    int totalMembers = 0;

    for(int i = 0; i < snapshot.data.length; i++) {
      DocumentSnapshot doc = snapshot.data[i];
      double hours = double.parse(doc.data['hours'].toString());
      double quarterHours = double.parse(doc.data[currentQuarter].toString());
      int projects = doc.data['num of community service events'];
      int grade = int.tryParse(doc.data['grade']) != null ? int.parse(doc.data['grade']) : 0;
      int permissions = doc.data['permissions'];
      
      if(permissions == 2) {
        totalMembers += 1;
        totalHours += hours;
        completedChapterProjects += projects;
        if(currentQuarter == "secondQuarter") {
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
                    Container(
                      height: SizeConfig.blockSizeVertical * 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              justTheText("COMPLETED\nREQUIRED HOURS"),
                              justTheText("COMPLETED\nCHAPTER PROJECTS"),
                              justTheText("COMPLETED HOURS +\nCHAPTER PROJECT"),
                            ]
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              justTheCircle(double.parse((requiredHours / totalMembers).toStringAsFixed(3))),
                              justTheCircle(double.parse((completedChapterProjects / totalMembers).toStringAsFixed(3))),
                              justTheCircle(double.parse((combination / totalMembers).toStringAsFixed(3))),
                            ],
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        gradeCircles("11TH GRADE", double.parse((eleventh / totalEleventh).toStringAsFixed(3))),
                        gradeCircles("12th GRADE", double.parse((twelfth / totalTwelfth).toStringAsFixed(3)))
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), offset: Offset(2, 4), blurRadius: 4, spreadRadius: 0)]),
                            child: CircularPercentIndicator(
                              backgroundColor: Colors.white,
                              progressColor: Colors.green,
                              radius: SizeConfig.blockSizeVertical * 12,
                              lineWidth: 5,
                              startAngle: 180,
                              percent: 0,
                              center: Text((0.0 * 100).toString() + "%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.blockSizeVertical * 2.5),),
                            ),
                          ),
                          Text("PAID DUES", style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    bottomText(43.toString(), " ONLINE TODAY"),
                    bottomText(totalMembers.toString(), " TOTAL MEMBERS")
                  ],
                ),
              ),
            )
          )
        ],
      ),
    );
  }

  Widget justTheText(String text) {
    return Text(text, style: TextStyle(fontSize: 16), textAlign: TextAlign.center);
  }

  Widget justTheCircle(double theDoubleNumber) {
    return Container(
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