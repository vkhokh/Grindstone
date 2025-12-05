class Timer {
  final int hours;
  final int minutes;
  final int seconds;

  Timer({required this.hours, required this.minutes, required this.seconds});

  Map<String, dynamic> toJson() {
    return {'hours': hours, 'minutes': minutes, 'seconds': seconds};
  }

  static Timer fromJson(Map<String, dynamic> json) {
    return Timer(
      hours: json['hours'],
      minutes: json['minutes'],
      seconds: json['seconds'],
    );
  }

  @override
  String toString() {
    String hours_ = hours.toString().padLeft(0, '2');
    String minutes_ = minutes.toString().padLeft(2, '0');
    String seconds_ = seconds.toString().padLeft(2, '0');
    return "$hours_:$minutes_:$seconds_";
  }
}
