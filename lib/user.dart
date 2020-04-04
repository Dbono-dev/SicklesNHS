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

  UserData({this.uid, this.firstName, this.lastName, this.grade, this.permissions, this.date});
}