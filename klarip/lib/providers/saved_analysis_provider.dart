// ==============================================================================
// PENJELASAN UNTUK SIDANG: SAVED ANALYSIS PROVIDER
// ==============================================================================
// Bapak/Ibu Penguji, file `saved_analysis_provider.dart` ini adalah pengelola
// State (State Management) untuk fitur Koleksi/Riwayat analisis di aplikasi Klarip.
// Kami menggunakan arsitektur Provider (dari package flutter 'provider').
//
// KONSEP UTAMA: STATE MANAGEMENT
// - Mengapa butuh Provider? Jika kita hapus riwayat di halaman A, halaman B harus
//   otomatis tahu dan memperbarui tampilannya tanpa perlu kita coding secara manual
//   untuk me-refresh halaman B. Inilah tugas Provider (menggunakan `notifyListeners()`).
//
// OPERASI YANG DIDUKUNG (CRUD - Create, Read, Update, Delete):
// - CREATE  : Menyimpan hasil analisis baru ke database (addAnalysis)
// - READ    : Memuat semua riwayat dari database khusus milik user yang login (loadAnalyses)
// - UPDATE  : Mengedit catatan pribadi & menekan tombol favorit (updateNote, toggleFavorite)
// - DELETE  : Menghapus satu riwayat dari memori dan database (deleteAnalysis)
//
// FITUR TAMBAHAN UNTUK SIDANG:
// - Terdapat fitur Export (ke JSON) dan Import untuk mem-backup riwayat.
// - Menggunakan Optimistic Update saat menekan tombol favorit agar UI terasa sangat cepat.
// ==============================================================================

import 'dart:convert'; // Untuk encode/decode teks JSON saat proses export/import.
import 'package:flutter/material.dart'; // Dibutuhkan untuk class ChangeNotifier.
import 'package:shared_preferences/shared_preferences.dart'; // Untuk membaca sesi email user yang sedang login.
import '../models/saved_analysis.dart'; // Blueprint/Model dari data riwayat analisis.
import '../services/database_helper.dart'; // Kelas penghubung ke database SQLite lokal.

/// PENJELASAN SIDANG:
/// Kelas ini adalah 'Jantung' dari fitur Koleksi.
/// Kelas ini 'extends ChangeNotifier', yang artinya kelas ini bisa "berteriak" (lewat notifyListeners())
/// ke seluruh halaman UI jika ada data yang berubah, sehingga UI langsung me-refresh diri sendiri.
class SavedAnalysisProvider extends ChangeNotifier {
  // PENJELASAN SIDANG:
  // Ini adalah penyimpanan sementara (memori RAM) dari daftar riwayat yang dimuat dari database.
  // Dibuat private (diawali '_') agar tidak sembarangan diubah oleh kelas lain dari luar.
  List<SavedAnalysis> _analyses = [];

  // Variabel untuk melacak apakah aplikasi sedang sibuk memuat data (loading).
  bool _isLoading = false;

  // === GETTERS ===
  // Cara aman agar kelas lain (seperti UI) bisa membaca data tanpa bisa mengubahnya.
  List<SavedAnalysis> get analyses => _analyses; 
  bool get isLoading => _isLoading;

  // Membuat perwakilan dari DatabaseHelper untuk mengeksekusi perintah SQL.
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// PENJELASAN SIDANG (FUNGSI READ):
  /// Fungsi `loadAnalyses` bertugas mengambil data dari database SQLite.
  /// Fitur Keamanan: Fungsi ini HANYA memuat riwayat milik pengguna yang saat ini login.
  /// Ini dicek dari email yang tersimpan di `SharedPreferences`.
  Future<void> loadAnalyses() async {
    _isLoading = true; // Nyalakan loading
    notifyListeners(); // Beritahu UI agar menampilkan ikon loading (CircularProgressIndicator)

    try {
      // 1. Cek siapa yang sedang login sekarang.
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? '';

      // 2. Ambil data dari database SQLite
      // PENJELASAN SIDANG: Perintah 'WHERE' di sini memastikan data tidak bocor ke user lain.
      final data = await _dbHelper.queryAll(
        'saved_analyses',
        where: 'user_email = ?', 
        whereArgs: [userEmail],
      );

      // 3. Ubah format dari Database (Map) menjadi format Objek (SavedAnalysis) yang mudah dipakai UI.
      _analyses = data.map((e) => SavedAnalysis.fromMap(e)).toList();

      // 4. Urutkan riwayat: Favorit di atas, lalu urut berdasarkan tanggal paling baru.
      _sortAnalyses();
    } catch (e) {
      debugPrint('Error memuat data: $e');
    }

    _isLoading = false; // Matikan loading
    notifyListeners(); // Beritahu UI bahwa data siap ditampilkan
  }

  /// PENJELASAN SIDANG:
  /// Fungsi private (hanya dipakai di dalam kelas ini) untuk mengurutkan (Sorting).
  /// Aturan urutannya:
  /// 1. Data yang status 'isFavorite' nya TRUE, dipaksa naik ke urutan teratas.
  /// 2. Jika status favoritnya sama, maka diurutkan dari yang paling baru disimpan (Descending).
  void _sortAnalyses() {
    _analyses.sort((a, b) {
      // Jika A favorit dan B tidak -> A ditaruh di atas (-1)
      if (a.isFavorite && !b.isFavorite) return -1;
      // Jika B favorit dan A tidak -> B ditaruh di atas (1)
      if (!a.isFavorite && b.isFavorite) return 1;
      // Jika sama, bandingkan tanggalnya
      return b.savedAt.compareTo(a.savedAt);
    });
  }

  /// PENJELASAN SIDANG (FUNGSI CREATE):
  /// Menyimpan hasil analisis baru dari halaman Utama ke halaman Koleksi (Database).
  Future<void> addAnalysis(SavedAnalysis analysis) async {
    try {
      // Sama seperti READ, saat CREATE kita juga "menyuntikkan" (inject) email pengguna
      // ke dalam data, agar data ini terikat secara eksklusif ke akun pengguna saat ini.
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? '';
      
      final newAnalysis = analysis.copyWith(userEmail: userEmail);

      // Jalankan perintah INSERT ke SQLite
      await _dbHelper.insert('saved_analyses', newAnalysis.toMap());

      // Panggil loadAnalyses agar data terbaru langsung muncul di list.
      await loadAnalyses();
    } catch (e) {
      debugPrint('Error menyimpan analisis: $e');
    }
  }

  /// PENJELASAN SIDANG (FUNGSI DELETE):
  /// Menghapus satu item dari riwayat Koleksi berdasarkan ID unik-nya.
  Future<void> deleteAnalysis(int id) async {
    try {
      // Hapus secara permanen dari tabel SQLite
      await _dbHelper.delete('saved_analyses', 'id = ?', [id]);

      // PENJELASAN SIDANG:
      // Daripada memanggil `loadAnalyses` dan query ulang seluruh database (yang boros memori),
      // kita cukup hapus data dari variabel 'List _analyses' di memori RAM, lalu panggil notifyListeners().
      // Ini jauh lebih efisien dan cepat!
      _analyses.removeWhere((element) => element.id == id);
      notifyListeners(); 
    } catch (e) {
      debugPrint('Error menghapus analisis: $e');
    }
  }

  /// PENJELASAN SIDANG (FUNGSI UPDATE 1):
  /// Mengizinkan user untuk mengedit kolom catatan pribadi pada riwayat mereka.
  Future<void> updateNote(int id, String newNote) async {
    try {
      // Update di SQLite: Ubah isi kolom 'user_note'
      await _dbHelper.update(
        'saved_analyses',
        {'user_note': newNote},
        'id = ?',
        [id],
      );

      // Sekali lagi, gunakan efisiensi dengan hanya mengubah list di memori lalu memberitahu UI.
      final index = _analyses.indexWhere((element) => element.id == id);
      if (index != -1) {
        _analyses[index] = _analyses[index].copyWith(userNote: newNote);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error memperbarui catatan: $e');
    }
  }

  /// PENJELASAN SIDANG (FUNGSI UPDATE 2 - TEKNIK LANJUTAN):
  /// Fungsi `toggleFavorite` dipanggil saat user menekan icon Bintang (Favorit).
  ///
  /// KONSEP: OPTIMISTIC UPDATE.
  /// Jika kita menunggu database selesai di-update baru me-refresh UI, tombol Bintang
  /// akan terasa ada 'jeda' (lag). Dengan Optimistic Update, kita ubah warna tombol
  /// di UI terlebih dahulu dengan memanipulasi List memori, baru di belakang layar (background)
  /// kita perbarui databasenya. Ini membuat aplikasi terasa sangat "snappy" (responsif).
  Future<void> toggleFavorite(int id) async {
    final index = _analyses.indexWhere((element) => element.id == id);
    if (index != -1) {
      // Balik nilai statusnya (Jika True jadi False, jika False jadi True)
      final newValue = !_analyses[index].isFavorite;
      final updatedItem = _analyses[index].copyWith(isFavorite: newValue);

      // --- AWAL OPTIMISTIC UPDATE ---
      // Update memori dan beritahu UI SEKARANG JUGA
      _analyses[index] = updatedItem;
      _sortAnalyses(); // Urutkan ulang karena status favorit berubah
      notifyListeners(); 
      // --- AKHIR OPTIMISTIC UPDATE ---

      // --- PROSES BACKGROUND (Database) ---
      try {
        await _dbHelper.update(
          'saved_analyses',
          {'is_favorite': newValue ? 1 : 0}, // SQLite tidak punya boolean, pakai integer 1/0
          'id = ?',
          [id],
        );
      } catch (e) {
        debugPrint('Error mengubah favorit: $e');
      }
    }
  }

  // ==========================================================================
  // FITUR EKSPOR / IMPOR (PENJELASAN SIDANG)
  // Fitur ini memungkinkan pengguna untuk mem-backup data mereka sendiri ke 
  // bentuk teks JSON, lalu me-restore-nya di perangkat lain jika pindah HP.
  // ==========================================================================

  /// Mengubah seluruh tabel database menjadi String panjang berformat JSON.
  String exportToJson() {
    final exportData = {
      'app': 'klarip', // 'Watermark' bahwa JSON ini milik aplikasi Klarip
      'version': '2.4.0',
      'exported_at': DateTime.now().toIso8601String(), // Waktu backup
      'total': _analyses.length,
      'data': _analyses.map((a) {
        final map = a.toMap();
        // PENJELASAN SIDANG: 
        // Kenapa ID-nya dihapus saat di-export?
        // Karena ID adalah Auto-Increment (dibuat urut oleh SQLite lokal). 
        // Jika kita pindah ke HP lain yang mungkin sudah punya data sendiri, ID-nya bisa bentrok.
        map.remove('id'); 
        return map;
      }).toList(),
    };
    // Menggunakan JsonEncoder.withIndent agar hasil teks JSON tidak berantakan
    // melainkan rapi dan mudah dibaca (pretty-print).
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Menerima teks String JSON (biasanya dari clipboard/paste) dan memasukkannya ke SQLite.
  Future<int> importFromJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString); // Teks JSON diubah kembali jadi format Map Dart

      // 1. Keamanan Sederhana: Memeriksa apakah formatnya benar dan apakah file ini milik Klarip.
      if (decoded is! Map<String, dynamic> || decoded['app'] != 'klarip') {
        throw FormatException('File ini bukan backup Klarip atau formatnya tidak valid');
      }

      final dataList = decoded['data'] as List<dynamic>?;
      if (dataList == null || dataList.isEmpty) return 0; // Tidak ada data untuk diimpor

      // 2. Mencegah Data Ganda (Duplikat).
      // Kami memuat klaim yang sudah ada, lalu mengubahnya menjadi tipe data `Set`
      // agar proses pencarian saat pengecekan duplikat jauh lebih cepat daripada List.
      await loadAnalyses();
      final existingClaims = _analyses.map((a) => a.claim.trim()).toSet();

      int importedCount = 0; // Variabel pelacak jumlah berhasil impor

      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? '';

      // 3. Proses perulangan untuk memasukkan tiap item backup ke Database
      for (final item in dataList) {
        try {
          final map = item as Map<String, dynamic>;
          // Pastikan data backup yang masuk 'diklaim' kepemilikannya oleh user yang sedang login
          final analysis = SavedAnalysis.fromMap(map).copyWith(userEmail: userEmail);

          // Pengecekan Duplikat: Jika klaim ini sudah ada di HP, lewati saja (skip).
          if (existingClaims.contains(analysis.claim.trim())) continue;

          // Hapus ID (kalau masih ada) dan serahkan ke SQLite untuk membuat ID baru.
          final insertMap = analysis.toMap();
          insertMap.remove('id');
          await _dbHelper.insert('saved_analyses', insertMap);

          // Masukkan ke 'Set' daftar duplikat agar jika ada data kembar di dalam file backup itu sendiri, bisa terdeteksi.
          existingClaims.add(analysis.claim.trim()); 
          importedCount++; // Tambah 1 keberhasilan
        } catch (e) {
          debugPrint('Gagal mengimpor 1 item: $e');
        }
      }

      // Setelah selesai memborbardir database, muat ulang (refresh) UI dengan data gabungan terbaru.
      await loadAnalyses();
      return importedCount;
    } catch (e) {
      debugPrint('Error saat proses impor: $e');
      rethrow; // Lempar pesan error ke halaman UI agar user tahu
    }
  }
}

