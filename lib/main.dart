import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/auth_service.dart';
import 'package:sickles_nhs_app/backend/messages_page.dart';
import 'package:sickles_nhs_app/backend/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/backend/user.dart';
import 'package:sickles_nhs_app/memberSide/notification_system.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    return StreamProvider<User>.value(
      value: AuthService().user,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Wrapper(),
      ),
    ); 
  }
}