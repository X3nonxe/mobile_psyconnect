import 'package:flutter/material.dart';
import 'package:psyconnect/screens/onboarding/first_onboard.dart';

class ThirdOnBoard extends StatelessWidget {
  const ThirdOnBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardPage(
      imagePath: "images/doctor3.png",
      text: "Dapatkan konsultasi online\nyang mudah dan nyaman",
    );
  }
}
