import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/memberSide/add_new_hours.dart';
import 'package:sickles_nhs_app/memberSide/saved_service_hour.dart';
import 'package:sickles_nhs_app/memberSide/submitted_service_hour_forms.dart';
import 'package:sickles_nhs_app/adminSide/scanning_page.dart';
import 'package:sickles_nhs_app/adminSide/view_saved_scanning_session.dart';

class CreateNewHoursOptionsPage extends StatelessWidget {
  CreateNewHoursOptionsPage({Key key, this.tile1, this.tile2, this.tile3, this.uid}) : super(key: key);

  final String tile1;
  final String tile2;
  final String tile3;
  final String uid;

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 18),
            child: Container(
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
                  theTiles(tile1, tile1 == "Create New Scanning Session" ? ScanningPage(uid) : AddNewHours(), context),
                  theTiles(tile2, tile2 == "View Saved Scanning Sessions" ? ViewSavedScanningSessions(uid: uid,) : ViewSavedServiceHourForms(), context),
                  tile3 == "View Submitted Scanning Sessions" ? Container() : theTiles(tile3, SubmittedServiceHourForms(uid: uid), context),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget theTiles(String text, Widget location, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => location));
        },
        child: Card(
          elevation: 10,
          child: ListTile(
            title: Text(text),
            trailing: Icon(Icons.arrow_forward)
          )
        ),
      ),
    );
  }
}