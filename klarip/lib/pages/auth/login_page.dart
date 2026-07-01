// ==============================================================================
// LOGIN PAGE - KLARIP
// ==============================================================================
// File ini berisi tampilan dan logika halaman LOGIN.
// Halaman ini ditampilkan PERTAMA KALI ketika pengguna membuka aplikasi
// dan belum memiliki sesi login yang aktif.
//
// ELEMEN TAMPILAN:
// 1. Ikon/logo aplikasi di bagian atas
// 2. Teks sambutan "Selamat Datang Kembali"
// 3. Input field Email
// 4. Input field Password (dengan tombol tampilkan/sembunyikan)
// 5. Tombol "Masuk"
// 6. Link "Belum punya akun? Daftar" -> ke RegisterPage
//
// ALUR PROSES LOGIN:
// 1. Pengguna mengisi email dan password
// 2. Pengguna menekan tombol "Masuk"
// 3. _handleLogin() dipanggil
// 4. AuthProvider.login() memverifikasi di database SQLite
// 5. Jika berhasil -> navigasi ke HomeShell (halaman utama)
// 6. Jika gagal -> tampilkan pesan error via SnackBar
//
// POLA FLUTTER:
// StatefulWidget digunakan karena halaman ini memiliki STATE yang berubah:
// - Isi text field email dan password
// - Status password visible/hidden (mata terbuka/tertutup)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Untuk mengakses AuthProvider
import '../../providers/auth_provider.dart'; // Provider autentikasi
import '../../theme/app_theme.dart'; // Tema warna aplikasi
import 'register_page.dart'; // Halaman registrasi (tujuan link "Daftar")
import '../../app/home_shell.dart'; // Halaman utama (tujuan setelah login berhasil)

/// Widget halaman login.
/// Menggunakan StatefulWidget karena ada state yang berubah (password visibility).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// State class untuk LoginPage.
/// Menyimpan data yang bisa berubah selama halaman aktif.
class _LoginPageState extends State<LoginPage> {
  // TextEditingController menghubungkan widget TextField dengan nilai teksnya.
  // Dengan controller, kita bisa mengambil teks yang diketik pengguna di mana saja.
  final _emailController = TextEditingController();    // Controller untuk field Email
  final _passwordController = TextEditingController(); // Controller untuk field Password

  // Variabel state: apakah karakter password ditampilkan atau disembunyikan?
  // false = password disembunyikan (default) -> tampil sebagai ****
  // true  = password ditampilkan -> tampil sebagai teks biasa
  bool _isPasswordVisible = false;

  /// Dipanggil saat widget dihapus dari layar (navigasi ke halaman lain).
  /// WAJIB memanggil dispose() pada controller untuk membebaskan memori.
  /// Tanpa ini, bisa terjadi memory leak.
  @override
  void dispose() {
    _emailController.dispose();    // Bebaskan memori controller email
    _passwordController.dispose(); // Bebaskan memori controller password
    super.dispose();
  }

  // ==========================================================================
  // LOGIKA LOGIN
  // ==========================================================================
  /// Fungsi yang dipanggil saat pengguna menekan tombol "Masuk".
  /// Memproses input, memvalidasi, dan menghubungi AuthProvider untuk autentikasi.
  void _handleLogin() async {
    // Ambil teks yang diketik pengguna dari masing-masing controller
    // trim() menghapus spasi di awal dan akhir teks
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi awal: kedua field tidak boleh kosong
    if (email.isEmpty || password.isEmpty) {
      // Tampilkan pesan error di bagian bawah layar (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom')),
      );
      return; // Hentikan proses login
    }

    // Panggil fungsi login di AuthProvider.
    // context.read<T>() digunakan untuk memanggil fungsi sekali saja (tidak listen).
    // Mengembalikan true jika login berhasil, false jika gagal.
    final success = await context.read<AuthProvider>().login(email, password);

    // Cek apakah widget masih ada di layar setelah operasi async selesai.
    // PENTING: Tanpa pengecekan ini, memanggil Navigator setelah widget dihapus
    // akan menyebabkan error di Flutter.
    if (!mounted) return;

    if (success) {
      // Login berhasil: navigasi ke HomeShell (halaman utama dengan 3 tab)
      // pushAndRemoveUntil + (route) => false : menghapus SEMUA halaman sebelumnya
      // dari stack navigasi. Ini mencegah pengguna kembali ke LoginPage
      // dengan tombol Back setelah berhasil login.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (route) => false, // Hapus semua route sebelumnya
      );
    } else {
      // Login gagal: tampilkan pesan error di SnackBar merah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Ambil pesan error dari AuthProvider (misal: "Email atau password salah")
          content: Text(context.read<AuthProvider>().error ?? 'Login gagal'),
          backgroundColor: Colors.red, // Warna merah untuk menandai error
        ),
      );
    }
  }

  // ==========================================================================
  // TAMPILAN UI (BUILD METHOD)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    // context.watch<T>() mendengarkan perubahan di AuthProvider.
    // Setiap kali isLoading berubah, widget ini akan dibangun ulang (rebuild).
    // isLoading = true saat sedang proses login (menunggu database)
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark, // Warna latar belakang gelap dari tema
      body: Center(
        // SingleChildScrollView memungkinkan konten di-scroll jika layar terlalu kecil
        // (misalnya di HP kecil atau saat keyboard muncul)
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0), // Jarak sisi kiri-kanan-atas-bawah
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
            crossAxisAlignment: CrossAxisAlignment.stretch, // Lebarkan ke kiri-kanan
            children: [
              // === IKON APLIKASI ===
              // Ikon perisai (verified_user) sebagai representasi visual keamanan/fakta
              Icon(
                Icons.verified_user_outlined,
                size: 80, // Ukuran besar untuk impact visual
                color: AppTheme.primarySeedColor, // Warna hijau khas Klarip
              ),
              const SizedBox(height: 24), // Jarak vertikal antara elemen

              // === JUDUL HALAMAN ===
              Text(
                'Selamat Datang Kembali',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // === SUBJUDUL ===
              Text(
                'Masuk untuk melanjutkan analisis fakta',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70, // Putih semi-transparan untuk visual hierarki
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // === INPUT EMAIL ===
              TextField(
                controller: _emailController, // Hubungkan ke controller
                style: const TextStyle(color: Colors.white), // Teks yang diketik warna putih
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined), // Ikon amplop di kiri
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Sudut membulat
                  ),
                ),
                keyboardType: TextInputType.emailAddress, // Keyboard mode email (muncul '@')
              ),
              const SizedBox(height: 16),

              // === INPUT PASSWORD ===
              TextField(
                controller: _passwordController,
                // obscureText: true = karakter diganti *** (password mode)
                // Nilainya dibalik dari _isPasswordVisible:
                //   _isPasswordVisible=false -> obscureText=true (disembunyikan)
                //   _isPasswordVisible=true  -> obscureText=false (ditampilkan)
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline), // Ikon gembok di kiri
                  // Tombol mata di sebelah kanan untuk tampilkan/sembunyikan password
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Ganti ikon sesuai status: mata terbuka atau tertutup
                      _isPasswordVisible
                          ? Icons.visibility     // Mata terbuka = password terlihat
                          : Icons.visibility_off, // Mata tertutup = password tersembunyi
                    ),
                    onPressed: () {
                      // setState() memberitahu Flutter untuk membangun ulang widget
                      // dengan nilai _isPasswordVisible yang baru (dibalik)
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // === TOMBOL MASUK ===
              ElevatedButton(
                // Jika sedang loading, tombol dinonaktifkan (onPressed = null)
                // Ini mencegah pengguna menekan tombol berkali-kali
                onPressed: isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primarySeedColor, // Warna hijau khas Klarip
                  padding: const EdgeInsets.symmetric(vertical: 16), // Tinggi tombol
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Saat loading: tampilkan spinner, saat tidak: tampilkan teks "Masuk"
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, // Ketebalan lingkaran spinner
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Masuk',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 16),

              // === LINK KE HALAMAN REGISTRASI ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigasi ke RegisterPage dengan animasi slide standar Flutter
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Daftar',
                      style: TextStyle(
                        color: AppTheme.primarySeedColor, // Warna hijau untuk link
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
