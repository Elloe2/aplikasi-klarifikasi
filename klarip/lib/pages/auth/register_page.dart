// ==============================================================================
// REGISTER PAGE - KLARIP
// ==============================================================================
// File ini berisi tampilan dan logika halaman REGISTRASI (pendaftaran akun baru).
// Pengguna bisa mengakses halaman ini dengan menekan link "Daftar" di LoginPage.
//
// ELEMEN TAMPILAN:
// 1. AppBar dengan judul "Buat Akun Baru" dan tombol kembali
// 2. Ikon "tambah pengguna" di bagian atas
// 3. Input field: Nama Lengkap, Username, Email, Password
// 4. Tombol "Daftar Sekarang"
//
// ALUR PROSES REGISTRASI:
// 1. Pengguna mengisi semua field
// 2. Pengguna menekan tombol "Daftar Sekarang"
// 3. _handleRegister() dipanggil
// 4. Validasi: semua field tidak boleh kosong
// 5. AuthProvider.register() dipanggil:
//    a. Cek email sudah terdaftar? (jika ya -> tampilkan error)
//    b. Simpan pengguna baru ke database SQLite
//    c. Login otomatis menggunakan email + password yang baru didaftarkan
// 6. Jika berhasil -> navigasi ke HomeShell (halaman utama)
// 7. Jika gagal -> tampilkan pesan error via SnackBar
//
// CATATAN: Setelah registrasi berhasil, pengguna LANGSUNG masuk ke halaman
// utama tanpa perlu login manual. Ini disebut "auto-login setelah registrasi".
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Untuk mengakses AuthProvider
import '../../providers/auth_provider.dart'; // Provider autentikasi
import '../../theme/app_theme.dart'; // Tema warna aplikasi
import '../../app/home_shell.dart'; // Halaman utama (tujuan setelah registrasi berhasil)

/// Widget halaman registrasi.
/// StatefulWidget karena memiliki state yang berubah (visibility password).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// State class untuk RegisterPage.
class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk setiap field input.
  // Setiap TextField membutuhkan satu controller agar nilainya bisa dibaca di kode.
  final _fullNameController = TextEditingController();  // Field Nama Lengkap
  final _usernameController = TextEditingController();  // Field Username
  final _emailController = TextEditingController();     // Field Email
  final _passwordController = TextEditingController();  // Field Password

  // State: apakah password ditampilkan atau disembunyikan?
  bool _isPasswordVisible = false;

  /// Wajib memanggil dispose() untuk semua controller saat widget dihapus.
  /// Mencegah memory leak (kebocoran memori).
  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // LOGIKA REGISTRASI
  // ==========================================================================
  /// Dipanggil saat tombol "Daftar Sekarang" ditekan.
  /// Memvalidasi input dan memanggil AuthProvider.register() untuk menyimpan akun.
  void _handleRegister() async {
    // Ambil semua input dan bersihkan dari spasi tidak perlu
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi: SEMUA field wajib diisi
    // Operator || berarti "ATAU" -- jika SALAH SATU kosong, tampilkan error
    if (fullName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom')),
      );
      return; // Hentikan proses, jangan lanjut ke registrasi
    }

    // Panggil AuthProvider.register() yang akan:
    // 1. Cek apakah email sudah terdaftar
    // 2. Simpan pengguna baru ke SQLite
    // 3. Auto-login setelah berhasil
    final success = await context.read<AuthProvider>().register(
      fullName,
      username,
      email,
      password,
    );

    // Cek apakah widget masih aktif di layar setelah operasi async
    if (!mounted) return;

    if (success) {
      // Registrasi dan auto-login berhasil.
      // Navigasi ke HomeShell dan hapus semua halaman sebelumnya dari stack.
      // Ini mencegah pengguna kembali ke LoginPage/RegisterPage dengan tombol Back.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (route) => false, // Hapus semua route sebelumnya
      );
    } else {
      // Registrasi gagal (misalnya: email sudah terdaftar)
      // Tampilkan pesan error dari AuthProvider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthProvider>().error ?? 'Registrasi gagal',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================================
  // TAMPILAN UI
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan isLoading dari AuthProvider untuk menonaktifkan tombol
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      // AppBar dengan tombol kembali (<-) otomatis dari Flutter
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        backgroundColor: Colors.transparent, // Transparan agar menyatu dengan background
        elevation: 0, // Hilangkan bayangan di bawah AppBar
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === IKON HEADER ===
              // Ikon "tambah orang" menandakan ini halaman pendaftaran pengguna baru
              Icon(
                Icons.person_add_outlined,
                size: 64,
                color: AppTheme.primarySeedColor,
              ),
              const SizedBox(height: 32),

              // === FIELD NAMA LENGKAP ===
              TextField(
                controller: _fullNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.badge_outlined), // Ikon kartu identitas
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                // Huruf pertama setiap kata otomatis besar (format nama)
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // === FIELD USERNAME ===
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.alternate_email), // Ikon @
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // === FIELD EMAIL ===
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress, // Keyboard mode email
              ),
              const SizedBox(height: 16),

              // === FIELD PASSWORD ===
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, // Sembunyikan/tampilkan karakter
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  // Tombol mata untuk toggle tampilkan/sembunyikan password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              // === TOMBOL DAFTAR ===
              ElevatedButton(
                // Nonaktifkan tombol saat sedang loading (proses registrasi berjalan)
                onPressed: isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primarySeedColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Tampilkan spinner saat loading, teks saat tidak loading
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Daftar Sekarang',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
