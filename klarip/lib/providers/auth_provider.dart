// ==============================================================================
// AUTH PROVIDER - KLARIP
// ==============================================================================
// File ini mengelola STATE (kondisi) autentikasi pengguna di seluruh aplikasi.
//
// MENGAPA MENGGUNAKAN PROVIDER?
// Provider adalah pola state management di Flutter. Dengan Provider, perubahan
// data login/logout otomatis diketahui oleh semua widget yang memerlukannya,
// tanpa perlu meneruskan data secara manual dari widget ke widget.
//
// TANGGUNG JAWAB AuthProvider:
// 1. Menyimpan data pengguna yang sedang login (_currentUser)
// 2. Mengecek sesi login saat aplikasi pertama dibuka
// 3. Menangani proses Login, Registrasi, Update Profil, Ganti Password, Logout
// 4. Memberitahu UI jika ada perubahan status (via notifyListeners)
// ==============================================================================

import 'package:flutter/material.dart'; // Untuk ChangeNotifier
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan sesi login
import '../models/user.dart'; // Model data pengguna
import '../services/database_helper.dart'; // Akses ke database SQLite

/// AuthProvider mewarisi ChangeNotifier dari Flutter.
/// ChangeNotifier memungkinkan class ini memberi tahu widget yang mendengarkan
/// (listen) ketika ada perubahan data -- misalnya saat login berhasil.
class AuthProvider extends ChangeNotifier {
  // Data pengguna yang sedang login. Null jika belum login.
  User? _currentUser;

  // Status loading: true saat sedang memproses operasi async (login, registrasi, dll)
  // Diinisialisasi true karena langsung mengecek sesi saat aplikasi dibuka
  bool _isLoading = true;

  // Pesan error terakhir. Null jika tidak ada error.
  String? _error;

  // === GETTERS (Properti publik untuk dibaca oleh widget) ===
  User? get currentUser => _currentUser; // Data pengguna saat ini
  bool get isLoading => _isLoading; // Apakah sedang loading?
  String? get error => _error; // Pesan error (jika ada)
  bool get isLoggedIn => _currentUser != null; // Apakah pengguna sudah login?

  // Instance DatabaseHelper untuk operasi database
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Constructor: langsung cek apakah ada sesi login yang tersimpan
  /// saat AuthProvider pertama kali dibuat (saat aplikasi dibuka).
  AuthProvider() {
    _checkLoginStatus();
  }

  /// Mengecek apakah pengguna sudah pernah login sebelumnya.
  /// Sesi login disimpan di SharedPreferences (penyimpanan key-value di HP).
  ///
  /// ALUR:
  /// 1. Baca email tersimpan dari SharedPreferences
  /// 2. Jika ada, cari data pengguna di database SQLite
  /// 3. Jika data ditemukan, set sebagai pengguna aktif
  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners(); // Beritahu widget bahwa loading dimulai

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email'); // Baca email dari sesi

      if (userEmail != null) {
        // Ada email tersimpan -- cari data lengkap pengguna di database
        final userData = await _dbHelper.getUserByEmail(userEmail);
        if (userData != null) {
          // Data ditemukan -- set sebagai pengguna yang sedang aktif
          _currentUser = User.fromMap(userData);
        } else {
          // Data tidak ada di database (mungkin dihapus) -- hapus sesi
          await prefs.remove('user_email');
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
    }

    _isLoading = false;
    notifyListeners(); // Beritahu widget bahwa pengecekan selesai
  }

  /// Memproses login pengguna.
  ///
  /// [email]    -- Email yang dimasukkan pengguna
  /// [password] -- Password yang dimasukkan pengguna
  ///
  /// Return: true jika berhasil, false jika gagal
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null; // Reset pesan error sebelumnya
    notifyListeners();

    try {
      // Verifikasi email + password di database SQLite
      final userData = await _dbHelper.loginUser(email, password);

      if (userData != null) {
        // Login berhasil: simpan data pengguna ke state
        _currentUser = User.fromMap(userData);

        // Simpan email ke SharedPreferences agar sesi tidak hilang saat app ditutup
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);

        _isLoading = false;
        notifyListeners(); // Beritahu widget: login berhasil, tampilkan halaman utama
        return true;
      } else {
        // Login gagal: email/password tidak cocok
        _error = 'Email atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Memproses registrasi (pendaftaran) pengguna baru.
  ///
  /// [fullName]  -- Nama lengkap pengguna
  /// [username]  -- Username unik
  /// [email]     -- Email (akan digunakan sebagai identitas login)
  /// [password]  -- Password akun
  ///
  /// Return: true jika berhasil, false jika gagal
  Future<bool> register(
    String fullName,
    String username,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Langkah 1: Cek apakah email sudah terdaftar
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        _error = 'Email sudah terdaftar';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Langkah 2: Buat objek User baru dari data yang dimasukkan
      final newUser = User(
        username: username,
        email: email,
        password: password, // Catatan: di aplikasi nyata, password sebaiknya di-hash
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      // Langkah 3: Simpan pengguna baru ke database SQLite
      await _dbHelper.insert('users', newUser.toMap());

      // Langkah 4: Login otomatis setelah registrasi berhasil
      return await login(email, password);
    } catch (e) {
      _error = 'Gagal mendaftar: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Memperbarui data profil pengguna yang sedang login.
  ///
  /// [updatedUser] -- Objek User berisi data profil terbaru
  ///
  /// Return: true jika berhasil, false jika gagal
  Future<bool> updateProfile(User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Perbarui data di database berdasarkan ID pengguna
      await _dbHelper.update('users', updatedUser.toMap(), 'id = ?', [
        updatedUser.id,
      ]);

      // Perbarui juga data yang tersimpan di memori (state lokal)
      _currentUser = updatedUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal update profil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Mengganti password pengguna yang sedang login.
  ///
  /// [userId]      -- ID pengguna (untuk memastikan yang tepat diperbarui)
  /// [oldPassword] -- Password lama (untuk verifikasi)
  /// [newPassword] -- Password baru yang ingin diterapkan
  ///
  /// Return: true jika berhasil, false jika gagal
  Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Langkah 1: Verifikasi password lama dengan data yang ada di state
      if (_currentUser?.id == userId) {
        if (_currentUser?.password != oldPassword) {
          _error = 'Password lama salah';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        // Kondisi ini tidak seharusnya terjadi dalam alur normal
        _error = 'User mismatch';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Langkah 2: Update HANYA field password di database (tidak semua field)
      await _dbHelper.update(
        'users',
        {'password': newPassword}, // Hanya kolom password yang diperbarui
        'id = ?',
        [userId],
      );

      // Langkah 3: Perbarui juga state lokal agar konsisten dengan database
      _currentUser = _currentUser?.copyWith(password: newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal ganti password: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Proses logout: menghapus sesi dan mengosongkan data pengguna.
  ///
  /// EFEK:
  /// 1. Hapus email dari SharedPreferences (sesi dihapus)
  /// 2. Set _currentUser menjadi null
  /// 3. Beritahu widget -- aplikasi akan kembali ke halaman login
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email'); // Hapus sesi yang tersimpan
    _currentUser = null; // Kosongkan data pengguna
    notifyListeners(); // Widget akan otomatis kembali ke LoginPage
  }
}
