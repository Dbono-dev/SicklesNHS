import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sickles_nhs_app/user.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  final CollectionReference memberCollection = Firestore.instance.collection('members');

  Future updateUserData(String firstName, String lastName, String hours, String studentNum, String grade) async {
    return await memberCollection.document(uid).setData({
      'first name': firstName,
      'last name': lastName,
      'hours': hours,
      'student number': studentNum,
      'grade': grade,
      'permissions': 2,
      'date': "5/20/21"
    });
  }

  Future updateUserPermissions(int permissions, String date) async {
    return await memberCollection.document(uid).updateData({
      'permissions': permissions,
      'date': date
    });
  }

  Future updateCompetedEvents(List<String> newEvent) async {
    return await memberCollection.document(uid).updateData({
      'completed events': newEvent,
    });
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      firstName: snapshot.data['first name'],
      lastName: snapshot.data['last name'],
      grade: snapshot.data['grade'],
      permissions: snapshot.data['permissions']
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

 Future updateEvents(String title, String description, int startTime, int endTime, String date, String photoUrl, String maxParticipates, String address, String type, int startTimeMinutes, int endTimeMinutes) async {
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
      'start time minutes': startTimeMinutes,
      'end time minutes': endTimeMinutes,
    });
  }

  Future updateEvent(var participate, String title) async {
    return await eventsCollection.document(title).updateData({
      'participates': participate,
    });
  }
}

class DatabaseSubmitHours {
  DatabaseSubmitHours();

  final CollectionReference submitHours = Firestore.instance.collection('Approving Hours');

 Future updateSubmitHours(String type, String location, String hours, String nameOfSup, String supPhone, String emailSup, String date, String name, bool complete, var url) async {
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
      'url': url
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
}