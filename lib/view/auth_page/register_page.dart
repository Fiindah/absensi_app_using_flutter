import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/copy_right.dart';
import 'package:aplikasi_absensi/helper/share_pref.dart';
import 'package:aplikasi_absensi/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const String id = "/register_page";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // --- KODE INTI (TIDAK BERUBAH) ---
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isFetchingDropdownData = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  Batch? _selectedBatch;
  List<Batch> _batches = [];

  Training? _selectedTraining;
  List<Training> _trainings = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    setState(() {
      _isFetchingDropdownData = true;
    });
    try {
      final fetchedBatches = await _authService.fetchBatches();
      final fetchedTrainings = await _authService.fetchTrainings();

      setState(() {
        _batches = fetchedBatches;
        _trainings = fetchedTrainings;
        // Optionally pre-select the first item if lists are not empty
        // _selectedBatch = _batches.isNotEmpty ? _batches.first : null;
        // _selectedTraining = _trainings.isNotEmpty ? _trainings.first : null;
      });
    } catch (e) {
      _showMessage(
        'Gagal memuat data Batch atau Training: $e',
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isFetchingDropdownData = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Color color = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        backgroundColor: color,
      ),
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Pastikan batch dan training sudah dipilih
    if (_selectedBatch == null) {
      _showMessage('Silakan pilih Batch.', color: Colors.red);
      return;
    }
    if (_selectedTraining == null) {
      _showMessage('Silakan pilih Training.', color: Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Konversi _selectedGender ke 'L' atau 'P'
    String genderForApi = '';
    if (_selectedGender == 'Laki-laki') {
      genderForApi = 'L';
    } else if (_selectedGender == 'Perempuan') {
      genderForApi = 'P';
    } else {
      // Ini seharusnya tidak tercapai jika validator sudah bekerja
      _showMessage('Jenis kelamin tidak valid.', color: Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        jenisKelamin: genderForApi,
        batchId: _selectedBatch!.id, // Send selected batch ID
        trainingId: _selectedTraining!.id, // Send selected training ID
      );

      if (response.data != null) {
        _showMessage(
          'Pendaftaran berhasil! Silakan masuk.',
          color: Colors.green,
        );
        await SharedPreferencesUtil.saveAuthToken(response.data!.token);
        await SharedPreferencesUtil.saveUserData(response.data!.user);
        Navigator.pop(context);
      } else {
        String errorMessage = response.message;
        if (response.errors != null) {
          response.errors!.forEach((key, value) {
            errorMessage +=
                '\n${key.toUpperCase()}: ${(value as List).join(', ')}';
          });
        }
        _showMessage(errorMessage, color: Colors.red);
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan tak terduga: $e', color: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // --- AKHIR DARI KODE INTI ---

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
                  _buildBackground(),
                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 30.0),
                            _buildRegisterForm(),
                            const SizedBox(height: 20.0),
                            _buildRegisterButton(),
                            const SizedBox(height: 20.0),
                            _buildLoginLink(),
                            const SizedBox(height: 20.0),
                            const CopyrightOverlay(textColor: Colors.white70),

                            // const CopyrightWidget(
                            //   appName: 'Si Absensi',
                            //   devName: 'Endah F N',
                            //   textColor: Colors.white70,
                            //   fontSize: 10.0,
                            // ),
                          ],
                        ),
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

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.myblue, AppColor.myblue1],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Image.asset('assets/images/logo.png', width: 150, height: 150),
        const SizedBox(height: 10.0),
        Text(
          'Buat Akun Baru',
          style: GoogleFonts.poppins(
            fontSize: 28.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Text(
          'Lengkapi data diri Anda untuk memulai',
          style: GoogleFonts.lato(fontSize: 16.0, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Nama Lengkap', Icons.person_outline),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Nama tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Email', Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Email tidak boleh kosong';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value))
                return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 20.0),
          // Dropdown Jenis Kelamin
          DropdownButtonFormField<String>(
            value: _selectedGender,
            style: const TextStyle(color: Colors.white),
            dropdownColor: AppColor.myblue.withOpacity(0.9),
            decoration: _inputDecoration('Jenis Kelamin', Icons.wc_outlined),
            items: _genders.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (newValue) => setState(() => _selectedGender = newValue),
            validator: (value) =>
                (value == null) ? 'Pilih jenis kelamin' : null,
          ),
          const SizedBox(height: 20.0),
          // Dropdown Batch
          DropdownButtonFormField<Batch>(
            value: _selectedBatch,
            isExpanded: true,
            style: const TextStyle(color: Colors.white),
            dropdownColor: AppColor.myblue.withOpacity(0.9),
            decoration: _inputDecoration('Batch', Icons.group_outlined),
            items: _batches.map((Batch batch) {
              return DropdownMenuItem<Batch>(
                value: batch,
                child: Text(
                  'Batch ${batch.batchKe} (${batch.startDate})',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (newValue) => setState(() => _selectedBatch = newValue),
            validator: (value) => (value == null) ? 'Pilih batch' : null,
            hint: _isFetchingDropdownData
                ? const Text(
                    'Memuat...',
                    style: TextStyle(color: Colors.white70),
                  )
                : null,
          ),
          const SizedBox(height: 20.0),
          // Dropdown Training
          DropdownButtonFormField<Training>(
            value: _selectedTraining,
            isExpanded: true,
            style: const TextStyle(color: Colors.white),
            dropdownColor: AppColor.myblue.withOpacity(0.9),
            decoration: _inputDecoration(
              'Training',
              Icons.local_activity_outlined,
            ),
            items: _trainings.map((Training training) {
              return DropdownMenuItem<Training>(
                value: training,
                child: Text(training.title, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (newValue) =>
                setState(() => _selectedTraining = newValue),
            validator: (value) => (value == null) ? 'Pilih training' : null,
            hint: _isFetchingDropdownData
                ? const Text(
                    'Memuat...',
                    style: TextStyle(color: Colors.white70),
                  )
                : null,
          ),
          const SizedBox(height: 20.0),
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
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Kata sandi tidak boleh kosong';
              if (value.length < 6) return 'Kata sandi minimal 6 karakter';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    bool isDisabled = _isLoading || _isFetchingDropdownData;
    return InkWell(
      onTap: isDisabled ? null : _register,
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          gradient: LinearGradient(
            colors: isDisabled
                ? [Colors.grey.shade600, Colors.grey.shade700]
                : [AppColor.myblue, AppColor.myblue],
          ),
          boxShadow: [
            BoxShadow(
              color: isDisabled
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: isDisabled
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  'Daftar',
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sudah punya akun?',
          style: TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Masuk',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              // decoration: TextDecoration.underline,
              // decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

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
