import 'package:flutter/material.dart';
import 'package:psyconnect/screens/onboarding/first_onboard.dart';

class SecondOnBoard extends StatelessWidget {
  const SecondOnBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardPage(
      imagePath: "images/doctor2.png",
      text: "Cari banyak psikolog spesialis dalam satu aplikasi",
    );
  }
}
