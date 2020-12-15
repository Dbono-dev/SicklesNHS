class User {
  final String uid;

  User({this.uid});
}

class UserData {
  final String uid;
  final String firstName;
  final String lastName;
  final String grade;
  final int permissions;
  final String date;
  final double hours;
  var firstQuarter;
  var secondQuarter;
  var thirdQuarter;
  var fourthQuarter;
  final int numClub;
  var eventTitleSignedUp;
  final int numOfCommunityServiceEvents;
  var dues;

  UserData({this.uid, this.firstName, this.lastName, this.grade, this.permissions, this.date, this.hours, this.firstQuarter, this.secondQuarter, this.thirdQuarter, this.fourthQuarter, this.numClub, this.eventTitleSignedUp, this.numOfCommunityServiceEvents, this.dues});
}