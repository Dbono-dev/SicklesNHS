class Event {
  final String title;
  final String date;
  final String image;
  final String description;
  final String address;
  final String startTime;
  final String endTime;

  Event(this.title, this.date, this.image, this.description, this.address, this.startTime, this.endTime);

  static List<Event> getEvents() {
    List<Event> items = <Event>[];

    items.add(Event(
      "Service Event 1",
      "2020-02-10",
      "",
      "A longer description goes here for Service Event 1",
      "Location/Address",
      "5",
      "8"
    ));

    items.add(Event(
      "Service Event 2",
      "2020-02-10",
      "",
      "A longer description goes here for Service Event 2",
      "Location/Address",
      "8",
      "10"
    ));

    items.add(Event(
      "Service Event 3",
      "2020-02-10",
      "",
      "A longer description goes here for Service Event 3",
      "Location/Address",
      "3",
      "10"
    ));

    items.add(Event(
      "Service Event 4",
      "2020-02-10",
      "",
      "A longer description goes here for Service Event 4",
      "Location/Address",
      "10",
      "11"
    ));

    return items;
  }
}