import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChatPsycholog extends StatelessWidget {
  final String name;
  final String timeAgo;
  final String imagePath;

  const ChatPsycholog({
    super.key,
    required this.name,
    required this.timeAgo,
    this.imagePath = "lib/icons/male-doctor.png",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile picture
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Psychologist information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.openSans(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 41, 41, 41),
                ),
              ),
              Text(
                timeAgo,
                style: GoogleFonts.openSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 92, 92, 92),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
