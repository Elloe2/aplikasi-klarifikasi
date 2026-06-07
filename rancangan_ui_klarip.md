# 2c. Perancangan User Interface (Antarmuka Pengguna)

Perancangan antarmuka pengguna (*User Interface*/UI) pada aplikasi Klarip ditujukan untuk menciptakan pengalaman visual yang modern, intuitif, dan nyaman bagi kelompok demografi Generasi Z. Mengingat pola konsumsi informasi Generasi Z yang serba cepat dan sangat mengutamakan estetika, aplikasi ini secara penuh mengadopsi pedoman desain **Material Design 3** dengan mengusung gaya *Dark Mode* (Mode Gelap) sebagai tema bawaan secara utuh.

### 1. Sistem Desain (Design System)
Pembangunan antarmuka aplikasi berpegang pada sistem desain yang konsisten di seluruh halaman untuk menjaga integritas visual:
- **Palet Warna:** Aplikasi menggunakan warna gradasi gelap `#121212` hingga `#1E1E1E` sebagai warna latar belakang (background) utama, dengan warna hijau `#1DB954` sebagai warna aksen primer. Warna ini dipilih karena merepresentasikan validitas, keamanan, dan interaksi positif.
- **Tipografi:** Seluruh elemen tekstual pada aplikasi dirender menggunakan keluarga fon **SpotifyMix**. Penggunaan fon khusus (custom font) yang memiliki 7 variasi ketebalan (weight) ini dipilih untuk memberikan kesan eksklusif, dinamis, dan familiar bagi demografi anak muda.
- **Komponen Visual:** Desain memanfaatkan elemen *Glassmorphism* transparan (opacity rendah) untuk kartu (card) atau panel, serta menerapkan sudut membulat (rounded corners) untuk memperhalus kontur tampilan.
- **Feedback Visual:** Untuk mencegah kebingungan saat aplikasi sedang melakukan pemanggilan API eksternal (proses komputasi Google CSE dan Gemini AI), sistem menghindari indikator loading konvensional dan menggantinya dengan efek *Skeleton Loading* yang jauh lebih interaktif.

---

### 2. Mockup Halaman Aplikasi

Berikut adalah penjabaran rancangan antarmuka untuk setiap halaman fungsional pada aplikasi Klarip yang dibangun menggunakan framework Flutter:

#### a. Halaman Masuk (Login) dan Daftar (Register)
Halaman autentikasi berfungsi sebagai gerbang validasi identitas sebelum pengguna dapat mengakses fitur utama aplikasi.

> **[📝 INSTRUKSI UNTUK SKRIPSI: Masukkan Screenshot Halaman Login & Register dari Emulator di sini]**
> *Gambar X. Tampilan Halaman Login dan Register*

**Komponen Utama Halaman:**
1. **Form Input (TextField):** Area untuk menginput Email dan Kata Sandi (untuk Login) serta isian tambahan seperti Nama Lengkap dan Username (untuk Register). Kolom input memiliki desain kontras minimalis dengan garis bawah yang menyala hijau ketika sedang difokuskan (active state).
2. **Tombol Aksi Utama:** Tombol solid berukuran penuh dengan aksen hijau ("Masuk" atau "Daftar") untuk mengeksekusi proses autentikasi ke SQLite.
3. **Navigasi Teks:** Tautan interaktif di bagian bawah form ("Belum punya akun? Daftar di sini" / "Sudah punya akun? Masuk") untuk mempermudah transisi perpindahan halaman.

#### b. Halaman Utama / Pencarian (Home / Search)
Halaman pencarian merupakan inti operasional (core) dari interaksi aplikasi, tempat di mana pengguna memasukkan teks klaim berita untuk diverifikasi.

> **[📝 INSTRUKSI UNTUK SKRIPSI: Masukkan Screenshot Halaman Tab Cari di sini]**
> *Gambar X. Tampilan Halaman Pencarian Klaim Berita*

**Komponen Utama Halaman:**
1. **Hero Header:** Teks sapaan di bagian atas yang menyapa pengguna secara dinamis berdasarkan nama lengkapnya, ditulis menggunakan tipografi tebal (bold).
2. **Kolom Teks (TextField) Klaim:** Area masukan multi-baris (multiline) yang luas dan lega, dirancang secara khusus agar pengguna leluasa menempelkan (paste) paragraf klaim hoaks yang panjang dari aplikasi lain.
3. **Tombol "Cari Fakta":** Tombol pemicu yang akan mengeksekusi pipeline asinkron: pengecekan rate-limit, ekstraksi Google CSE, hingga komputasi bahasa Gemini AI.
4. **Indikator Proses (Skeleton Loading):** Saat tombol pencarian ditekan, antarmuka di bawahnya akan menampilkan blok abu-abu yang beranimasi kedip dengan status beruntun (misal: "Mencari bukti..." transisi ke "Menganalisis kalimat...").

#### c. Tampilan Hasil Analisis AI (Verdict)
Hasil inferensi dari Gemini AI di-render di halaman yang sama (Home) menggunakan konsep panel lipat (ExpansionTile) agar pengguna tidak kehilangan konteks halaman.

> **[📝 INSTRUKSI UNTUK SKRIPSI: Masukkan Screenshot Hasil Analisis (Kotak Hijau/Merah) di sini]**
> *Gambar X. Tampilan Hasil Analisis AI dan Daftar Bukti Artikel*

**Komponen Utama Halaman:**
1. **Kartu Status (Verdict Card):** Kartu indikator visual yang menunjukkan kesimpulan tegas. Sistem merender tiga variasi warna berdasarkan respons AI: Hijau (Data Didukung), Merah (Tidak Didukung Data / Hoaks), dan Kuning (Perlu Verifikasi Lebih Lanjut).
2. **Panel Penjelasan AI:** Area teks komprehensif yang menjabarkan argumentasi logis dari Gemini AI mengenai alasan mengapa klaim tersebut masuk ke kategori status di atas.
3. **Daftar Bukti Artikel (Tiled Bukti):** Susunan tautan hiperteks (URL) artikel dari Google CSE yang menjadi landasan (context) bagi AI. Setiap tautan dapat diketuk oleh pengguna untuk membuka peramban web dan membaca artikel asli.
4. **Tombol Aksi Simpan:** Ikon simpan (bookmark) di sudut panel untuk merangkum hasil JSON ini dan memasukkannya ke dalam tabel *saved_analyses* SQLite.

#### d. Halaman Koleksi (Saved Analyses)
Halaman ini bertindak sebagai memori kognitif eksternal (cognitive offloading) yang menampung seluruh histori pengecekan fakta milik pengguna secara luring.

> **[📝 INSTRUKSI UNTUK SKRIPSI: Masukkan Screenshot Tab Koleksi di sini]**
> *Gambar X. Tampilan Halaman Riwayat Koleksi dan Menu Konteks*

**Komponen Utama Halaman:**
1. **Daftar Riwayat (ListView):** Kumpulan kartu hasil verifikasi terdahulu yang diurutkan secara hierarkis (item Favorit di posisi teratas, disusul berdasarkan urutan waktu simpan terbaru).
2. **Ikon Favorit (Toggle Bintang):** Ikon interaktif untuk menandai (pin) analisis berita yang dianggap sangat vital oleh pengguna.
3. **Menu Aksi (Context Menu):** Menu opsi tersembunyi untuk mengeksekusi operasi "Edit Catatan Pribadi" (menambah user note) atau operasi "Hapus" untuk membuang baris data secara permanen dari basis data lokal.

#### e. Halaman Profil & Pengaturan
Halaman terakhir pada *BottomNavigationBar* yang memuat informasi identitas dan manajemen keamanan pengguna.

> **[📝 INSTRUKSI UNTUK SKRIPSI: Masukkan Screenshot Tab Profil di sini]**
> *Gambar X. Tampilan Halaman Profil dan Pengaturan Keamanan*

**Komponen Utama Halaman:**
1. **Kartu Identitas Pengguna:** Menampilkan avatar inisial, nama lengkap, serta alamat email (username) pengguna yang sedang login (sesi aktif).
2. **Menu Pengaturan Akun (ListTile):** Antarmuka berbaris yang mengarahkan pengguna ke sub-halaman formulir "Edit Profil" (mengubah nama/username) dan sub-halaman formulir "Ganti Kata Sandi".
3. **Tombol Keluar (Logout):** Tombol merah (destructive action) untuk memusnahkan kredensial dari *SharedPreferences* dan memutus sesi secara aman.
