import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:psyconnect/config/constants.dart';
import 'package:psyconnect/screens/article_page.dart';
import 'package:psyconnect/screens/user-screen/psycholog_search.dart';
import 'package:psyconnect/widgets/article.dart';
import 'package:psyconnect/widgets/banner.dart';
import 'package:psyconnect/widgets/list_icon.dart';
import 'package:psyconnect/widgets/list_psycholog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Common TextStyle for header texts
  TextStyle get headerTextStyle => GoogleFonts.montserrat(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: textColor,
      );

  // Profile section
  Widget _buildProfileSection(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage("lib/icons/profile.png"),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hai, Rohman!",
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Bagaimana",
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 46, 46, 46)),
                ),
                const SizedBox(width: 5),
                DefaultTextStyle(
                  style: const TextStyle(fontSize: 12, color: bluePrimaryColor),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      WavyAnimatedText('Kabarmu'),
                      WavyAnimatedText('Perasaanmu'),
                      WavyAnimatedText('Harimu'),
                    ],
                    repeatForever: true,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  "Hari ini?",
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 46, 46, 46)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Search Field
  Widget _buildSearchField(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: const BoxDecoration(),
        child: TextField(
          textAlign: TextAlign.start,
          textInputAction: TextInputAction.none,
          autofocus: false,
          obscureText: false,
          keyboardType: TextInputType.emailAddress,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            focusColor: Colors.black26,
            fillColor: const Color.fromARGB(255, 247, 247, 247),
            filled: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset("lib/icons/search.png",
                  filterQuality: FilterQuality.high),
            ),
            prefixIconColor: bluePrimaryColor,
            label: const Text("Cari psikolog, artikel, topik..."),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  // Psychologist List Section
  Widget _buildPsychologistList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        height: 180,
        width: 400,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: const [
            ListPsycholog(
              image: "lib/icons/male-doctor.png",
              namaPsikolog: "Ikhwan Baharudin",
              pengalaman: "20 Tahun",
              spesialisasi: "Psikoolog Klinis",
            ),
            ListPsycholog(
              image: "lib/icons/docto3.png",
              namaPsikolog: "Raine Nento",
              pengalaman: "20 Tahun",
              spesialisasi: "Psikoolog Klinis",
            ),
            ListPsycholog(
              image: "lib/icons/doctor2.png",
              namaPsikolog: "Syifa Rahma",
              pengalaman: "20 Tahun",
              spesialisasi: "Psikoolog Klinis",
            ),
          ],
        ),
      ),
    );
  }

  // Article Section
  Widget _buildArticleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Artikel Terkait",
            style: headerTextStyle,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const ArticlePage(),
                ),
              );
            },
            child: Text(
              "Lihat semua",
              style: GoogleFonts.openSans(
                  fontSize: 16.sp, color: bluePrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              alignment: Alignment.bottomCenter,
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.06,
              child: Image.asset("lib/icons/bell.png",
                  filterQuality: FilterQuality.high),
            ),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(top: 20)),
            _buildProfileSection(context),
          ],
        ),
        toolbarHeight: 130,
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildSearchField(context),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListIcons(
                      icon: "lib/icons/stress.png",
                      text: "Klinis",
                      category: "Klinis"),
                  ListIcons(
                      icon: "lib/icons/depresi.png",
                      text: "Anak & Keluarga",
                      category: "Anak & Keluarga"),
                  ListIcons(
                      icon: "lib/icons/trauma.png",
                      text: "Industri & Organisasi",
                      category: "Industri & Organisasi"),
                  ListIcons(
                      icon: "lib/icons/adiksi.png",
                      text: "Lainnya",
                      category: "Lainnya"),
                ],
              ),
              const SizedBox(height: 10),
              const BannerWidget(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Psikolog",
                      style: headerTextStyle,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: PsychologSearch(),
                          ),
                        );
                      },
                      child: Text(
                        "Lihat semua",
                        style: GoogleFonts.openSans(
                            fontSize: 16.sp, color: bluePrimaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildPsychologistList(context),
              const SizedBox(height: 20),
              _buildArticleSection(context),
              const SizedBox(height: 10),
              const Article(
                image: "images/article1.png",
                dateText: "Jun 10, 2021 ",
                duration: "5min read",
                mainText:
                    "Kesehatan Mental dapat dipengaruhi oleh berbagai faktor",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
