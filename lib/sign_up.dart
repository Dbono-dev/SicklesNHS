import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/auth_service.dart';
import 'package:sickles_nhs_app/login_screen.dart';
import 'package:sickles_nhs_app/size_config.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage ({Key key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return Stack (
      children: <Widget> [
        Container(
          height: SizeConfig.blockSizeHorizontal * 100,
          width: SizeConfig.blockSizeVertical * 100,
          color: Colors.green,
        ),
        Column(
          children: <Widget>[
            TopHalfSignUpPage(),
            MiddlePageSignUpScreen(),
          ],
        )
      ]
    );
  }
}

class TopHalfSignUpPage extends StatelessWidget {
  TopHalfSignUpPage({Key key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
            type: MaterialType.transparency,
            child: Container(
            height: SizeConfig.blockSizeVertical * 20,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                color: Colors.green,
                blurRadius: 25.0,
                spreadRadius: 2.0,
                offset: Offset(0, -10.0)
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


class MiddlePageSignUpScreen extends StatelessWidget {
  MiddlePageSignUpScreen({Key key}) : super (key: key);

  String _firstName;
  String _lastName;
  String _email;
  String _password;
  String _studentNum;
  String _grade;
  final _secondformKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService(); 

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      height: SizeConfig.blockSizeVertical * 80,
        child: Form(
        key: _secondformKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(5)),
            Material(
              color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: TextFormField(
                    onSaved: (value) => _firstName = value,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "First Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
              ),
                ),
            ),
            Padding(padding: EdgeInsets.all(5),),
            Material(
              color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: TextFormField(
                    onSaved: (value) => _lastName = value,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "Last Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
              ),
                ),
            ),
            Padding(padding: EdgeInsets.all(5),),
            Material(
              color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: TextFormField(
                    onSaved: (value) => _studentNum = value,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "Student Number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
              ),
                ),
            ),
            Padding(padding: EdgeInsets.all(5),),
            Material(
              color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: TextFormField(
                    onSaved: (value) => _grade = value,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "Grade",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
              ),
                ),
            ),
            Padding(padding: EdgeInsets.all(5),),
            Material(
              color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: TextFormField(
                    onSaved: (value) => _email = value,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
              ),
                ),
            ),
            Padding(padding: EdgeInsets.all(5),),
            Material(
              color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: TextFormField(
                    onSaved: (value) => _password = value,
                  style: TextStyle(fontSize: 20),
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
              ),
                ),
            ),
            //Padding(padding: EdgeInsets.all(10),),
            Spacer(),
            Material(
              type: MaterialType.transparency,
              child: Container(
              height: 49.0,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                      builder: (context) => LoginScreen()
                    ),
                    );
                    },
                      child: FlatButton(
                        onPressed: () async {
                          print("clicked");
                          final form = _secondformKey.currentState;
                          form.save();
                          if(form.validate()) {
                            try {
                              dynamic result = await _auth.createUser(
                                email: _email,
                                password: _password,
                                firstName: _firstName,
                                lastName: _lastName,
                                studentNum: _studentNum,
                                grade: _grade,
                              );
                              print("Works");
                            }
                            on AuthException catch (error) {
                            return _buildErrorDialog(context, error.message);
                            } on Exception catch (error) {
                            return _buildErrorDialog(context, error.toString());
                          }
                          }
                          Navigator.push(context, MaterialPageRoute(
                          builder: (context) => LoginScreen()),);
                        },
                        child: Text("Sign Up", style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    )),
                      ),
                  ),
                ],
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}


Future _buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Error Message'),
          content: Text("Please fill in all of the fields"),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }