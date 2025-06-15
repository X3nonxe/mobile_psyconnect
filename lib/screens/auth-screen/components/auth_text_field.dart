import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Ubah AuthTextField menjadi Stateful Widget
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String text;
  final String icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword; // Tambahkan properti baru

  const AuthTextField({
    super.key,
    required this.controller,
    required this.text,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.isPassword = false, // Default false
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? _obscureText : false,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 4.w),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 4.w, right: 2.w),
          child: Image.asset(
            widget.icon,
            height: 2.5.h,
            width: 2.5.h,
          ),
        ),
        // Tambahkan suffix icon untuk toggle visibility
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        hintText: widget.text,
        hintStyle: GoogleFonts.openSans(
          fontSize: 15.sp,
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: bluePrimaryColor),
        ),
      ),
      validator: widget.validator,
    );
  }
}
