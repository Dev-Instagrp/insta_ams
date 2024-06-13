import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: StreamBuilder<DateTime>(
        stream: Stream.periodic(
            const Duration(seconds: 1), (_) => DateTime.now()),
        builder: (context, snapshot) {
          String timeString =
          DateFormat.jm().format(snapshot.data ?? DateTime.now());
          return Text(
            timeString,
            style: const TextStyle(fontSize: 36),
          );
        },
      ),
    );
  }
}

///Mustkeem Baraskar 2024
