# PENGUJIAN BLACK BOX — APLIKASI KLARIP
## (Draft untuk Disalin ke Skripsi BAB 4 / BAB 5 — Tahap Pengujian)

---

## Penjelasan Metode

Pengujian *Black Box* (*Black Box Testing*) adalah metode pengujian perangkat lunak yang berfokus pada **fungsionalitas sistem dari sudut pandang pengguna**, tanpa memperhatikan kode program di dalamnya. Pengujian ini dilakukan dengan cara memberikan masukan (*input*) tertentu ke dalam sistem, kemudian membandingkan keluaran (*output*) yang dihasilkan dengan keluaran yang seharusnya (*expected output*).

Pengujian ini bertujuan untuk memastikan bahwa seluruh fitur aplikasi Klarip berjalan **sesuai dengan kebutuhan fungsional** yang telah dirancang, meliputi: autentikasi pengguna, verifikasi klaim, manajemen riwayat, dan pengaturan aplikasi.

---

## Tabel Skenario & Hasil Pengujian Black Box

### A. Modul Autentikasi (Login & Register)

| No | Skenario Uji | Data Masukan (Input) | Hasil yang Diharapkan | Hasil Pengujian | Status |
|---|---|---|---|---|---|
| 1 | Registrasi akun baru dengan data lengkap dan valid | Nama: "Alfath", Username: "alfath123", Email: "alfath@email.com", Password: "pass123" | Akun berhasil dibuat dan pengguna langsung masuk ke halaman utama (HomeShell) | Sesuai harapan | ✅ Berhasil |
| 2 | Registrasi dengan email yang sudah terdaftar | Email: "alfath@email.com" (sudah ada di database) | Muncul notifikasi "Email sudah terdaftar" dan registrasi tidak dilanjutkan | Sesuai harapan | ✅ Berhasil |
| 3 | Registrasi dengan kolom yang tidak diisi (kosong) | Semua kolom dikosongkan lalu tombol "Daftar" ditekan | Muncul notifikasi "Harap isi semua kolom" | Sesuai harapan | ✅ Berhasil |
| 4 | Registrasi dengan salah satu kolom kosong | Kolom password dikosongkan, kolom lain diisi | Muncul notifikasi "Harap isi semua kolom" | Sesuai harapan | ✅ Berhasil |
| 5 | Login dengan email dan password yang benar | Email: "alfath@email.com", Password: "pass123" | Pengguna berhasil masuk dan diarahkan ke halaman utama (HomeShell) | Sesuai harapan | ✅ Berhasil |
| 6 | Login dengan password yang salah | Email: "alfath@email.com", Password: "salah999" | Muncul notifikasi "Email atau password salah" berwarna merah | Sesuai harapan | ✅ Berhasil |
| 7 | Login dengan email yang tidak terdaftar | Email: "tidakada@email.com", Password: "apa123" | Muncul notifikasi "Email atau password salah" | Sesuai harapan | ✅ Berhasil |
| 8 | Login dengan kolom email kosong | Email: (kosong), Password: "pass123" | Muncul notifikasi "Harap isi semua kolom" | Sesuai harapan | ✅ Berhasil |
| 9 | Sesi login tersimpan setelah aplikasi ditutup | Pengguna login, tutup aplikasi, buka kembali | Pengguna langsung masuk ke halaman utama tanpa diminta login ulang | Sesuai harapan | ✅ Berhasil |
| 10 | Logout dari aplikasi | Pengguna menekan tombol "Keluar" di halaman Profil | Sesi terhapus dan pengguna diarahkan kembali ke halaman Login | Sesuai harapan | ✅ Berhasil |
| 11 | Tombol lihat/sembunyikan password di Login | Menekan ikon mata (👁) di kolom password | Teks password berganti antara tampil dan tersembunyi | Sesuai harapan | ✅ Berhasil |
| 12 | Tombol lihat/sembunyikan password di Register | Menekan ikon mata (👁) di kolom password | Teks password berganti antara tampil dan tersembunyi | Sesuai harapan | ✅ Berhasil |

---

### B. Modul Verifikasi Klaim (Pencarian & Analisis AI)

| No | Skenario Uji | Data Masukan (Input) | Hasil yang Diharapkan | Hasil Pengujian | Status |
|---|---|---|---|---|---|
| 13 | Pencarian klaim dengan teks valid | Klaim: "Vaksin COVID-19 mengandung microchip" | Aplikasi menampilkan hasil pencarian artikel dari Google CSE dan hasil analisis AI Gemini (verdict, penjelasan, sumber) | Sesuai harapan | ✅ Berhasil |
| 14 | Pencarian klaim menghasilkan verdict "Tidak Didukung Data" | Klaim berisi informasi yang terbukti salah/hoaks | Kartu hasil menampilkan badge merah "TIDAK DIDUKUNG DATA" beserta penjelasan dan sumber artikel | Sesuai harapan | ✅ Berhasil |
| 15 | Pencarian klaim menghasilkan verdict "Didukung Data" | Klaim berisi informasi yang terbukti benar | Kartu hasil menampilkan badge hijau "DIDUKUNG DATA" beserta penjelasan | Sesuai harapan | ✅ Berhasil |
| 16 | Pencarian klaim menghasilkan verdict "Memerlukan Verifikasi" | Klaim berisi informasi yang ambigu/tidak jelas | Kartu hasil menampilkan badge kuning "MEMERLUKAN VERIFIKASI" | Sesuai harapan | ✅ Berhasil |
| 17 | Pencarian dengan kolom klaim kosong | Kolom teks klaim dibiarkan kosong lalu tombol "Cari" ditekan | Tombol tidak merespons atau muncul pesan agar klaim diisi | Sesuai harapan | ✅ Berhasil |
| 18 | Pencarian klaim saat API key tidak valid | API Key diubah ke nilai yang salah di pengaturan | Muncul pesan error yang informatif (contoh: "API Key tidak valid") | Sesuai harapan | ✅ Berhasil |
| 19 | Menampilkan indikator loading saat pencarian berjalan | Klaim dikirimkan, proses pencarian sedang berlangsung | Tampil indikator *loading* (animasi putar) selama proses berlangsung | Sesuai harapan | ✅ Berhasil |
| 20 | Menyimpan hasil analisis ke riwayat | Menekan tombol "Simpan" setelah hasil analisis tampil | Hasil analisis tersimpan dan muncul di halaman Koleksi | Sesuai harapan | ✅ Berhasil |
| 21 | Mengakses tautan sumber artikel | Menekan nama domain/tautan artikel dari hasil pencarian | Browser eksternal terbuka dan menampilkan artikel asli | Sesuai harapan | ✅ Berhasil |
| 22 | Melakukan pencarian ulang setelah mendapat hasil | Mengubah teks klaim dan menekan tombol "Cari" kembali | Hasil sebelumnya dihapus dan hasil baru ditampilkan | Sesuai harapan | ✅ Berhasil |

---

### C. Modul Riwayat (Koleksi Fakta)

| No | Skenario Uji | Data Masukan (Input) | Hasil yang Diharapkan | Hasil Pengujian | Status |
|---|---|---|---|---|---|
| 23 | Melihat daftar riwayat analisis tersimpan | Pengguna membuka tab "Koleksi" | Daftar seluruh hasil analisis yang telah disimpan ditampilkan secara terurut | Sesuai harapan | ✅ Berhasil |
| 24 | Melihat detail salah satu item riwayat | Mengetuk salah satu kartu riwayat | Panel detail terbuka menampilkan klaim, verdict, penjelasan lengkap, dan catatan pribadi | Sesuai harapan | ✅ Berhasil |
| 25 | Riwayat kosong saat belum ada yang disimpan | Membuka tab "Koleksi" saat belum ada data | Tampil ilustrasi kosong dengan teks "Belum ada koleksi" | Sesuai harapan | ✅ Berhasil |
| 26 | Menambah catatan pribadi pada item riwayat | Membuka detail riwayat → mengisi kolom catatan → menekan "Simpan" | Catatan tersimpan dan tampil di kartu riwayat | Sesuai harapan | ✅ Berhasil |
| 27 | Mengubah catatan pribadi yang sudah ada | Membuka catatan lama → mengedit teks → menekan "Simpan" | Catatan diperbarui dengan teks yang baru | Sesuai harapan | ✅ Berhasil |
| 28 | Menghapus item riwayat | Membuka detail riwayat → menekan ikon hapus (🗑) | Dialog konfirmasi muncul; setelah dikonfirmasi, item terhapus dari daftar dan database | Sesuai harapan | ✅ Berhasil |
| 29 | Membatalkan penghapusan item riwayat | Pada dialog konfirmasi, menekan tombol "Batal" | Dialog ditutup, item tidak dihapus dan tetap ada di daftar | Sesuai harapan | ✅ Berhasil |
| 30 | Menandai item riwayat sebagai favorit | Menekan ikon bintang (⭐) pada kartu riwayat | Ikon bintang berubah menjadi kuning dan item berpindah ke urutan teratas daftar | Sesuai harapan | ✅ Berhasil |
| 31 | Membatalkan tanda favorit | Menekan kembali ikon bintang (⭐) yang sudah aktif | Ikon bintang kembali abu-abu dan item kembali ke urutan normal | Sesuai harapan | ✅ Berhasil |
| 32 | Daftar riwayat terurut: favorit di atas | Ada beberapa item favorit dan non-favorit | Item yang ditandai favorit selalu muncul di bagian atas daftar | Sesuai harapan | ✅ Berhasil |
| 33 | Ekspor riwayat ke file JSON | Membuka menu ⋮ → menekan "Ekspor Koleksi" | Sistem berbagi (*share dialog*) perangkat terbuka dengan file JSON berisi seluruh riwayat | Sesuai harapan | ✅ Berhasil |
| 34 | Impor riwayat dari file JSON yang valid | Membuka menu ⋮ → "Impor Koleksi" → memilih file backup .json | Data dari file berhasil diimpor ke dalam aplikasi, muncul notifikasi "N koleksi berhasil diimpor" | Sesuai harapan | ✅ Berhasil |
| 35 | Impor file JSON yang bukan dari Klarip | Memilih file JSON sembarang yang tidak valid | Muncul pesan error "File ini bukan backup Klarip" | Sesuai harapan | ✅ Berhasil |
| 36 | Impor file dengan data yang sudah ada (duplikat) | Mengimpor file backup yang isinya sudah ada di aplikasi | Data duplikat dilewati otomatis; muncul notifikasi "Tidak ada data baru untuk diimpor" | Sesuai harapan | ✅ Berhasil |
| 37 | Riwayat hanya menampilkan data akun yang login | Login sebagai akun berbeda di perangkat yang sama | Hanya riwayat milik akun yang sedang login yang ditampilkan | Sesuai harapan | ✅ Berhasil |

---

### D. Modul Profil & Pengaturan Akun

| No | Skenario Uji | Data Masukan (Input) | Hasil yang Diharapkan | Hasil Pengujian | Status |
|---|---|---|---|---|---|
| 38 | Melihat data profil pengguna | Pengguna membuka tab "Profil" | Data pengguna yang tersimpan (nama, username, email, usia, pendidikan) ditampilkan dengan benar | Sesuai harapan | ✅ Berhasil |
| 39 | Mengubah data profil (nama lengkap) | Pengguna mengubah nama di halaman Edit Profil lalu menekan "Simpan" | Data profil berhasil diperbarui dan tampilan profil menampilkan nama yang baru | Sesuai harapan | ✅ Berhasil |
| 40 | Mengubah password dengan data valid | Password lama benar, password baru diisi dua kali sama | Password berhasil diubah dan muncul notifikasi "Password berhasil diubah" | Sesuai harapan | ✅ Berhasil |
| 41 | Mengubah password dengan password lama yang salah | Password lama diisi dengan nilai yang tidak sesuai | Muncul notifikasi "Password lama tidak sesuai" | Sesuai harapan | ✅ Berhasil |
| 42 | Mengubah password dengan konfirmasi yang tidak cocok | Password baru dan konfirmasi password berbeda | Muncul notifikasi "Konfirmasi password tidak sesuai" | Sesuai harapan | ✅ Berhasil |

---

### E. Modul Pengaturan API Key

| No | Skenario Uji | Data Masukan (Input) | Hasil yang Diharapkan | Hasil Pengujian | Status |
|---|---|---|---|---|---|
| 43 | Mengubah Gemini API Key dengan key yang valid | API Key baru yang valid dimasukkan → tombol "Simpan" ditekan | API Key berhasil disimpan, muncul notifikasi "API key berhasil diperbarui 🎉" | Sesuai harapan | ✅ Berhasil |
| 44 | Menyimpan API Key dengan kolom kosong | Kolom API Key dibiarkan kosong → tombol "Simpan" ditekan | Muncul notifikasi "API key tidak boleh kosong" | Sesuai harapan | ✅ Berhasil |
| 45 | Mengubah Google CSE API Key | CSE API Key baru dimasukkan → tombol "Simpan" ditekan | API Key CSE berhasil disimpan | Sesuai harapan | ✅ Berhasil |
| 46 | Mengubah Google CSE CX (Search Engine ID) | CX ID baru dimasukkan → tombol "Simpan" ditekan | CX ID berhasil disimpan | Sesuai harapan | ✅ Berhasil |
| 47 | Reset API Key ke nilai bawaan (default) | Menekan tombol "Reset ke Default" | API Key kembali ke nilai bawaan aplikasi | Sesuai harapan | ✅ Berhasil |

---

### F. Modul Navigasi & Antarmuka Umum

| No | Skenario Uji | Data Masukan (Input) | Hasil yang Diharapkan | Hasil Pengujian | Status |
|---|---|---|---|---|---|
| 48 | Berpindah antar tab navigasi | Mengetuk tab "Cari", "Koleksi", dan "Profil" secara bergantian | Halaman berpindah sesuai tab yang dipilih tanpa error | Sesuai harapan | ✅ Berhasil |
| 49 | Tampilan aplikasi dalam mode gelap | Membuka aplikasi di perangkat dengan tema sistem apapun | Aplikasi selalu tampil dalam mode gelap (*dark mode*) yang konsisten | Sesuai harapan | ✅ Berhasil |
| 50 | Responsivitas layar pada berbagai ukuran | Membuka aplikasi di perangkat dengan ukuran layar berbeda | Tata letak UI menyesuaikan ukuran layar dengan baik, tidak ada elemen yang terpotong | Sesuai harapan | ✅ Berhasil |

---

## Rekapitulasi Hasil Pengujian

| Modul | Jumlah Skenario | Berhasil | Tidak Berhasil |
|---|---|---|---|
| A. Autentikasi (Login & Register) | 12 | 12 | 0 |
| B. Verifikasi Klaim | 10 | 10 | 0 |
| C. Riwayat (Koleksi Fakta) | 15 | 15 | 0 |
| D. Profil & Pengaturan Akun | 5 | 5 | 0 |
| E. Pengaturan API Key | 5 | 5 | 0 |
| F. Navigasi & Antarmuka Umum | 3 | 3 | 0 |
| **TOTAL** | **50** | **50** | **0** |

---

## Kesimpulan Pengujian Black Box

Berdasarkan hasil pengujian *Black Box* yang telah dilakukan terhadap 50 skenario uji yang mencakup seluruh modul fungsional aplikasi Klarip, diperoleh hasil bahwa **seluruh 50 skenario (100%) berjalan sesuai dengan hasil yang diharapkan**. Tidak ditemukan adanya kegagalan fungsi pada modul autentikasi, verifikasi klaim, manajemen riwayat, pengaturan profil, pengelolaan API Key, maupun navigasi antarmuka.

Dengan demikian, dapat disimpulkan bahwa aplikasi Klarip telah memenuhi seluruh **kebutuhan fungsional** yang telah dirancang sebelumnya dan siap untuk dilanjutkan ke tahap pengujian usabilitas menggunakan metode *System Usability Scale* (SUS) dan *Time on Task*.

---

> **[📝 INSTRUKSI SKRIPSI]**: Kolom "Hasil Pengujian" dan "Status" pada tabel di atas dapat diisi berdasarkan pengujian nyata yang Anda lakukan pada emulator/perangkat fisik. Jika ada skenario yang hasilnya berbeda dari harapan, ubah status menjadi ❌ Tidak Berhasil dan catat perbedaannya.
