import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:psyconnect/blocs/auth/auth_bloc.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:psyconnect/screens/auth-screen/components/auth_social_login.dart';
import 'package:psyconnect/screens/auth-screen/components/auth_text_field.dart';
import 'package:psyconnect/screens/auth-screen/components/forgot_password_screen.dart';
import 'package:psyconnect/screens/auth-screen/login_register_screen.dart';
import 'package:psyconnect/screens/auth-screen/register_screen.dart';
import 'package:psyconnect/screens/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _isEmailValid(_emailController.text) &&
        _isPasswordValid(_passwordController.text);
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8;
  }

  Future<void> _saveUserData(String token, String role, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('id', id);
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginEvent(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            ),
          );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: const Homepage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _saveUserData(
            state.token,
            state.user.role,
            state.user.id,
          );
          _navigateToHome();
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showMaterialBanner(
            MaterialBanner(
              content: Text("Invalid email or password"),
              backgroundColor: Colors.red,
              contentTextStyle:
                  TextStyle(color: Colors.white), // Pastikan teks terlihat
              actions: <Widget>[
                TextButton(
                  child: Text('TUTUP', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  },
                ),
              ],
            ),
          );

          Future.delayed(Duration(seconds: 3), () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Image.asset(
              "lib/icons/back2.png",
              height: 2.5.h,
              width: 2.5.h,
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.leftToRight,
                child: const LoginRegisterScreen(),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            "Masuk",
            style: GoogleFonts.montserrat(
              color: Colors.black87,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          toolbarHeight: 11.h,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Form(
              key: _formKey,
              autovalidateMode:
                  AutovalidateMode.onUserInteraction, // Tambahkan ini
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 4.h),
                    AuthTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      text: 'Masukkan Email',
                      icon: 'lib/icons/email.png',
                      validator: (value) {
                        if (value!.isEmpty) return 'Email wajib diisi';
                        if (!_isEmailValid(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 1.h),
                    AuthTextField(
                      controller: _passwordController,
                      text: 'Masukkan Password',
                      icon: 'lib/icons/lock.png',
                      isPassword: true,
                      validator: (value) {
                        if (value!.isEmpty) return 'Password wajib diisi';
                        if (!_isPasswordValid(value)) {
                          return 'Password minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    _buildForgotPassword(),
                    SizedBox(height: 3.h),
                    _buildLoginButton(),
                    SizedBox(height: 3.h),
                    _buildRegisterLink(),
                    SizedBox(height: 3.h),
                    _buildOrDivider(),
                    SizedBox(height: 3.h),
                    const AuthSocialLogins(
                      logo: "images/google.png",
                      text: "Masuk dengan Google",
                    ),
                    SizedBox(height: 2.h),
                    const AuthSocialLogins(
                      logo: "images/apple.png",
                      text: "Masuk dengan Apple",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: const ForgotPasswordScreen(),
          ),
        ),
        child: Text(
          "Lupa Password?",
          style: GoogleFonts.openSans(
            fontSize: 15.sp,
            color: bluePrimaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          height: 6.h,
          width: 90.w,
          child: ElevatedButton(
            onPressed:
                (state is AuthLoading || !_isFormValid) // Perubahan disini
                    ? null
                    : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: bluePrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: state is AuthLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "Masuk",
                    style: GoogleFonts.openSans(
                      fontSize: 17.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Belum memiliki akun? ",
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const RegisterScreen(),
            ),
          ),
          child: Text(
            "Daftar",
            style: GoogleFonts.openSans(
              fontSize: 15.sp,
              color: bluePrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            "Atau",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
