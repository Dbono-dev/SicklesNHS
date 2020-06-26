import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';

class PDFScreen extends StatelessWidget {

  String title = "";
  String pdfPath;
  String pdfUrl;
  PDFScreen(this.title, this.pdfPath, this.pdfUrl);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.of(context).pop();
          }
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(title, style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save_alt, color: Colors.white,),
            onPressed: () {},
          )
        ],
      ),
      path: pdfPath,
    );
  }
}