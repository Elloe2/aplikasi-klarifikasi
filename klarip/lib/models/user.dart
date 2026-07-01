// ==============================================================================
// PENJELASAN UNTUK SIDANG: MODEL USER (PENGGUNA)
// ==============================================================================
// Bapak/Ibu Penguji, file ini adalah "Blueprint" (Cetak Biru) dari data Pengguna.
// Mirip seperti KTP yang punya kolom pasti (Nama, NIK, Tanggal Lahir), kelas ini
// memastikan setiap data User di aplikasi memiliki struktur yang seragam.
//
// KONSEP IMMUTABILITY (KEKEKALAN DATA):
// Model ini dirancang "Immutable" (menggunakan kata kunci `final`).
// Artinya, setelah sebuah data User dibuat, nilainya tidak bisa diubah begitu saja 
// secara tidak sengaja (sangat aman dari bug state). 
// Jika pengguna ingin mengganti nama, kita menggunakan fungsi `copyWith` untuk 
// mencetak KTP/objek baru dengan nama yang diupdate, bukan mencoret nama di KTP lama.
// ==============================================================================

/// Kelas User merepresentasikan data satu akun pengguna di aplikasi.
/// Bersifat IMMUTABLE (tidak bisa diubah setelah dibuat) -- jika ingin
/// mengubah data, gunakan method copyWith() untuk membuat salinan baru.
class User {
  final int? id; // ID unik dari database (null saat belum disimpan)
  final String username; // Nama pengguna unik untuk identifikasi
  final String email; // Email sebagai ID login
  final String password; // Password akun
  final String? fullName; // Nama lengkap (opsional)
  final int? age; // Usia pengguna (opsional)
  final String? education; // Tingkat pendidikan (opsional)
  final DateTime createdAt; // Waktu registrasi akun

  /// Constructor: membuat objek User baru.
  /// Parameter dengan tanda '?' bersifat opsional (boleh null).
  /// Parameter dengan 'required' wajib diisi.
  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
    this.age,
    this.education,
    required this.createdAt,
  });

  /// Mengubah objek User menjadi Map (seperti kamus key-value).
  /// Digunakan saat menyimpan data ke database SQLite.
  /// Nama key harus sama dengan nama kolom di tabel 'users'.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName, // Di database kolom bernama 'full_name'
      'age': age,
      'education': education,
      'created_at': createdAt.toIso8601String(), // Format: "2024-01-15T10:30:00"
    };
  }

  /// Factory constructor: membuat objek User dari Map (data dari database).
  /// Digunakan saat membaca data dari database SQLite -- kebalikan dari toMap().
  ///
  /// [map] -- Data satu baris dari database dalam bentuk Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      fullName: map['full_name'],
      age: map['age'],
      education: map['education'],
      createdAt: DateTime.parse(map['created_at']), // String -> DateTime
    );
  }

  /// Membuat salinan objek User dengan beberapa field yang diubah.
  /// Karena User bersifat immutable, cara mengubah data adalah dengan
  /// membuat objek baru yang mewarisi semua field lama kecuali yang diubah.
  ///
  /// Contoh penggunaan: mengubah hanya nama tanpa mengubah email/password
  /// User diperbarui = user.copyWith(fullName: 'Nama Baru');
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? fullName,
    int? age,
    String? education,
    DateTime? createdAt,
  }) {
    return User(
      // Operator ?? berarti: gunakan nilai baru jika ada, jika tidak pakai nilai lama
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      education: education ?? this.education,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
