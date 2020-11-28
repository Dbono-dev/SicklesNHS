import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget> [
          TopHalfViewStudentsPage(),
          Padding(padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 3)),
          Expanded(child: SettingsPageBody())
        ]
      ),
    );
  }
}

class SettingsPageBody extends StatelessWidget {
  String _summary;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          settingsTiles(context, "Reset Password", resetPassword(context)),
          Padding(padding: EdgeInsets.all(5)),
          settingsTiles(context, "Report a Bug", reportBug(context)),
          Padding(padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 2)),
          Text("Follow Us", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 35, decoration: TextDecoration.underline), textAlign: TextAlign.center,),
          Padding(padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Ink(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [Color.fromARGB(255, 76, 104, 215), Color.fromARGB(255, 138, 58, 185), Color.fromARGB(255, 188, 42, 141), Color.fromARGB(255, 205, 72, 107), Color.fromARGB(255, 233, 89, 80), Color.fromARGB(255, 251, 173, 80), Color.fromARGB(255, 252, 204, 99)],
                        begin: Alignment.topLeft,
                        end: Alignment(0, 1),
                      ),
                    ),
                    child: Center(child: FaIcon(FontAwesomeIcons.instagram))
                  ),
                ), 
                iconSize: 55,
                color: Colors.white,
                onPressed: () => launch('https://www.instagram.com/sicklesnhs/?hl=en')
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.twitter), 
                color: Color.fromARGB(255, 29, 161, 242),
                iconSize: 55,
                onPressed: () => launch('https://twitter.com/SicklesNhs')
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 15,
                height: SizeConfig.blockSizeVertical * 15,
                child: GestureDetector(
                  onTap: () => launch('https://sdhc.instructure.com/courses/209936'),
                  child: Image.asset("CanvasLogo.png")
                )
              )
            ],
          )
        ],
      ),
    );
  }

  Widget settingsTiles(BuildContext context, String text, Future<dynamic> theFuntion) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          resetPassword(context);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
          child: Card(
            color: Colors.white,
            elevation: 10,
            child: ListTile(title: Text("Reset Password")),
          ),
        ),
      ),
    );
  }

  Future reportBug(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 75, 10, 75),
          child: AlertDialog(
            elevation: 10,
            content: Column(
              children: <Widget> [
                Text("Report a Bug"),
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: TextFormField(
                      minLines: 10,
                      maxLines: 20,
                      onSaved: (val) => _summary = val ,
                      decoration: InputDecoration(
                        hintText: "Type a summary of the bug you found here...",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)
                        )
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("CANCEL")
                    ),
                    FlatButton(
                      onPressed: () async {
                        dynamic result;
                        _formKey.currentState.save();
                        try {
                          result = sendBugToDatabase(_summary);
                          dynamic result2 = sendBugToEmail(_summary);
                        }
                        catch (e) {
                          print(e);
                        }
                        if(result != null) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text("SUBMIT")
                    )
                  ],
                )
              ]
            ),
          ),
        );
      }
    );
  }

  Future sendBugToDatabase(String _summary) async {
    await DatabaseBugs().submmissionBugs(_summary);
  }

  Future sendBugToEmail(String _summary) async {
    String userName = "dbosports2";
    String password = "Dbo7030217";

    final smtpServer = gmail(userName, password);

    final message = Message()
    ..from = Address(userName, 'Sickles NHS Developer')
    ..recipients.add('dylanrbono@gmail.com')
    ..subject = 'A New Bug Report'
    ..text = _summary;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
    }
  }
}