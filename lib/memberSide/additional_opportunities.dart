import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sickles_nhs_app/adminSide/view_students.dart';
import 'package:sickles_nhs_app/backend/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class AdditionalOpportunities extends StatelessWidget {

  Future getOppertunities() async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("additionalOppertunites").getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack( 
        children: [
          TopHalfViewStudentsPage(),
          Padding(
            padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 18),
            child: Container(
              width: SizeConfig.blockSizeHorizontal * 100,
              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(000000).withOpacity(0.25),
                    offset: Offset(0, -2),
                    blurRadius: 15,
                    spreadRadius: 5
                  )
                ]
              ),
              child: Container(
                height: SizeConfig.blockSizeVertical * 76,
                child: FutureBuilder(
                  future: getOppertunities(),
                  builder: (_, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                        ),
                      );
                    }
                    else {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: snapshot.data.length,
                        itemBuilder: (_, index) {
                          return theAdditionalOpportunitiesTiles(snapshot.data[index].data['title'], snapshot.data[index].data['description'], snapshot.data[index].data['url']);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget theAdditionalOpportunitiesTiles(String title, String description, String url) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1.5),
      child: Container(
        width: SizeConfig.blockSizeHorizontal * 90,
        child: Card(
          elevation: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: SizeConfig.blockSizeHorizontal * 60,
                child: Column(
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600),),
                    Text(description, textAlign: TextAlign.center,)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 1),
                child: GestureDetector(
                  onTap: () => launch(url),
                  child: Text("More Details", style: TextStyle(decoration: TextDecoration.underline, color: Colors.green),)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}