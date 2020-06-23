import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/auth_service.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
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
            primaryColor: Colors.green
          ),
          debugShowCheckedModeBanner: false,
          home: Wrapper(),
      ),
    ); 
  }
}

class CommonBottomPageButton extends StatelessWidget {

  CommonBottomPageButton({Key key, this.text, this.method}) : super(key: key);

  final String text;
  final Future method;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
      height: SizeConfig.blockSizeVertical * 7,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(
          color: Colors.black,
          blurRadius: 15.0,
          spreadRadius: 2.0,
          offset: Offset(0, 10.0)
          )
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        color: Colors.green,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Builder(
            builder: (context) {
              return FlatButton(
                child: Text(text, style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                )),
                onPressed: () async {
                  await method;
                }
              );
            },
          ),
        ],
      ),
    ),
    );
  }
}