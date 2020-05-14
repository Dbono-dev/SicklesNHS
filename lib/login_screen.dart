import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sickles_nhs_app/backend/auth_service.dart';
import 'package:sickles_nhs_app/sign_up.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen ({Key key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Stack(
      children: <Widget>[
        Container(
          height: SizeConfig.blockSizeVertical * 100,
          width: SizeConfig.blockSizeHorizontal * 100,
          color: Colors.green,
        ),
        Column(
          children: <Widget>[
            TopHalfLoginPage(),
            Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 10)),
            LoginPage(),
            //Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 8.5),),
            //BottonHalfLoginPage()
          ],
        )
      ],
    );
  }
}

class TopHalfLoginPage extends StatelessWidget {
  TopHalfLoginPage({Key key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Material(
            type: MaterialType.transparency,
            child: Container(
            padding: EdgeInsets.all(20),
            height: SizeConfig.blockSizeVertical * 20,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                color: Colors.black,
                blurRadius: 25.0,
                spreadRadius: 2.0,
                offset: Offset(0, 10.0)
                )
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)
              ),
              color: Colors.white,
            ),
            child: FittedBox(
                  fit: BoxFit.fitWidth,
                    child: Text("Sickles NHS", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green
                  )),
                ),
          ),
    );
  }
}

class BottonHalfLoginPage extends StatelessWidget {
  BottonHalfLoginPage({Key key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
            type: MaterialType.transparency,
            child: Container(
              alignment: Alignment.center,
            height: SizeConfig.blockSizeVertical * 10,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                color: Colors.black,
                blurRadius: 25.0,
                spreadRadius: 2.0,
                offset: Offset(0, -5.0)
                )
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30)
              ),
              color: Colors.white,
            ),
            child:  GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SignUpPage()
                  ),);},
                  child: Text("Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: SizeConfig.blockSizeHorizontal * 8,
                    )),
                ),
          ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _MiddlePageLoginScreen createState() => _MiddlePageLoginScreen();
}

class _MiddlePageLoginScreen extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical * 33,
          child: Form(
            key: _formKey,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Material(
                color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: TextFormField(
                      onSaved: (String value) {_email = value;},
                      validator: (val) => val.isEmpty ? 'Enter an email': null,
                      keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                ),
                  ),
              ),
              Material(
                color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: TextFormField(
                      onSaved: (value) => _password = value,
                      validator: (val) => val.length < 6 ? 'Enter a password 6+ characters long': null,
                    obscureText: true,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                ),
                  ),
              ),
              Material(
                color: Colors.transparent,
                child: FlatButton(
                  child: Text("Forgot Password/Reset Password", style: TextStyle(color: Colors.white),),
                  onPressed: () async {
                    resetPassword(context);
                  },
                ),
              ),
              Padding(padding: EdgeInsets.all(1),),
              Material(
                elevation: 8.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.white,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width / 2,
                  child: Text("Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: SizeConfig.blockSizeHorizontal * 7.5)
                ),
                  onPressed: () async {
                    print("clicked");
                    if(_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                        dynamic result = await _auth.loginUser(
                          email: _email,
                          password: _password,
                          context: context
                        );
                    if(result == null) {
                      print("Could not sign in with those credentials");
                    }
                    }
                  })
              )
            ],
      ),
          ),
    );
  }
}

  Future resetPassword(BuildContext context) {
    final _theFormKey = GlobalKey<FormState>();
    String _theEmail;
    final AuthService _auth = AuthService();

    return showDialog(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        title: Text("Reset Password"),
        content: Container(
          height: SizeConfig.blockSizeVertical * 15,
          child: Column(
            children: <Widget>[
              Text("Enter your Email"),
              Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 1)),
              Form(
                key: _theFormKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Email..."
                  ),
                  onSaved: (value) => _theEmail = value,
                  validator: (val) => val.isEmpty ? 'Enter an email': null,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel", style: TextStyle(color: Colors.green),)
              ),
              FlatButton(
                onPressed: () async {
                  if(_theFormKey.currentState.validate()) {
                    _theFormKey.currentState.save();
                    try {
                      await _auth.resetPassword(_theEmail);
                    }
                    on PlatformException catch (error) {
                      print(error.message);
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: Text("Ok", style: TextStyle(color: Colors.green))
              ),
            ],
          )
        ],)
      );
    }