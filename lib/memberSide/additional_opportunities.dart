import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';

class AdditionalOpportunities extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack( 
        children: [
          TopHalfViewStudentsPage(),
          Padding(
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 18),
            child: Container(
              width: SizeConfig.blockSizeHorizontal * 100,
              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
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
                  theAdditionalOpportunitiesTiles("Virtual Tutoring Opportunity", "Interested in tutoring middle school students in language arts?"),
                  theAdditionalOpportunitiesTiles("Georgia Runoff Phone Banking", "Volunteer to phone bank for candidates in Georgia's Senate runoff elections in January!")
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget theAdditionalOpportunitiesTiles(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1.5),
      child: Container(
        width: SizeConfig.blockSizeHorizontal * 90,
        child: Card(
          elevation: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: SizeConfig.blockSizeHorizontal * 60,
                child: Column(
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600),),
                    Text(description, textAlign: TextAlign.center,)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 1),
                child: Text("More Details", style: TextStyle(decoration: TextDecoration.underline, color: Colors.green),),
              )
            ],
          ),
        ),
      ),
    );
  }
}