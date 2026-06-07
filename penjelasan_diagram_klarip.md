# Narasi Penjelasan Diagram Perancangan Alur Kerja Sistem
## (Untuk Disalin ke BAB 4 Sub-bab 2b Skripsi Anda)

Berikut adalah teks narasi akademik yang menjelaskan kelima gambar diagram yang sudah dibuat sebelumnya. Silakan letakkan teks ini tepat di bawah setiap gambar diagram yang relevan di dokumen Microsoft Word skripsi Anda.

---

### Penjelasan Diagram 1: Use Case Diagram

*Letakkan narasi ini di bawah **Gambar Use Case Diagram**.*

**Penjelasan Alur:**
*Use Case Diagram* di atas mendeskripsikan interaksi antara aktor (Pengguna dari demografi Generasi Z) dengan fungsionalitas sistem pada aplikasi Klarip. Pengguna memiliki akses ke sebelas fitur fungsional utama, yang meliputi pendaftaran akun, login, pengelolaan profil, penggantian kata sandi, hingga manajemen riwayat koleksi (melihat, memfavoritkan, mengedit catatan, dan menghapus). 

Fitur krusial dalam sistem ini adalah "Verifikasi Klaim Berita" (UC3). Pada proses ini, terdapat relasi *include* yang menunjukkan bahwa saat pengguna mengeksekusi proses verifikasi klaim, aplikasi secara otomatis akan bergantung pada dan memanggil dua layanan pihak ketiga (*External Services*), yaitu layanan pencarian terfilter Google Custom Search Engine (CSE) API dan model bahasa komputasi Google Gemini 2.5 Flash-Lite API. Selain itu, fitur "Menyimpan Hasil Verifikasi" memiliki relasi *extend*, yang berarti penyimpanan ke basis data lokal (SQLite) dapat dipicu sebagai kelanjutan dari proses verifikasi jika pengguna menghendakinya.

---

### Penjelasan Diagram 2: Flowchart Sistem Aplikasi Klarip

*Letakkan narasi ini di bawah **Gambar Flowchart Sistem** yang baru Anda lampirkan.*

**Penjelasan Alur:**
Flowchart ini merepresentasikan alur logika menyeluruh dari aplikasi Klarip secara terstruktur. Proses diawali saat pengguna membuka aplikasi, di mana sistem secara otomatis akan melakukan pengecekan status "*Sudah pernah Login?*". Jika belum (Tidak), pengguna akan diarahkan ke blok **Gerbang Masuk & Navigasi Utama**, tepatnya pada kotak *Halaman Autentikasi*. Di tahap ini, aplikasi memverifikasi apakah pengguna "*Punya Akun?*". Jika belum, pengguna akan diarahkan ke *Halaman Register*. Jika sudah, pengguna masuk dengan menginput Email dan Kata Sandi. Sistem lalu memvalidasi "*Kredensial apakah Valid?*". Jika kredensial salah, sistem memunculkan error kredensial dan menahan pengguna di halaman login. Jika valid (Ya), sistem akan menyimpan Sesi & Token lalu meneruskan alur ke Menu Utama.

Apabila pada awal pengecekan pengguna dipastikan sudah memiliki sesi login yang aktif (Ya), alur akan memotong kompas (bypass) dan langsung melompat ke **Menu Utama (*HomeShell / Dashboard*)**. Pada titik *Pilih navigasi Tab Menu* ini, sistem mendistribusikan pengguna ke dalam tiga modul fungsional utama yang berada di dalam lingkup **Modul Alur Aplikasi (Dashboard Shell)**:
1. **Menu Cari & Verifikasi:** Alur dieksekusi bermula dari *Input Klaim & Cari*. Sistem terlebih dahulu mengevaluasi blok putusan *Cek rate limit / cooldown*. Jika eksekusi terdeteksi bersifat *spamming* (Tidak aman), aplikasi menolak permintaan dengan memberikan *Error Cooldown* dan meminta pengguna mengulang input. Jika jeda waktu aman, sistem mengeksekusi proses komputasi utama, yakni *HTTP Req CSE + Gemini*. Hasil dari komputasi tersebut dikembalikan ke antarmuka dalam wujud *Tampil Verdict (3-Tier State)* yang mengklasifikasikan kebenaran klaim.
2. **Halaman Koleksi:** Modul ini bertugas merender riwayat (*Tampil analisa*). Saat terdapat *Aksi Pengguna?*, sistem mendeteksi jenis interaksi dan mengarahkannya ke salah satu dari empat fungsi operasional: *Edit catatan*, *Lihat Detail*, operasi *Hapus*, atau pengubahan *status Favorit*.
3. **Profil & Pengaturan:** Pengguna yang mengakses *Halaman Profil* memiliki tiga pilihan *Aksi Pengguna?*. Mereka dapat memodifikasi data diri (*Update Profil*), memperbarui lapisan keamanan (*Ganti Password*), atau memutus akses melalui opsi *Keluar & Sesi*. Memilih opsi keluar (logout) secara otomatis akan mendepak pengguna kembali ke blok *Halaman Autentikasi*. Seluruh interaksi ini pada akhirnya akan bermuara pada titik terminal *Selesai*.

---

### Penjelasan Diagram 3: Sequence Diagram (Khusus Alur Verifikasi Klaim)

*Letakkan narasi ini di bawah **Gambar Sequence Diagram Verifikasi Klaim**.*

**Penjelasan Alur:**
Diagram Sekuens (*Sequence Diagram*) Verifikasi Klaim menitikberatkan pada detail kronologis pertukaran pesan komputasi yang beroperasi di belakang layar (*behind-the-scenes*) saat aplikasi dihadapkan pada masukan klaim dari pengguna. Proses diprakarsai oleh pengguna yang menekan tombol "Cari". Aplikasi Flutter melalui lapisan *Provider* pertama-tama melakukan validasi *Rate-Limit* untuk mencegah penumpukan kueri eksesif (Spamming). 

Bila berada pada rentang waktu yang direstui, sistem merender *Skeleton Loading* untuk memberikan *feedback* antarmuka, dilanjutkan dengan pelemparan protokol `HTTP GET` menuju Google CSE. Saat metadata perolehan bukti (judul, tautan, dan *snippet*) berhasil ditarik, sistem beralih mengirimkan kueri `POST` terstruktur menuju model Gemini AI dengan teknik *Retrieval-Augmented Generation* (RAG)—yakni menyertakan bukti web ke dalam perintah agar AI tidak mengalami halusinasi. Sebagai produk akhir, Gemini mengembalikan objek JSON yang merepresentasikan putusan 3 strata (*3-Tier Verdict*), yang kemudian langsung dipersistensikan ke memori lokal via *query* INSERT SQLite sebelum ditransformasikan secara utuh ke representasi visual aplikasi.

---

### Penjelasan Diagram 4: Sequence Diagram (Operasi CRUD Koleksi)

*Letakkan narasi ini di bawah **Gambar Sequence Diagram CRUD Koleksi**.*

**Penjelasan Alur:**
Diagram Sekuens ini menggambarkan bagaimana antarmuka Flutter berinteraksi dengan kelas manajemen basis data (*DatabaseHelper*) dan pengontrol (*SavedAnalysisProvider*) untuk menjalankan empat tugas CRUD (*Create, Read, Update, Delete*) pada tabel `saved_analyses` di SQLite.
1. **Skenario Read:** Sistem mengkueri keseluruhan riwayat berdasar email pengguna dan menyortirnya secara dinamis sehingga koleksi bertanda bintang (favorit) dan termutakhir tampil paling atas. 
2. **Skenario Update (Favorit & Catatan):** Pendekatan pembaruan memanfaatkan konsep *Optimistic Update*, di mana antarmuka (UI) akan merender pembaruan ikon bintang atau teks seketika sebelum baris data pada SQLite selesai dimodifikasi dengan klausa SET, sehingga menciptakan rasa responsif seketika. 
3. **Skenario Delete:** Sistem mengeluarkan dialog konfirmasi untuk mengeksekusi kueri penghapusan mutlak pada baris parameter ID terkait, guna memastikan tak ada memori yang tertinggal.

---

### Penjelasan Diagram 5: Sequence Diagram (Operasi CRUD Data Pengguna)

*Letakkan narasi ini di bawah **Gambar Sequence Diagram CRUD Data Pengguna**.*

**Penjelasan Alur:**
Diagram sekuens terakhir ini merepresentasikan bagaimana autentikasi luring berjalan tanpa ketergantungan pada layanan backend terpusat. Keamanan kredensial sepenuhnya divalidasi ke dalam tabel `users` di basis data SQLite lokal.
1. **Skenario Create (Register):** Sebelum memasukkan data (*insert*) identitas baru, pengontrol (*AuthProvider*) wajib melakukan uji validasi redundansi menggunakan kueri pemilahan untuk memastikan alamat email belum diregistrasi sebelumnya. Jika valid, pengguna dicatat dan sesi otomatis dibuatkan.
2. **Skenario Read (Login):** Autentikasi dicocokkan menggunakan dua pilar parameter (email dan kata sandi). Kesuksesan login akan memicu aplikasi merantai sesi ke penyimpanan bawaan ponsel (*SharedPreferences*), yang memungkinkan kelestarian akses walau aplikasi ditutup.
3. **Skenario Update (Profil & Sandi):** Modifikasi data pribadi atau transisi kata sandi memicu pembaruan pada *state* manajemen internal `_currentUser` yang selaras dengan keberhasilan pembaruan basis data (UPDATE query). Khusus penggantian kata sandi, operasi harus melewati filter validasi ketat pencocokan kata sandi lawas sebelum kueri eksekusi akhir dijalankan.
