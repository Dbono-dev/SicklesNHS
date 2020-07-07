import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/auth_service.dart';
import 'package:sickles_nhs_app/backend/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:sickles_nhs_app/backend/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    return StreamProvider<User>.value(
      value: AuthService().user,
        child: MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.green,
            accentColor: Colors.green
          ),
          debugShowCheckedModeBanner: false,
          home: Wrapper(),
      ),
    ); 
  }
}