import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyconnect/screens/user-screen/psycholog_details_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PsychologList extends StatelessWidget {
  final String image;
  final String namaPsikolog;
  final String spesialisasi;
  final String harga;
  final String psychologId;

  const PsychologList({
    super.key,
    required this.harga,
    required this.image,
    required this.namaPsikolog,
    required this.spesialisasi,
    required this.psychologId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PsychologDetails(
                  psychologId: psychologId,
                ),
              ),
            );
          },
          child: Container(
            height: 14.h, // Menggunakan responsive_sizer
            width: 90.w, // Menggunakan responsive_sizer
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: const Color.fromARGB(255, 226, 226, 226)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                //Doctor image Container
                Container(
                  height: 12.h, // Menggunakan responsive_sizer
                  width: 24.w, // Menggunakan responsive_sizer
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                          image: AssetImage(image),
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.contain)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 12.h, // Menggunakan responsive_sizer
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaPsikolog,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          spesialisasi,
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              harga,
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color:
                                      const Color.fromARGB(255, 133, 133, 133),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
