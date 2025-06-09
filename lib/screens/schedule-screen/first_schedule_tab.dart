import 'package:psyconnect/widgets/schedule_card.dart';
import 'package:flutter/material.dart';

class FirstScheduleTab extends StatelessWidget {
  const FirstScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        SizedBox(
          height: 30,
        ),
        SecheduleCard(
          confirmation: "Terkonfirmasi",
          mainText: "Ratih Perbatasari, S.Psi., Psikolog",
          subText: "Psikolog Klinis",
          date: "26/06/2024",
          time: "10:30 AM",
          image: "lib/icons/male-doctor.png",
        )
      ]),
    );
  }
}
