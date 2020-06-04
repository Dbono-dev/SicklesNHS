import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CurrentQuarter {
  DateTime date;

  CurrentQuarter(this.date);

  DateTime startOfFirstQuarter;
  DateTime firstQuarter;
  DateTime secondQuarter;
  DateTime thirdQuarter;
  DateTime fourthQuarter;

  Future<String> currentQuarter() async {
    DateFormat _format = new DateFormat("MM-dd-yyyy");
    
    Future getQuarterDate(String documentName) async {
      DateTime temp;
      var document = Firestore.instance.collection("Important Dates").document(documentName);
      await document.get().then((DocumentSnapshot snapshot) =>
        temp = _format.parse(snapshot.data['date'].toString()));
      return temp;
    }

    startOfFirstQuarter = await getQuarterDate("endOfQuarterStart of School");
    firstQuarter = await getQuarterDate("endOfQuarterFirst");
    secondQuarter = await getQuarterDate("endOfQuarterSecond");
    thirdQuarter = await getQuarterDate("endOfQuarterThird");
    fourthQuarter = await getQuarterDate("endOfQuarterFourth");

    DateTime currentDate = DateTime.now();

    if(currentDate.isAfter(startOfFirstQuarter) && currentDate.isBefore(firstQuarter))
      return "firstQuarter";
    if(currentDate.isAfter(firstQuarter) && currentDate.isBefore(secondQuarter))
      return "secondQuarter";
    if(currentDate.isAfter(secondQuarter) && currentDate.isBefore(thirdQuarter))
      return "thirdQuarter";
    if(currentDate.isAfter(thirdQuarter) && currentDate.isBefore(fourthQuarter))
      return "fourthQuarter";
    else
      return "fourthQuarter";
  }

  Future<String> getQuarter() async {
    await currentQuarter();

    if(date.isAfter(startOfFirstQuarter) && date.isBefore(firstQuarter))
      return "firstQuarter";
    if(date.isAfter(firstQuarter) && date.isBefore(secondQuarter))
      return "secondQuarter";
    if(date.isAfter(secondQuarter) && date.isBefore(thirdQuarter))
      return "thirdQuarter";
    if(date.isAfter(thirdQuarter) && date.isBefore(fourthQuarter))
      return "fourthQuarter";
    else
      return "fourthQuarter";
  }
}