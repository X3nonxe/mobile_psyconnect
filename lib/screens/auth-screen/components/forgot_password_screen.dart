// forgot_password.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:psyconnect/screens/auth-screen/login_screen.dart';
import 'package:psyconnect/widgets/forgot_password_tabs.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _TabBarExampleState createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset("lib/icons/back2.png"),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.topToBottom,
                child: const LoginScreen(),
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40.h),
              _buildTitle(),
              const SizedBox(height: 10),
              _buildDescription(),
              ForgotPasswordTabs(tabController: tabController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Lupa password?",
      style: GoogleFonts.montserrat(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      "Masukkan email atau nomor telepon Anda, kami\nakan mengirimkan kode konfirmasi kepada Anda",
      style: GoogleFonts.openSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Colors.black54,
      ),
    );
  }
}
