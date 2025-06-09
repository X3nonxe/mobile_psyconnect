import 'package:psyconnect/screens/user-screen/psycholog_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ListIcons extends StatelessWidget {
  final String icon;
  final String text;
  final String category;

  const ListIcons({
    super.key,
    required this.icon,
    required this.text,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final double iconContainerSideLength =
        MediaQuery.of(context).size.height * 0.07;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PsychologSearch(selectedCategory: category), // Kirim kategori
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: iconContainerSideLength,
              width: iconContainerSideLength,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    spreadRadius: 1,
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                  )
                ],
                image: DecorationImage(
                  image: AssetImage(icon),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
