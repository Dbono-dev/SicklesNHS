import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/push_notification.dart';
import 'package:sickles_nhs_app/size_config.dart';
import 'package:sickles_nhs_app/view_students.dart';

class Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
          children: <Widget> [
            TopHalfViewStudentsPage(),
            Padding(padding: EdgeInsets.all(20)),
            MiddlePageNotification(),
          ]
        )
    );
  }
}

class MiddlePageNotification extends StatefulWidget {
  @override
  _MiddlePageNotificationState createState() => _MiddlePageNotificationState();
}

class _MiddlePageNotificationState extends State<MiddlePageNotification> {

  void intState() {
    PushNotificationService().initialise();
  }

  final _fourthformKey = GlobalKey<FormState>();
  String _title;
  String _body;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical * 74.1,
      child: Material(
        child: Form(
          key: _fourthformKey,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextFormField(
                    onSaved: (value) => _title = value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      hintText: "Title"
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(0)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextFormField(
                    onSaved: (value) => _body = value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      hintText: "Body of Message"
                    ),
                    maxLines: 6,
                    minLines: 3,
                  ),
                ),
              ),
              
              Spacer(),
              Material(
                type: MaterialType.transparency,
                child: Container(
                height: 49.0,
                width: SizeConfig.blockSizeHorizontal * 100,
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
                  color: Colors.green,
                ),
                child: GestureDetector(
                      onTap: () async {
                        _fourthformKey.currentState.save();
                        sendMessage(_title, _body);
                        print("works");
                        _fourthformKey.currentState.reset();
                      },
                    child: Center(
                      child: Text("Send", style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                      )),
                          ),
                        ),
                ))
            ],
          )
        ),
      ),
    );
  }

  Future sendMessage(String title, String body) async {
    await PushNotificationService().sendAndRetrieveMessage(title, body);
  }
}
