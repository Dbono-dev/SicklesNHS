class Event {
  final String title;
  final String description;
  final String date;
  final int startTime;
  final int startTimeMinutes;
  final int endTime;
  final int endTimeMinutes;
  final String address;
  final String maxParticipates;
  final String photoUrl;
  final String type;
  var participates;
  var participatesDates;
  final String oldTitle;

  Event({this.title, this.description, this.date, this.startTime, this.startTimeMinutes, this.endTime, this.endTimeMinutes, this.address, this.maxParticipates, this.photoUrl, this.type, this.oldTitle});
}