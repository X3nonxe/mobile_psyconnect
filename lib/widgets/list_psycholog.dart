import 'package:psyconnect/config/color_pallate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ListPsycholog extends StatelessWidget {
  final String image;
  final String namaPsikolog;
  final String spesialisasi;
  final String pengalaman;
  // final String harga;

  const ListPsycholog(
      {super.key,
      // required this.harga,
      required this.image,
      required this.namaPsikolog,
      required this.pengalaman,
      required this.spesialisasi});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromARGB(134, 228, 227, 227)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15,
            ),
            Center(
              child: Container(
                alignment: Alignment.topCenter,
                height: 80,
                width: 100,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(image),
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.cover),
                    shape: BoxShape.circle),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  //Main text
                  Text(
                    namaPsikolog,
                    style: GoogleFonts.openSans(
                        fontSize: 13.sp, fontWeight: FontWeight.bold),
                  ),
                  //Sub text
                  Text(
                    spesialisasi,
                    style: GoogleFonts.openSans(
                        fontSize: 11.sp,
                        color: Colors.black45,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //Rating star container start from here!!
                  Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.01500,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: const Color.fromARGB(255, 240, 236, 236),
                        child: Row(children: [
                          Container(
                            height:
                                MediaQuery.of(context).size.height * 0.01500,
                            width: MediaQuery.of(context).size.width * 0.03,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                      "lib/icons/exp.png",
                                    ),
                                    filterQuality: FilterQuality.high)),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            pengalaman,
                            style: GoogleFonts.openSans(
                                fontSize: 11.sp,
                                color: bluePrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                      ),
                      //Sizebox betwen ratting + distance
                      // const SizedBox(
                      //   width: 15,
                      // ),
                      // Text(
                      //   harga,
                      //   style: GoogleFonts.poppins(
                      //       fontSize: 11.sp,
                      //       color: const Color.fromARGB(255, 133, 133, 133),
                      //       fontWeight: FontWeight.bold),
                      // ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
