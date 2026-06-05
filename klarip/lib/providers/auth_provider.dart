import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true; // Start with loading to check session
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');

      if (userEmail != null) {
        final userData = await _dbHelper.getUserByEmail(userEmail);
        if (userData != null) {
          _currentUser = User.fromMap(userData);
        } else {
          // User data might have been deleted, clear session
          await prefs.remove('user_email');
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _dbHelper.loginUser(email, password);

      if (userData != null) {
        _currentUser = User.fromMap(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
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
      // Check if email already exists
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        _error = 'Email sudah terdaftar';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      final newUser = User(
        username: username,
        email: email,
        password: password, // In a real app, hash this!
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      await _dbHelper.insert('users', newUser.toMap());

      // Auto login
      return await login(email, password);
    } catch (e) {
      _error = 'Gagal mendaftar: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.update('users', updatedUser.toMap(), 'id = ?', [
        updatedUser.id,
      ]);

      // Update local state
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

  Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Verify old password
      // Since we don't have getById, we check against current user state or re-query
      if (_currentUser?.id == userId) {
        if (_currentUser?.password != oldPassword) {
          _error = 'Password lama salah';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        // Fallback: should not happen if logic is correct
        _error = 'User mismatch';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Update password
      // We need to update ONLY the password field.
      // But our User model is immutable.
      // We can use dbHelper.update with a specific map.
      await _dbHelper.update(
        'users',
        {'password': newPassword},
        'id = ?',
        [userId],
      );

      // 3. Update local state
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    _currentUser = null;
    notifyListeners();
  }
}
