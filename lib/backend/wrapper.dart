import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/home_page.dart';
import 'package:sickles_nhs_app/login_screen.dart';
import 'package:sickles_nhs_app/backend/push_notification.dart';
import 'package:sickles_nhs_app/backend/user.dart';

class Wrapper extends StatelessWidget {
  final PushNotificationService _pushNotificationService = PushNotificationService();

  Future pushNotification() async {
    //await _pushNotificationService.initialise();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    pushNotification();

    if(user == null) {
      return LoginScreen();
    }
    else {
      return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return TheOpeningPage();
          }
          else {
            return Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: SizeConfig.blockSizeHorizontal * 100,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("SICKLES NHS", style: TextStyle(color: Colors.green, fontSize: 45)),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      );
    }
  }
}