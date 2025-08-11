import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/copy_right.dart';
import 'package:aplikasi_absensi/helper/share_pref.dart';
import 'package:aplikasi_absensi/view/auth_page/forgot_password.dart';
import 'package:aplikasi_absensi/view/auth_page/register_page.dart';
import 'package:aplikasi_absensi/view/buttom_navbar_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String id = "/login_page";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Services and Controllers (TIDAK BERUBAH)
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  double _opacity = 0.0; // State untuk animasi

  @override
  void initState() {
    super.initState();
    // Memicu animasi fade-in setelah widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIKA INTI (TIDAK ADA PERUBAHAN) ---
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (response.data != null) {
        _showMessage(
          'Login berhasil! Selamat datang, ${response.data!.user.name}',
        );
        await SharedPreferencesUtil.saveAuthToken(response.data!.token);
        await SharedPreferencesUtil.saveUserData(response.data!.user);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ButtonNavbarPage()),
            (route) => false,
          );
        }
      } else {
        _showMessage(response.message, isError: true);
      }
    } catch (e) {
      debugPrint("Login Exception: $e");
      _showMessage(
        'Terjadi kesalahan. Periksa koneksi internet Anda.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // --- AKHIR DARI LOGIKA INTI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Center(
            child: Container(
              width: isWideScreen
                  ? 400
                  : double.infinity, // max width di web/desktop
              decoration: isWideScreen
                  ? BoxDecoration(
                      color: Colors.blue,
                      // borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: Stack(
                children: [
                  // Latar belakang gradien
                  _buildBackground(),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    // Animasi untuk konten
                    child: AnimatedOpacity(
                      opacity: _opacity,
                      duration: const Duration(milliseconds: 800),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20.0),
                          _buildLogo(),
                          const SizedBox(height: 20.0),
                          _buildSubtitle(),
                          const SizedBox(height: 50.0),
                          _buildLoginForm(),
                          const SizedBox(height: 20.0),
                          _buildLoginButton(),
                          const SizedBox(height: 15.0),
                          _buildForgotPasswordLink(),
                          const SizedBox(height: 100.0),
                          _buildSignUpLink(),
                          const SizedBox(height: 10.0),
                          const CopyrightWidget(
                            appName: 'Endah F N',
                            companyName: 'Si Absensi',
                            textColor: Colors.white70,
                            fontSize: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget untuk latar belakang gradien.
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Ganti dengan warna dari AppColor Anda
          colors: [AppColor.myblue, AppColor.myblue1],
        ),
      ),
    );
  }

  /// Widget untuk logo dan judul.
  Widget _buildLogo() {
    return Column(
      children: [
        // Image.asset('assets/images/logo.png', width: 150, height: 150),
        const SizedBox(height: 20.0),
        Text(
          'Selamat Datang',
          style: GoogleFonts.pacifico(
            fontSize: 36.0,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Column(
      children: [
        Text(
          'Silahkan login untuk masuk ke akun Anda.',
          style: GoogleFonts.poppins(
            fontSize: 12.0,
            color: AppColor.neutral,
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Widget untuk form login.
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Field Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Email', Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(value)) {
                return 'Masukkan format email yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 20.0),
          // Field Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Kata Sandi', Icons.lock_outline)
                .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi tidak boleh kosong';
              }
              if (value.length < 6) {
                return 'Kata sandi minimal 6 karakter';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Widget untuk tombol login.
  Widget _buildLoginButton() {
    return InkWell(
      onTap: _isLoading ? null : _login,
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColor.myblue, AppColor.myblue1, AppColor.myblue],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  'Masuk',
                  style: GoogleFonts.montserrat(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  /// Widget untuk link lupa kata sandi.
  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _isLoading
          ? null
          : () {
              Navigator.pushNamed(context, ForgotPasswordPage.id);
            },
      child: const Text(
        'Lupa Kata Sandi?',
        style: TextStyle(
          color: Colors.white70,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white70,
        ),
      ),
    );
  }

  /// Widget untuk link daftar.
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun?',
          style: TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pushNamed(context, RegisterPage.id);
                },
          child: const Text(
            'Daftar Sekarang',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Dekorasi input yang dapat digunakan kembali.
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
      ),
      errorStyle: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.red.shade300, width: 2.0),
      ),
    );
  }
}
