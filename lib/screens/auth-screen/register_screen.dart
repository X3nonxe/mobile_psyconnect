import 'package:intl/intl.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:psyconnect/screens/auth-screen/components/auth_text_field.dart';
import 'package:psyconnect/screens/auth-screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:psyconnect/services/auth_service.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nomorController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z]+\.[a-zA-Z]+$');
    return emailRegex.hasMatch(email);
  }

  bool isNameValid(String fullName) => fullName.length >= 3;
  bool isPasswordValid(String password) => password.length >= 8;
  bool isNomorValid(String nomor) {
    final regex = RegExp(r'^(^\+62\s?|^0)(\d{3,4}-?){2}\d{3,4}$');
    return regex.hasMatch(nomor);
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    nameController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    nomorController.addListener(() => setState(() {}));
    birthDateController.addListener(() => setState(() {}));
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .subtract(const Duration(days: 365 * 18)), // 18 tahun lalu
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: bluePrimaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: bluePrimaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        birthDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> handleRegister() async {
    String phoneNumber = nomorController.text.trim();
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '+62${phoneNumber.substring(1)}';
    }
    // Validate input fields
    if (!_validateInputs()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
        phoneNumber,
        birthDateController.text.trim(),
      );

      print('Response: $response');

      if (response['message'] == 'KLien registered successfully') {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: LoginScreen(),
          ),
        );
      } else {
        setState(() {
          errorMessage = response['message'];
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _validateInputs() {
    if (!isEmailValid(emailController.text.trim())) {
      _showSnackBar("Format email tidak valid");
      return false;
    }
    if (!isNameValid(nameController.text.trim())) {
      _showSnackBar("Nama harus minimal 3 karakter");
      return false;
    }
    if (!isPasswordValid(passwordController.text.trim())) {
      _showSnackBar("Password harus minimal 8 karakter");
      return false;
    }
    if (!isNomorValid(nomorController.text.trim())) {
      _showSnackBar("Nomor harus minimal 10 karakter");
      return false;
    }

    if (birthDateController.text.isEmpty) {
      _showSnackBar("Tanggal lahir harus diisi");
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          errorMessage!,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.redAccent),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String iconPath,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    return AuthTextField(
      text: label,
      icon: iconPath,
      keyboardType: keyboardType,
      controller: controller,
      isPassword: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Field tidak boleh kosong";
        }
        if (isPassword && !isPasswordValid(value)) {
          return "Password harus minimal 8 karakter";
        }
        if (!isEmailValid(value) &&
            keyboardType == TextInputType.emailAddress) {
          return "Format email tidak valid";
        }
        if (!isNomorValid(value) && keyboardType == TextInputType.phone) {
          return "Nomor harus minimal 10 karakter";
        }
        return null;
      },
    );
  }

  Widget _buildDateOfBirthField() {
    return GestureDetector(
      onTap: _selectBirthDate,
      child: AbsorbPointer(
        child: AuthTextField(
          text: "Tanggal Lahir",
          icon: "lib/icons/callender.png",
          controller: birthDateController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Tanggal lahir harus diisi";
            }
            return null;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width * 0.06,
            child: Image.asset("lib/icons/back2.png"),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.leftToRight,
                child: LoginScreen(),
              ),
            );
          },
        ),
        title: Text(
          "Daftar",
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        toolbarHeight: 110,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildTextField(
                  controller: nameController,
                  label: "Masukkan Nama",
                  iconPath: "lib/icons/person.png",
                ),
                const SizedBox(height: 5),
                _buildTextField(
                  controller: emailController,
                  label: "Masukkan email anda",
                  iconPath: "lib/icons/email.png",
                  keyboardType: TextInputType.emailAddress,
                  errorText: emailController.text.isNotEmpty &&
                          !isEmailValid(emailController.text.trim())
                      ? "Format email tidak valid"
                      : null,
                ),
                const SizedBox(height: 5),
                _buildTextField(
                  controller: passwordController,
                  label: "Masukkan password anda",
                  iconPath: "lib/icons/lock.png",
                  isPassword: true,
                  errorText: passwordController.text.isNotEmpty &&
                          !isPasswordValid(passwordController.text.trim())
                      ? "Password harus minimal 8 karakter"
                      : null,
                ),
                const SizedBox(height: 5),
                _buildTextField(
                  controller: nomorController,
                  label: "Masukkan nomor telepon anda",
                  iconPath: "lib/icons/call.png",
                  keyboardType: TextInputType.phone,
                  errorText: nomorController.text.isNotEmpty &&
                          !isNomorValid(nomorController.text.trim())
                      ? "Nomor harus minimal 10 karakter"
                      : null,
                ),
                const SizedBox(height: 5),
                _buildDateOfBirthField(),
                const SizedBox(height: 5),
                _buildErrorMessage(),
                const SizedBox(height: 30),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                    onPressed: handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bluePrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Buat Akun",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
