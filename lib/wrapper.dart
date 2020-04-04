import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/home_page.dart';
import 'package:sickles_nhs_app/login_screen.dart';
import 'package:sickles_nhs_app/push_notification.dart';
import 'package:sickles_nhs_app/user.dart';

class Wrapper extends StatelessWidget {
  final PushNotificationService _pushNotificationService = PushNotificationService();

  Future pushNotification() async {
    await _pushNotificationService.initialise();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    pushNotification();

    if(user == null) {
      return LoginScreen();
    }
    else {
      return TheOpeningPage();
    }
  }
}