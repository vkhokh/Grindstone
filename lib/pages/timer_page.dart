import 'package:flutter/material.dart';
import 'dart:async';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  static const Duration countDownDuration = Duration(seconds: 1);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier<Duration>(
    countDownDuration,
  );
  Timer? timer;
  @override
  void initState() {
    super.initState();
    //startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    durationNotifier.dispose();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final seconds = durationNotifier.value.inSeconds - 1;
    if (seconds < 0) {
      timer?.cancel();
      // showEndMessage();
    } else {
      durationNotifier.value = Duration(seconds: seconds);
    }
  }

  Widget buildTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // buildTimeColumn(hours, "Hrs"),
        // buildTimeColumn(minutes, "Mins"),
        // buildTimeColumn(seconds, "Secs", isLast: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
