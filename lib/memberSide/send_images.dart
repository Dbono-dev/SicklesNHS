import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:sickles_nhs_app/backend/database.dart';

class SendImages extends StatefulWidget {

  SendImages({this.name});

  final String name;

  @override
  _SendImagesState createState() => _SendImagesState();
}

class _SendImagesState extends State<SendImages> {
  StorageReference firebaseStorageRef;

  List<File> theImages = new List<File>();

  Future getImage() async {
    var tempImage = await ImagePicker().getImage(source: ImageSource.gallery);
    File theFile = File(tempImage.path);
    print(tempImage.path);
    setState(() {
      theImages.add(theFile);
    });
  }

  Future sendImages() async {
    List theImagesUrl = new List();
    for(int i = 0; i < theImages.length; i++) {
      firebaseStorageRef = FirebaseStorage.instance.ref().child(widget.name + DateTime.now().toString());
      final StorageUploadTask task = firebaseStorageRef.putFile(theImages[i]);

      var test = await (await task.onComplete).ref.getDownloadURL();
      theImagesUrl.add(test.toString());
    }
    await UploadedPictures().addPics(theImagesUrl, widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TopHalfViewStudentsPage(),
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                height: 475,
                width: SizeConfig.blockSizeHorizontal * 85,
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(5)),
                    FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.green,
                        onPressed: () async {
                          await getImage();
                        },
                        child: Text("Add Images", style: TextStyle(color: Colors.white),)
                      ),
                      Padding(padding: EdgeInsets.all(15)),
                      theImages.length == 0 ? Center(child: Text("NO IMAGES", style: TextStyle(color: Colors.green, fontSize: 35))) : SizedBox(
                        height: 375,
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: theImages.length,
                          itemBuilder: (_, i) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                              child: Image.file(theImages[i], height: 150,),
                            );
                          }
                        ),
                      )
                  ],
                )
              ),
            ),
          ),
          Spacer(),
          Material(
            type: MaterialType.transparency,
            child: Container(
            height: SizeConfig.blockSizeVertical * 7.316,
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
                FlatButton(
                  onPressed: () async {
                    await sendImages();
                    setState(() {
                      theImages.clear();
                    });
                  },
                    child: Text("Send Images", style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  )),
                ),
              ],
            ),
          ),
          )
        ],
      ),
    );
  }
}