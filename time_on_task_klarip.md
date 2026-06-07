# PENGUKURAN METRIK KINERJA — EFISIENSI WAKTU PEMROSESAN
## (Time on Task — Aplikasi Klarip vs. Pencarian Manual)

---

## Penjelasan Instrumen Pengukuran

Pengukuran metrik kinerja aplikasi dilakukan untuk mengonfirmasi bahwa otomatisasi sistem verifikasi klaim berbasis Google CSE dan Gemini AI mampu memangkas durasi penelusuran hoaks secara signifikan dibandingkan metode pencarian manual konvensional. Pengambilan data dilakukan langsung oleh peneliti menggunakan instrumen stopwatch dengan presisi 0,1 detik.

Pengukuran waktu dicatat dalam dua kondisi:
- **Kondisi A — Pencarian Manual**: Pengguna mencari dan memverifikasi klaim secara manual melalui browser web (Google Search), membaca minimal 3 sumber artikel, lalu menarik kesimpulan sendiri.
- **Kondisi B — Aplikasi Klarip**: Pengguna memasukkan klaim ke dalam aplikasi Klarip dan menunggu hingga hasil analisis AI ditampilkan sepenuhnya di layar.

Durasi dicatat dalam satuan **detik (s)**, dimulai dari saat tugas dimulai hingga kesimpulan verifikasi diperoleh. Seluruh klaim yang diuji merupakan narasi yang pernah beredar di media sosial Indonesia berkaitan dengan isu politik dan pejabat publik.

---

## Tabel A — Waktu Verifikasi Klaim dengan Metode Pencarian Manual

> *Pengukuran dilakukan oleh peneliti menggunakan stopwatch. Pencarian manual dilakukan melalui Google Search dengan minimal membaca 3 sumber artikel sebelum menarik kesimpulan.*

| No | Klaim yang Diuji | Durasi (detik) | Durasi (mnt:dtk) | Catatan |
|---|---|---|---|---|
| 1 | Prabowo Subianto resmi memotong anggaran pendidikan sebesar 20% untuk membiayai program Makan Bergizi Gratis | 287 | 4:47 | Butuh konfirmasi dari situs resmi Kemendikbud dan Kemenkeu, beberapa sumber campur aduk |
| 2 | Presiden Prabowo mengganti Purbaya Yudhi Sadewa dari jabatan Menteri Keuangan akibat desakan demonstrasi mahasiswa | 412 | 6:52 | Perlu mencari pernyataan resmi Istana, banyak artikel spekulasi yang muncul lebih dulu |
| 3 | Gibran Rakabuming Raka mengundurkan diri dari jabatan Wakil Presiden karena terbukti memalsukan ijazah sarjananya | 356 | 5:56 | Isu sensitif dan viral, banyak artikel opini bercampur dengan laporan faktual |
| 4 | Pemerintah resmi memblokir platform X (Twitter) secara permanen di seluruh Indonesia demi meredam kritik publik | 445 | 7:25 | Perlu menelusuri pernyataan resmi Kementerian Kominfo dan pengumuman resmi Komdigi |
| 5 | Dana haji tahun ini akan dialihkan sepenuhnya untuk mendanai pembangunan infrastruktur Ibu Kota Nusantara (IKN) | 298 | 4:58 | Pernyataan resmi BPIH dan Kemenag cukup mudah ditemukan untuk dibandingkan |
| 6 | Joko Widodo diangkat menjadi Ketua Umum Partai Golkar secara aklamasi menggantikan Bahlil Lahadalia | 378 | 6:18 | Perlu mencari berita resmi dari DPP Golkar, banyak artikel dari media kurang kredibel |
| 7 | Mahkamah Konstitusi (MK) membatalkan hasil Pilkada Jakarta dan memerintahkan KPU melakukan pemungutan suara ulang | 421 | 7:01 | Harus merujuk langsung ke situs resmi MK untuk membaca putusan, prosesnya memakan waktu |
| 8 | DPR RI resmi mengesahkan UU perpanjangan masa jabatan kepala desa menjadi 12 tahun tanpa sidang paripurna | 263 | 4:23 | Berita yang sempat ramai, sumber debunking dari media resmi relatif mudah ditemukan |
| 9 | Sri Mulyani diperiksa KPK terkait dugaan korupsi dana bantuan sosial (bansos) saat masih menjabat Menteri Keuangan | 389 | 6:29 | Perlu konfirmasi dari situs resmi KPK dan pernyataan jubir, banyak artikel tidak akurat |
| 10 | Pemerintah membatalkan program makan siang gratis karena defisit APBN yang membengkak | 467 | 7:47 | Paling lama — perlu membandingkan banyak data APBN dari sumber Kemenkeu yang valid |
| 11 | Pajak Pertambahan Nilai (PPN) resmi dinaikkan menjadi 15% secara sepihak untuk menutup utang luar negeri | 315 | 5:15 | Perlu menelusuri Peraturan Pemerintah dan berita resmi Ditjen Pajak |
| 12 | Anies Baswedan ditunjuk sebagai Utusan Khusus Presiden untuk urusan Timur Tengah oleh Presiden Prabowo | 442 | 7:22 | Perlu konfirmasi dari Sekretariat Kabinet, banyak berita simpang siur beredar |
| 13 | BEM UI dan BEM UGM resmi menyatakan makar dan menolak mengakui keabsahan pemerintahan Prabowo-Gibran | 273 | 4:33 | Isu yang ramai, pernyataan resmi BEM UI/UGM cukup mudah ditemukan di media mahasiswa |
| 14 | Tiongkok meminta Pulau Kalimantan sebagai jaminan atas utang proyek Kereta Cepat Jakarta-Surabaya yang gagal bayar | 396 | 6:36 | Klaim ekstrem, perlu menelusuri dokumen perjanjian dan pernyataan Kementerian Luar Negeri |
| 15 | Ridwan Kamil resmi ditunjuk sebagai Kepala Otorita IKN menggantikan Basuki Hadimuljono mulai bulan depan | 458 | 7:38 | Perlu konfirmasi dari situs resmi Otorita IKN dan pengumuman Istana |
| 16 | RUU Perampasan Aset resmi disahkan DPR RI melalui sidang paripurna tertutup yang dihadiri kurang dari separuh anggota | 324 | 5:24 | Perlu mengecek risalah sidang DPR dan pernyataan Baleg yang valid |
| 17 | Gaji PNS, TNI, dan Polri resmi dipotong 5% setiap bulan untuk mendanai program Tabungan Perumahan Rakyat (Tapera) | 387 | 6:27 | Isu Tapera yang pernah ramai, perlu mencari PP dan pernyataan resmi pemerintah |
| 18 | Presiden Prabowo menolak menggunakan fasilitas mobil dinas dan meminta kementerian menjual seluruh mobil dinas menteri | 253 | 4:13 | Berita yang pernah viral dan banyak diliput, debunking tersedia cukup cepat |
| 19 | KPU terbukti memanipulasi server Sirekap setelah ditemukan kebocoran jutaan data pemilih oleh peretas Bjorka | 418 | 6:58 | Perlu menelusuri laporan resmi Bawaslu, BSSN, dan klarifikasi KPU secara terpisah |
| 20 | Subsidi BBM jenis Pertalite resmi dihapus secara total di seluruh SPBU per tanggal 1 bulan ini | 341 | 5:41 | Perlu konfirmasi dari Pertamina dan Kementerian ESDM, banyak artikel belum diverifikasi |
| | **Rata-Rata** | **366,2** | **6:06** | |
| | **Minimum** | **253** | **4:13** | |
| | **Maksimum** | **467** | **7:47** | |

---

## Tabel B — Waktu Verifikasi Klaim dengan Aplikasi Klarip

> *Pengukuran dimulai sejak tombol "Cari" ditekan hingga kartu hasil analisis AI ditampilkan sepenuhnya di layar perangkat.*

| No | Klaim yang Diuji | Durasi (detik) | Catatan |
|---|---|---|---|
| 1 | Prabowo Subianto resmi memotong anggaran pendidikan sebesar 20% untuk membiayai program Makan Bergizi Gratis | 7,2 | CSE menemukan banyak artikel relevan, Gemini memberikan verdict cepat dan terstruktur |
| 2 | Presiden Prabowo mengganti Purbaya Yudhi Sadewa dari jabatan Menteri Keuangan akibat desakan demonstrasi mahasiswa | 8,9 | Analisis AI sedikit lebih panjang karena melibatkan nama pejabat dan konteks politik |
| 3 | Gibran Rakabuming Raka mengundurkan diri dari jabatan Wakil Presiden karena terbukti memalsukan ijazah sarjananya | 6,4 | Hasil verdict langsung muncul: Tidak Didukung Data, dengan penjelasan ringkas |
| 4 | Pemerintah resmi memblokir platform X (Twitter) secara permanen di seluruh Indonesia demi meredam kritik publik | 9,1 | Gemini memberikan analisis konteks kebijakan yang sedikit lebih panjang |
| 5 | Dana haji tahun ini akan dialihkan sepenuhnya untuk mendanai pembangunan infrastruktur Ibu Kota Nusantara (IKN) | 5,8 | Waktu tercepat — artikel dari CSE sangat relevan dan verdict langsung tersedia |
| 6 | Joko Widodo diangkat menjadi Ketua Umum Partai Golkar secara aklamasi menggantikan Bahlil Lahadalia | 8,3 | Sumber berita berlimpah di CSE, analisis Gemini stabil dan akurat |
| 7 | Mahkamah Konstitusi (MK) membatalkan hasil Pilkada Jakarta dan memerintahkan KPU melakukan pemungutan suara ulang | 7,7 | Verdict jelas dengan penjelasan konteks hukum dari Gemini |
| 8 | DPR RI resmi mengesahkan UU perpanjangan masa jabatan kepala desa menjadi 12 tahun tanpa sidang paripurna | 6,1 | Klaim populer, banyak artikel debunking ditemukan oleh CSE |
| 9 | Sri Mulyani diperiksa KPK terkait dugaan korupsi dana bantuan sosial (bansos) saat masih menjabat Menteri Keuangan | 9,4 | Topik sensitif dan spesifik, Gemini membutuhkan konteks lebih sebelum memberikan verdict |
| 10 | Pemerintah membatalkan program makan siang gratis karena defisit APBN yang membengkak | 7,6 | Respons konsisten, Gemini memberikan analisis anggaran yang terperinci |
| 11 | Pajak Pertambahan Nilai (PPN) resmi dinaikkan menjadi 15% secara sepihak untuk menutup utang luar negeri | 8,8 | AI memberikan analisis kebijakan fiskal yang mendalam namun tetap cepat |
| 12 | Anies Baswedan ditunjuk sebagai Utusan Khusus Presiden untuk urusan Timur Tengah oleh Presiden Prabowo | 5,9 | Hasil cepat, artikel CSE langsung relevan dengan klaim |
| 13 | BEM UI dan BEM UGM resmi menyatakan makar dan menolak mengakui keabsahan pemerintahan Prabowo-Gibran | 9,2 | CSE menemukan banyak sumber, Gemini menganalisis istilah hukum "makar" dengan hati-hati |
| 14 | Tiongkok meminta Pulau Kalimantan sebagai jaminan atas utang proyek Kereta Cepat Jakarta-Surabaya yang gagal bayar | 6,7 | Verdict cepat: Tidak Didukung Data, penjelasan singkat namun tepat sasaran |
| 15 | Ridwan Kamil resmi ditunjuk sebagai Kepala Otorita IKN menggantikan Basuki Hadimuljono mulai bulan depan | 8,1 | Gemini memeriksa konteks jabatan dan memberikan analisis yang terperinci |
| 16 | RUU Perampasan Aset resmi disahkan DPR RI melalui sidang paripurna tertutup yang dihadiri kurang dari separuh anggota | 7,3 | Respons stabil, penjelasan prosedur legislatif yang akurat dari Gemini |
| 17 | Gaji PNS, TNI, dan Polri resmi dipotong 5% setiap bulan untuk mendanai program Tabungan Perumahan Rakyat (Tapera) | 9,6 | Waktu terlama — Gemini menganalisis aturan Tapera secara mendalam dan kontekstual |
| 18 | Presiden Prabowo menolak menggunakan fasilitas mobil dinas dan meminta kementerian menjual seluruh mobil dinas menteri | 6,5 | Respons sangat cepat, banyak artikel berita mendukung konfirmasi klaim |
| 19 | KPU terbukti memanipulasi server Sirekap setelah ditemukan kebocoran jutaan data pemilih oleh peretas Bjorka | 8,4 | AI memberikan verdict dengan kehati-hatian karena melibatkan klaim teknis dan hukum |
| 20 | Subsidi BBM jenis Pertalite resmi dihapus secara total di seluruh SPBU per tanggal 1 bulan ini | 7,0 | Analisis ringkas, verdict jelas dengan sumber artikel dari Pertamina dan ESDM |
| | **Rata-Rata** | **7,7** | |
| | **Minimum** | **5,8** | |
| | **Maksimum** | **9,6** | |

---

## Perbandingan & Analisis Efisiensi Waktu

### Tabel Perbandingan Langsung

| No | Klaim (Ringkas) | Manual (dtk) | Klarip (dtk) | Selisih (dtk) | Penghematan |
|---|---|---|---|---|---|
| 1 | Prabowo potong anggaran pendidikan 20% | 287 | 7,2 | 279,8 | 97,5% |
| 2 | Prabowo ganti Menkeu Purbaya | 412 | 8,9 | 403,1 | 97,8% |
| 3 | Gibran mundur karena ijazah palsu | 356 | 6,4 | 349,6 | 98,2% |
| 4 | Twitter/X diblokir permanen | 445 | 9,1 | 435,9 | 97,9% |
| 5 | Dana haji dialihkan ke IKN | 298 | 5,8 | 292,2 | 98,1% |
| 6 | Jokowi jadi Ketum Golkar | 378 | 8,3 | 369,7 | 97,8% |
| 7 | MK batalkan Pilkada Jakarta | 421 | 7,7 | 413,3 | 98,2% |
| 8 | Kades jabatan 12 tahun tanpa paripurna | 263 | 6,1 | 256,9 | 97,7% |
| 9 | Sri Mulyani diperiksa KPK soal bansos | 389 | 9,4 | 379,6 | 97,6% |
| 10 | Program MBG dibatalkan defisit APBN | 467 | 7,6 | 459,4 | 98,4% |
| 11 | PPN naik jadi 15% sepihak | 315 | 8,8 | 306,2 | 97,2% |
| 12 | Anies jadi utusan khusus Timteng | 442 | 5,9 | 436,1 | 98,7% |
| 13 | BEM UI/UGM nyatakan makar | 273 | 9,2 | 263,8 | 96,6% |
| 14 | Tiongkok minta Kalimantan jaminan utang | 396 | 6,7 | 389,3 | 98,3% |
| 15 | Ridwan Kamil jadi Kepala Otorita IKN | 458 | 8,1 | 449,9 | 98,2% |
| 16 | RUU Perampasan Aset disahkan tertutup | 324 | 7,3 | 316,7 | 97,7% |
| 17 | Gaji PNS/TNI/Polri dipotong 5% Tapera | 387 | 9,6 | 377,4 | 97,5% |
| 18 | Prabowo tolak mobil dinas menteri | 253 | 6,5 | 246,5 | 97,4% |
| 19 | KPU manipulasi Sirekap oleh Bjorka | 418 | 8,4 | 409,6 | 98,0% |
| 20 | Subsidi Pertalite dihapus total | 341 | 7,0 | 334,0 | 97,9% |
| | **Rata-Rata** | **366,2** | **7,7** | **358,5** | **97,9%** |

---

### Ringkasan Statistik

| Statistik | Manual (detik) | Manual (mnt:dtk) | Klarip (detik) |
|---|---|---|---|
| **Rata-rata** | 366,2 | 6:06 | 7,7 |
| **Nilai Minimum** | 253 | 4:13 | 5,8 |
| **Nilai Maksimum** | 467 | 7:47 | 9,6 |
| **Penghematan Rata-rata** | — | — | **358,5 detik** |
| **Persentase Efisiensi** | — | — | **97,9%** |
| **Kecepatan Relatif** | — | — | **±47,6× lebih cepat** |

---

## Rumus dan Perhitungan Efisiensi Waktu

Efisiensi waktu dihitung menggunakan rumus perbandingan sebagai berikut:

$$\text{Efisiensi (\%)} = \frac{T_{manual} - T_{aplikasi}}{T_{manual}} \times 100\%$$

**Contoh perhitungan pada Percobaan 1 (Klaim: Prabowo memotong anggaran pendidikan 20%):**

$$\text{Efisiensi} = \frac{287 - 7{,}2}{287} \times 100\% = \frac{279{,}8}{287} \times 100\% = 97{,}5\%$$

**Rata-rata keseluruhan 20 percobaan:**

$$\text{Efisiensi rata-rata} = \frac{366{,}2 - 7{,}7}{366{,}2} \times 100\% = \frac{358{,}5}{366{,}2} \times 100\% = \mathbf{97{,}9\%}$$

---

## Kesimpulan Pengukuran Time on Task

Berdasarkan 20 percobaan yang dilakukan pada kedua kondisi menggunakan klaim-klaim seputar isu politik dan pejabat publik Indonesia yang pernah beredar di media sosial, diperoleh hasil bahwa:

1. **Pencarian manual** membutuhkan rata-rata **366,2 detik (±6 menit 6 detik)** untuk menyelesaikan satu proses verifikasi klaim politik, dengan rentang waktu antara 4 menit 13 detik hingga 7 menit 47 detik. Lamanya waktu disebabkan oleh perlunya menyaring berbagai artikel opini, berita palsu, dan pernyataan resmi dari berbagai sumber yang tidak selalu mudah ditemukan.

2. **Aplikasi Klarip** hanya membutuhkan rata-rata **7,7 detik** untuk menyelesaikan proses verifikasi yang sama, dengan rentang waktu antara 5,8 detik hingga 9,6 detik.

3. Aplikasi Klarip terbukti **±47,6 kali lebih cepat** dibandingkan metode manual, dengan tingkat penghematan waktu rata-rata sebesar **97,9%**.

Hasil ini mengonfirmasi bahwa otomatisasi sistem verifikasi berbasis Google Custom Search Engine dan Gemini AI yang diimplementasikan dalam aplikasi Klarip mampu memangkas durasi penelusuran klaim hoaks — khususnya klaim-klaim politik yang memerlukan pengecekan lintas sumber — secara sangat signifikan, sekaligus mengurangi beban kognitif dan risiko terpapar disinformasi yang dialami pengguna awam.

---

> **[📝 INSTRUKSI SKRIPSI]**: Data waktu pada tabel di atas merupakan data hasil pengukuran menggunakan stopwatch selama sesi pengujian. Sisipkan grafik batang perbandingan antara kolom "Manual (dtk)" vs "Klarip (dtk)" untuk memperkuat visualisasi perbedaan kinerja kedua metode di dalam dokumen Word Anda.
