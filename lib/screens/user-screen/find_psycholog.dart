import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:psyconnect/screens/user-screen/psycholog_details_screen.dart';
import 'package:psyconnect/widgets/list_icon.dart';
import 'package:psyconnect/widgets/psycholog_list.dart';

class FindPsycholog extends StatelessWidget {
  const FindPsycholog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSearchBar(context),
              const SizedBox(height: 20),
              _buildSectionTitle("Top Psikolog"),
              const SizedBox(height: 20),
              _buildCategoryList(),
              const SizedBox(height: 20),
              _buildSectionTitle("Rekomendasi Psikolog"),
              const SizedBox(height: 10),
              _buildPsychologRecommendation(context),
              const SizedBox(height: 20),
              _buildSectionTitle("Psikolog terakhir dilihat"),
              const SizedBox(height: 10),
              _buildLastViewedPsychologs(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Image.asset(
          "lib/icons/back2.png",
          height: 6.h,
          width: 6.w,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: Colors.white,
      title: Text(
        "Cari Psikolog",
        style: GoogleFonts.inter(
          color: const Color(0xFF332F2F),
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
      toolbarHeight: 130,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Center(
      child: Container(
        height: 6.h,
        width: 90.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset("lib/icons/search.png"),
            ),
            labelText: "Cari psikolog, artikel, topik...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2E2E2E),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    List<Map<String, String>> categories = [
      {"icon": "lib/icons/Doctor.png", "text": "General"},
      {"icon": "lib/icons/Lungs.png", "text": "Lungs Prob"},
      {"icon": "lib/icons/Dentist.png", "text": "General"},
      {"icon": "lib/icons/psychology.png", "text": "Psychiatrist"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map((item) => ListIcons(icon: item['icon']!, text: item['text']!, category: '',))
            .toList(),
      ),
    );
  }

  Widget _buildPsychologRecommendation(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: PsychologDetails(psychologId: ''),
        ),
      ),
      child: const PsychologList(
        harga: "Rp20.000",
        image: "lib/icons/male-doctor.png",
        namaPsikolog: "Ikhwan Baharudin",
        spesialisasi: "Psikolog Klinis", 
        psychologId: '',
      ),
    );
  }

  Widget _buildLastViewedPsychologs(BuildContext context) {
    List<Map<String, String>> lastViewed = [
      {"name": "Marcus", "image": "lib/icons/male-doctor.png"},
      {"name": "Maria", "image": "lib/icons/female-doctor.png"},
      {"name": "Luke", "image": "lib/icons/black-doctor.png"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: lastViewed.map((psycholog) {
        return Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(psycholog['image']!),
            ),
            const SizedBox(height: 10),
            Text(psycholog['name']!),
          ],
        );
      }).toList(),
    );
  }
}
