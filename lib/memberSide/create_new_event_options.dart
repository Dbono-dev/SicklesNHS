import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/memberSide/add_new_hours.dart';
import 'package:sickles_nhs_app/memberSide/saved_service_hour.dart';
import 'package:sickles_nhs_app/memberSide/submitted_service_hour_forms.dart';

class CreateNewHoursOptionsPage extends StatelessWidget {
  CreateNewHoursOptionsPage({Key key, this.tile1, this.tile2, this.tile3}) : super(key: key);

  final String tile1;
  final String tile2;
  final String tile3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 2)),
          theTiles(tile1, AddNewHours(), context),
          theTiles(tile2, ViewSavedServiceHourForms(), context),
          theTiles(tile3, SubmittedServiceHourForms(), context),
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