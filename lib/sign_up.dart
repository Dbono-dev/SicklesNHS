import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/auth_service.dart';
import 'package:sickles_nhs_app/login_screen.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage ({Key key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SingleChildScrollView(
        child: Container(
          height: SizeConfig.blockSizeVertical * 100,
          child: Column(
            children: <Widget>[
              TopHalfLoginPage(),
              Padding(padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 7.5)),
              Expanded(child: MiddlePageSignUpScreen()),
            ],
          ),
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
      color: Colors.transparent,
        child: Form(
        key: _secondformKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  color: Colors.transparent,
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: TextFormField(
                        onSaved: (value) => _firstName = value,
                        validator: (val) => val.isEmpty ? 'Enter an First Name' : null,
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          hintText: "First Name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: TextFormField(
                        onSaved: (value) => _lastName = value,
                        validator: (val) => val.isEmpty ? 'Enter your Last Name' : null,
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          hintText: "Last Name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(5),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  color: Colors.transparent,
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (value) => _studentNum = value,
                        validator: (val) => val.isEmpty ? 'Enter your Student Number' : null,
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          hintText: "Student Number",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal * 40,
                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (value) => _grade = value,
                        validator: (val) => val.isEmpty ? 'Enter a grade' : null,
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          hintText: "Grade",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                    ),
                  ),
                ),
              ],
            ),  
            Padding(padding: EdgeInsets.all(5),),          
            Material(
              color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => _email = value,
                    validator: (val) => val.isEmpty ? 'Enter an email' : null,
                  style: TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                    validator: (val) => val.isEmpty ? 'Enter a Password' : null,
                  style: TextStyle(fontSize: 15),
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    hintText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
              ),
                ),
            ),
            Padding(padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),),
            GestureDetector(
              onTap: () async {
                print("clicked");
                final form = _secondformKey.currentState;
                form.save();
                if(form.validate()) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Signing up...", style: TextStyle(color: Colors.green),),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.white,
                  ));
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
                /*Navigator.push(context, MaterialPageRoute(
                builder: (context) => LoginScreen()),);*/
              },
              child: Card(
                elevation: 10,
                child: Container(
                  height: SizeConfig.blockSizeVertical * 6,
                  width: SizeConfig.blockSizeHorizontal * 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white
                  ),
                  child: Center(child: Text("SIGN UP", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20), )),
                ),
              )
            ),
            Spacer(),
            Material(
              type: MaterialType.transparency,
              child: Container(
              height: SizeConfig.blockSizeVertical * 7,
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
                  FlatButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text("BACK", style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.green
                    )),
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