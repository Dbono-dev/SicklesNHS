import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sickles_nhs_app/backend/user.dart';

class DatabaseService {

  final String uid;
  
  DatabaseService({this.uid});

  final CollectionReference memberCollection = Firestore.instance.collection('members');

  Future updateUserData(String firstName, String lastName, String studentNum, String grade, String uid, String permissions) async {
    return await memberCollection.document(uid).setData({
      'first name': firstName,
      'last name': lastName,
      'hours': 0,
      'student number': studentNum,
      'grade': grade,
      'permissions': int.parse(permissions),
      'date': "5/20/21",
      'uid': uid,
      'event title': "",
      'event date': "",
      'event hours': "",
      'firstQuarter': 0,
      'secondQuarter': 0,
      'thirdQuarter': 0,
      'fourthQuarter': 0
    });
  }

  Future updateUserPermissions(int permissions, String date) async {
    return await memberCollection.document(uid).updateData({
      'permissions': permissions,
      'date': date
    });
  }

  Future updateHoursRequest(int hours, int currentHours) async {
    return await memberCollection.document(uid).updateData({
      'hours': currentHours + hours
    });
  }

  Future updateHoursByQuarter(int hours, int currentHours, String quarter) async {
    try{
      return await memberCollection.document(uid).updateData({
        quarter: currentHours + hours
      });
    }
    catch (e) {
      return await memberCollection.document(uid).updateData({
        quarter: hours
      });
    }
  }

  Future updateCompetedEvents(List title, List date, List hours) async {
    return await memberCollection.document(uid).updateData({
      'event title': title,
      'event date': date,
      'event hours': hours
    });
  }
  

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      firstName: snapshot.data['first name'],
      lastName: snapshot.data['last name'],
      grade: snapshot.data['grade'],
      permissions: snapshot.data['permissions'],
      hours: snapshot.data['hours'],
      firstQuarter: snapshot.data['firstQuarter'],
      secondQuarter: snapshot.data['secondQuarter'],
      thirdQuarter: snapshot.data['thirdQuarter'],
      fourthQuarter: snapshot.data['fourthQuarter']
    );
  }

  Stream<UserData> get userData {
    return memberCollection.document(uid).snapshots()
    .map(_userDataFromSnapshot);
  }

}

class DatabaseEvent {
  DatabaseEvent();

  final CollectionReference eventsCollection = Firestore.instance.collection('events');

 Future updateEvents(String title, String description, int startTime, int endTime, String date, var photoUrl, String maxParticipates, String address, String type, int startTimeMinutes, int endTimeMinutes) async {
    return await eventsCollection.document(title).setData({
      'title': title,
      'description': description,
      'start time': startTime,
      'end time': endTime,
      'date': date,
      'photo url': photoUrl,
      'max participates': maxParticipates,
      'address': address,
      'type': type,
      'participates': [],
      'participates dates': [],
      'start time minutes': startTimeMinutes,
      'end time minutes': endTimeMinutes,
    });
  }

  Future updateEvent(var participate, String title, var participateDate) async {
    return await eventsCollection.document(title).updateData({
      'participates': participate,
      'participates dates': participateDate
    });
  }
}

class DatabaseSubmitHours {
  DatabaseSubmitHours();

  final CollectionReference submitHours = Firestore.instance.collection('Approving Hours');

 Future updateSubmitHours(String type, String location, String hours, String nameOfSup, String supPhone, String emailSup, String date, String name, bool complete, var url, String uid, int currentHours) async {
    return await submitHours.document(type).setData({
      'type': type,
      'location': location,
      'hours': hours,
      'name of supervisor': nameOfSup,
      'supervisor phone number': supPhone,
      'supervisor email': emailSup,
      'date': date,
      'name': name, 
      'complete': complete,
      'url': url,
      'uid': uid,
      'current hours': hours
    });
  }

  Future updateCompleteness(String type, bool complete) async {
    return await submitHours.document(type).updateData({
      'complete': complete
    });
  }

  Future deleteCompleteness(String type) async {
    return await submitHours.document(type).delete();
  }
}

class DatabaseImportantDates {
  DatabaseImportantDates();

  final CollectionReference submitHours = Firestore.instance.collection('Important Dates');

 Future setImportantDates(String type, String date) async {
    return await submitHours.document(type + date).setData({
      'type': type,
      'date': date,
      'inital date': date
    });
  }

  Future updateImportantDates(String type, String oldDate, String newDate) async {
    return await submitHours.document(type + oldDate).updateData({
      'date': newDate
    });
  }

  Future deleteImportantDates(String type, String date) async {
    return await submitHours.document(type + date).delete();
  }

  Future setEndOfQuarter(String type, String date, String quarter) async {
    try{
      return await submitHours.document(type + quarter).updateData({
        'type': type,
        'date': date,
        'quarter': quarter
      });
    }
    catch(e) {
      return await submitHours.document(type + quarter).setData({
        'type': type,
        'date': date,
        'quarter': quarter
      });
    }
  }
}

class DatabaseBugs {
  DatabaseBugs();

  final CollectionReference submitBugs = Firestore.instance.collection("bugs");

  Future submmissionBugs(String summary) async {
    return await submitBugs.document(summary.substring(0, 5)).setData({
      'summary': summary
    });
  }
}

class DatabaseQRCodeHours {
  DatabaseQRCodeHours();

  final CollectionReference qrCodeHours = Firestore.instance.collection("DatabaseQRCodeHours");

  Future submitPreHours(String name, String title, String time, String type) async {
    return await qrCodeHours.document(name + "-" + title).setData({
      'title': title,
      'name': name,
      'time': time,
      'type': type
    });
  }

  Future deleteDoc(String name, String title) async {
    return await qrCodeHours.document(name + "-" + title).delete();
  }

}