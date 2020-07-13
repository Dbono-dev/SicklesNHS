import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'dart:io';
import 'package:http/http.dart' show get;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ViewImages extends StatelessWidget {
  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("upload pics").orderBy('dateTime', descending: true).getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TopHalfViewStudentsPage(),
          Padding(padding: EdgeInsets.all(15)),
          Center(
            child: FutureBuilder(
              future: getPosts(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                else {
                  return SizedBox(
                    height: SizeConfig.blockSizeVertical * 74,
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      itemBuilder: (_, index) {
                        return imageCards(context, snapshot.data[index]);
                      }
                    ),
                  );
                }
              }
            )
          )
        ],
      ),
    );
  }

  Widget imageCards(BuildContext context, DocumentSnapshot snapshot) {

    DateTime dateTime = snapshot.data['dateTime'].toDate();
    List theImages = new List();
    theImages = snapshot.data['url'];

    return Container(
      height: 225,
      width: SizeConfig.blockSizeHorizontal * 85,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.green,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("From: " + snapshot.data['name'], style: TextStyle(color: Colors.white)),
                  Spacer(),
                  Text(dateTime.month.toString() + "/" + dateTime.day.toString() + "/" + dateTime.year.toString() + " @ " + dateTime.hour.toString() + ":" + dateTime.minute.toString(), style: TextStyle(color: Colors.white),)
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(10)),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Container(
                width: SizeConfig.blockSizeHorizontal * 85,
                height: 150,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: theImages.length,
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, SizeConfig.blockSizeHorizontal * 2, 0),
                      child: GestureDetector(
                        onLongPress: () async {
                          showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                      icon: Icon(Icons.save_alt, color: Colors.white, size: 45,),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        var response = await get(theImages[i]);
                                        var documentDirectory = await getApplicationDocumentsDirectory();

                                        File file = new File(
                                          join(documentDirectory.path, snapshot.data['name'] + dateTime.month.toString() + "-" + dateTime.day.toString() + "-" + dateTime.year.toString() + '.png')
                                        );

                                        file.writeAsBytesSync(response.bodyBytes);
                                      },
                                    ),
                                  ),
                                  Image.network(
                                    theImages[i],
                                    height: SizeConfig.blockSizeVertical * 80,
                                    width: SizeConfig.blockSizeHorizontal * 80,
                                  ),
                                ],
                              );
                            }
                          );
                        },
                        child: Image.network(
                          theImages[i],
                          fit: BoxFit.fitHeight, height: 180,
                          loadingBuilder:(BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white)
                                ),
                              );
                            },
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}