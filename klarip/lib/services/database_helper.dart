// ==============================================================================
// PENJELASAN UNTUK SIDANG: DATABASE HELPER
// ==============================================================================
// Bapak/Ibu Penguji, file `database_helper.dart` ini bertanggung jawab penuh 
// untuk mengelola penyimpanan data lokal (Offline Storage) di aplikasi Klarip.
// Kami menggunakan teknologi SQLite (Standard Industri untuk mobile database).
//
// MENGAPA MENGGUNAKAN SQLITE (LOKAL) DAN BUKAN FIREBASE/MYSQL (SERVER)?
// 1. Privasi: Riwayat pencarian pengguna (yang mungkin sensitif) tidak dikirim 
//    dan disimpan di server kami, melainkan murni di HP pengguna.
// 2. Aksesibilitas: Pengguna tetap bisa melihat riwayat lama meskipun tidak ada internet.
// 3. Biaya: Memangkas biaya sewa server backend menjadi Rp 0.
//
// POLA DESAIN (DESIGN PATTERN) YANG DIGUNAKAN: SINGLETON
// Kelas ini menerapkan pola arsitektur Singleton. Artinya, di seluruh aplikasi
// hanya boleh ada SATU koneksi database yang terbuka. Ini mencegah error fatal
// seperti 'Database is locked' atau memory leak jika halaman A dan B sama-sama
// mencoba membuka database di waktu yang sama.
// ==============================================================================

import 'package:sqflite/sqflite.dart'; // Package utama Flutter untuk menjalankan perintah SQL.
import 'package:path/path.dart'; // Package pembantu untuk menyatukan nama folder dan file database.

/// PENJELASAN SIDANG:
/// Ini adalah inti dari kelas pengelola database kita.
class DatabaseHelper {
  // Nama file database berekstensi .db yang akan terbuat tersembunyi di memori HP.
  static const _databaseName = "klarip_v4.db";

  // PENJELASAN SIDANG: VERSI DATABASE (MIGRATION)
  // Konsep Migrasi: Jika di masa depan kita butuh tabel baru (misal: fitur profil),
  // kita tidak boleh menghapus database lama karena data user akan hilang.
  // Kita cukup menaikkan _databaseVersion (misal jadi 4), lalu menjalankan 
  // perintah 'ALTER TABLE' di fungsi _onUpgrade.
  static const _databaseVersion = 3;

  // === PENJELASAN SIDANG: IMPLEMENTASI SINGLETON PATTERN ===
  // 1. Constructor (Pembangun) dibuat private (ada tanda underscore '_').
  //    Artinya, file lain DILARANG KERAS membuat objek ini pakai sintaks 'new DatabaseHelper()'.
  DatabaseHelper._privateConstructor();

  // 2. Kita buat satu-satunya objek 'suci' yang statis (hanya ada satu di memori).
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  // 3. Factory constructor: Setiap kali file lain memanggil DatabaseHelper(),
  //    sistem secara otomatis melempar objek '_instance' yang sama, BUKAN membuat baru.
  factory DatabaseHelper() => _instance;

  // Variabel penyimpan koneksi database. Nullable (?) karena di detik pertama aplikasi dibuka, database belum termuat.
  static Database? _database;

  /// PENJELASAN SIDANG:
  /// Ini adalah metode 'Lazy Initialization' (Inisialisasi Malas).
  /// Database baru akan benar-benar dibuka HANYA KETIKA ada fitur yang memintanya.
  /// Ini menghemat pemakaian RAM HP saat aplikasi baru pertama kali dibuka.
  Future<Database> get database async {
    if (_database != null) return _database!; // Jika sudah pernah dibuka, langsung pakai.
    
    _database = await _initDatabase(); // Jika belum, buka/buat file db-nya sekarang.
    return _database!;
  }

  /// PENJELASAN SIDANG:
  /// Fungsi `_initDatabase` mencari lokasi aman di memori HP Android/iOS untuk menaruh file db.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath(); // Mencari folder khusus database dari sistem operasi HP
    final path = join(dbPath, _databaseName); // Menggabungkan path dengan nama file
    
    // Perintah sakti untuk membuka/membuat database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate, // Jika file belum ada (user baru download), buat dari awal.
      onUpgrade: _onUpgrade, // Jika versi naik (user update aplikasi), jalankan migrasi.
    );
  }

  /// PENJELASAN SIDANG (FUNGSI MIGRASI):
  /// Fungsi ini memastikan pengguna lama yang mengupdate aplikasi ke versi terbaru
  /// tidak akan kehilangan data riwayat mereka, karena kita hanya menambahkan kolom (ALTER), bukan menghapus.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN age INTEGER');
      await db.execute('ALTER TABLE users ADD COLUMN education TEXT');
    }
    if (oldVersion < 3) {
      // Penambahan relasi (foreign key virtual) agar riwayat menempel pada email user yang login.
      await db.execute('ALTER TABLE saved_analyses ADD COLUMN user_email TEXT');
    }
  }

  /// PENJELASAN SIDANG (FUNGSI PEMBUATAN AWAL):
  /// Bahasa SQL mentah (Raw SQL) digunakan di sini untuk merancang struktur (Schema) tabel.
  Future<void> _onCreate(Database db, int version) async {
    // 1. Membuat Tabel Koleksi Riwayat Analisis
    // ID menggunakan AUTOINCREMENT agar SQLite yang pusing memikirkan urutan nomor urutnya.
    await db.execute('''
      CREATE TABLE saved_analyses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        claim TEXT,
        verdict TEXT,
        explanation TEXT,
        confidence REAL,
        user_note TEXT,
        source_url TEXT,
        analysis TEXT,
        saved_at TEXT,
        is_favorite INTEGER DEFAULT 0,
        user_email TEXT
      )
    ''');

    // 2. Membuat Tabel Pengguna (Akun)
    // Kata kunci UNIQUE pada email mencegah satu email didaftarkan dua kali.
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        email TEXT UNIQUE,
        password TEXT,
        full_name TEXT,
        age INTEGER,
        education TEXT,
        created_at TEXT
      )
    ''');
  }

  // ==========================================================================
  // PENJELASAN SIDANG: FUNGSI PEMBUNGKUS CRUD UMUM (WRAPPER)
  // Tujuannya agar kode di Provider tidak perlu pusing menulis sintaks SQL mentah
  // setiap kali mau menyimpan data. Cukup panggil fungsi-fungsi bahasa Dart di bawah ini.
  // ==========================================================================

  /// Menyisipkan (Insert) data baru ke tabel. 
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database; // Minta koneksi dari singleton
    return await db.insert(table, row); // Jalankan bawaan sqflite
  }

  /// Mengambil (Select) banyak data. Mirip seperti "SELECT * FROM table WHERE..."
  Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  /// Memperbarui (Update) sebagian isi data.
  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  /// Menghapus (Delete) data berdasakan kondisi (where).
  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // ==========================================================================
  // PENJELASAN SIDANG: FUNGSI KHUSUS AUTENTIKASI LOGIN
  // Ini adalah contoh Custom Query yang memisahkan urusan Database dari UI/Provider.
  // ==========================================================================

  /// Dipakai saat Register: Mengecek apakah email tersebut sudah ada di tabel users.
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?', 
      whereArgs: [email], // Mengapa tanda tanya (?) ? Ini teknik keamanan Anti-SQL Injection.
      limit: 1, // Hemat performa, batasi 1 hasil saja.
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }

  /// Dipakai saat Login: Mencocokkan Email DAN Password sekaligus.
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      // AND berarti keduanya (email & password) HARUS TEPAT SAMA.
      where: 'email = ? AND password = ?',
      whereArgs: [email, password], 
      limit: 1,
    );
    if (results.isNotEmpty) return results.first; 
    return null; 
  }
}
