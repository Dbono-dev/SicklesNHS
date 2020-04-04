import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/auth_service.dart';
import 'package:sickles_nhs_app/push_notification.dart';
import 'package:sickles_nhs_app/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  void intState() {
    PushNotificationService().initialise();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Wrapper()
      ),
    );
  }
}