import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/backend/database.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/globals.dart' as global;

class AddParticipants extends StatefulWidget {

  AddParticipants({this.post});

  final DocumentSnapshot post;

  @override
  _AddParticipantsState createState() => _AddParticipantsState();
}

class _AddParticipantsState extends State<AddParticipants> {

  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("members").orderBy('last name').getDocuments();
    return qn.documents;
  }

  String search = "";

  @override
  Widget build(BuildContext context) {
    
    print(search);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 5)),
          Container(
            width: SizeConfig.blockSizeHorizontal * 100,
            height: SizeConfig.blockSizeVertical * 7,
            child: Card(
              elevation: 10,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back),
                  ),
                  Container(
                    width: SizeConfig.blockSizeHorizontal * 72.5,
                    height: SizeConfig.blockSizeVertical * 7,
                    child: TextFormField(
                      initialValue: search,
                      decoration: InputDecoration(border: InputBorder.none),
                      onChanged: (val) {
                        setState(() {
                          search = val;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        search = "";
                      });
                    },
                    icon: Icon(Icons.close)
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Expanded(
              child: FutureBuilder(
                future: getPosts(),
                builder: (_, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.green)
                    )
                  );
                }
                else {
                  return Material(
                    child: Container(
                      height: SizeConfig.blockSizeVertical * 59,
                      width: SizeConfig.blockSizeHorizontal * 100,
                      child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (_, index) {
                          if(search != "") {
                            if(snapshot.data[index].data['first name'].toString().contains(search) || snapshot.data[index].data['last name'].toString().contains(search) || (snapshot.data[index].data["first name"] + " " + snapshot.data[index].data["last name"]).toString().contains(search)) {
                              return personCards(snapshot.data[index].data['first name'] + " " + snapshot.data[index].data['last name'], snapshot.data[index]);
                            }
                            else {
                              return Container();
                            }
                          }
                          else {
                            return personCards(snapshot.data[index].data['first name'] + " " + snapshot.data[index].data['last name'], snapshot.data[index]);
                          }
                        }
                      )
                    )
                  );
                }
                }),
            ),
          )
        ],
      ),
    );
  }

  Widget personCards(String name, DocumentSnapshot snapshot) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1),
      width: SizeConfig.blockSizeHorizontal * 90,
      height: SizeConfig.blockSizeVertical * 7,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Confirmation"),
                content: Text("Are you sure you would like to add " + name + " to this event?"),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("CANCEL", style: TextStyle(color: Colors.red),),
                  ),
                  FlatButton(
                    onPressed: () {
                      var participates = widget.post.data['participates'];
                      var participateDate = widget.post.data['participates dates'];
                      participates.add(snapshot.data['first name'] + " " + snapshot.data['last name']);
                      participateDate.add(global.shownDate);
                      DatabaseEvent().updateEvent(participates, widget.post["title"], participateDate);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text("CONFIRM", style: TextStyle(color: Colors.green),),
                  ),
                ],
              );
            }
          );
        },
        child: Card(
          elevation: 6,
          child: Center(child: Text(name, textAlign: TextAlign.left, style: TextStyle(fontSize: 20),))
        ),
      ),
    );
  }
}