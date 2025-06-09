import 'package:psyconnect/config/color_pallate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SecheduleCard extends StatelessWidget {
  final String mainText;
  final String subText;
  final String image;
  final String date;
  final String time;
  final String confirmation;

  const SecheduleCard(
      {super.key,
      required this.mainText,
      required this.subText,
      required this.date,
      required this.confirmation,
      required this.time,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 90.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mainText,
                          style: GoogleFonts.montserrat(
                              fontSize: 16.sp, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          subText,
                          style: GoogleFonts.openSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 99, 99, 99)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.sp),
                  Container(
                    height: 50.sp,
                    width: 50.sp,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(image),
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover)),
                  ),
                ],
              ),
              SizedBox(height: 12.sp),
              Row(
                children: [
                  Image.asset(
                    "lib/icons/callender2.png",
                    height: 14.sp,
                    width: 14.sp,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(width: 4.sp),
                  Text(
                    date,
                    style: GoogleFonts.openSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 99, 99, 99)),
                  ),
                  SizedBox(width: 10.sp),
                  Image.asset(
                    "lib/icons/watch.png",
                    height: 14.sp,
                    width: 14.sp,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(width: 4.sp),
                  Text(
                    time,
                    style: GoogleFonts.openSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 99, 99, 99)),
                  ),
                  SizedBox(width: 10.sp),
                  Image.asset(
                    "lib/icons/elips.png",
                    height: 14.sp,
                    width: 14.sp,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(width: 4.sp),
                  Text(
                    confirmation,
                    style: GoogleFonts.openSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 99, 99, 99)),
                  ),
                ],
              ),
              SizedBox(height: 16.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 232, 233, 233),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                      ),
                      child: Text(
                        "Batalkan",
                        style: GoogleFonts.openSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 61, 61, 61)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: bluePrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                      ),
                      child: Text(
                        "Jadwalkan Ulang",
                        style: GoogleFonts.openSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
