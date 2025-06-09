import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:psyconnect/screens/auth-screen/login_screen.dart';
import 'package:psyconnect/screens/auth-screen/register_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 200),
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.height * 0.15,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/logo-blue.png"),
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Mulai sekarang!",
              style: GoogleFonts.montserrat(
                fontSize: 22.sp,
                color: const Color.fromARGB(211, 14, 13, 13),
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Expanded(
              child: Text(
                "Masuk untuk menikmati fitur yang kami \nsediakan, dan tetap sehat",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 15.sp,
                  color: const Color.fromARGB(211, 14, 13, 13),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          _buildButton(
            context,
            label: "Login",
            color: bluePrimaryColor,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const LoginScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildButton(
            context,
            label: "Sign up",
            color: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const RegisterScreen(),
                ),
              );
            },
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.7,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isOutlined
                ? const BorderSide(color: Colors.black12)
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 18.sp,
            color: isOutlined ? bluePrimaryColor : Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
