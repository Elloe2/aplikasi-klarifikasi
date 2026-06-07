# BAB V — PENUTUP
## (Draft untuk Disalin ke Dokumen Skripsi Microsoft Word)

---

## A. Kesimpulan

Penelitian ini bertujuan untuk mengembangkan aplikasi berbasis *mobile* bernama **Klarip** yang memanfaatkan layanan **Google Custom Search Engine (CSE)** dan **Gemini AI** sebagai sistem verifikasi klaim dan pengecekan fakta informasi yang beredar di media sosial. Pengembangan dilakukan menggunakan metodologi **SDLC** (*Software Development Life Cycle*) dengan platform **Flutter** sebagai kerangka kerja utama.

Berdasarkan hasil penelitian dan pengujian yang telah dilakukan, dapat ditarik kesimpulan sebagai berikut:

### 1. Aplikasi Klarip Berhasil Dibangun Sesuai Rancangan

Aplikasi Klarip berhasil dikembangkan dengan mengimplementasikan empat modul fungsional utama, yaitu: (a) sistem autentikasi pengguna berbasis database SQLite lokal; (b) sistem verifikasi klaim menggunakan teknik *Retrieval-Augmented Generation* (RAG) yang mengintegrasikan Google CSE dan Gemini AI; (c) sistem manajemen riwayat analisis dengan operasi CRUD lengkap; serta (d) sistem pengaturan antarmuka dan API *key* yang dapat dikustomisasi oleh pengguna. Seluruh fitur dibangun tanpa memerlukan server *backend* pihak ketiga dari pengembang, sehingga aplikasi berjalan sepenuhnya *client-side* di perangkat pengguna.

### 2. Pengujian Fungsionalitas Menunjukkan Keberhasilan 100%

Hasil pengujian *Black Box Testing* yang dilakukan terhadap **50 skenario uji** yang mencakup enam modul fungsional — autentikasi, verifikasi klaim, manajemen riwayat, profil pengguna, pengaturan API, dan navigasi antarmuka — menunjukkan bahwa **seluruh skenario (100%) berhasil berjalan sesuai dengan hasil yang diharapkan**. Tidak ditemukan adanya kegagalan fungsi pada satu pun skenario yang diujikan. Hal ini membuktikan bahwa aplikasi Klarip telah memenuhi seluruh kebutuhan fungsional yang telah dirancang.

### 3. Aplikasi Klarip Terbukti Jauh Lebih Efisien dari Metode Manual

Pengukuran *Time on Task* yang dilakukan melalui **20 percobaan** dengan menggunakan klaim-klaim hoaks politik yang pernah beredar di media sosial Indonesia menunjukkan perbedaan yang sangat signifikan. Metode pencarian manual melalui Google Search membutuhkan waktu rata-rata **366,2 detik (±6 menit 6 detik)** per verifikasi, sementara aplikasi Klarip hanya membutuhkan rata-rata **7,7 detik**. Berdasarkan perhitungan efisiensi, aplikasi Klarip terbukti **±47,6 kali lebih cepat** dengan tingkat penghematan waktu sebesar **97,9%**. Hasil ini mengonfirmasi bahwa otomatisasi sistem verifikasi berbasis AI mampu memangkas durasi penelusuran fakta secara sangat substansial.

### 4. Tingkat Usabilitas Aplikasi Berada pada Kategori "Baik"

Hasil evaluasi *System Usability Scale* (SUS) yang melibatkan **20 responden** pengguna aktif media sosial menghasilkan **rata-rata skor SUS sebesar 78,25**. Skor tersebut berada pada rentang 68–80,3 yang dikategorikan sebagai **Grade B (Good / Baik)** berdasarkan skala interpretasi SUS standar. Sebanyak 40% responden memberikan penilaian pada kategori *Excellent* dan 30% pada kategori *Good*, menunjukkan bahwa mayoritas pengguna (70%) menilai aplikasi ini sudah sangat baik dalam aspek kemudahan penggunaan, desain antarmuka, dan kegunaan fitur yang tersedia.

---

## B. Implikasi

Hasil penelitian ini memiliki beberapa implikasi penting, baik dari aspek akademis, teknologi, maupun sosial masyarakat:

### 1. Implikasi Akademis

Penelitian ini membuktikan secara empiris bahwa teknik *Retrieval-Augmented Generation* (RAG) — yang menggabungkan sistem pengambilan informasi (*information retrieval*) dengan model bahasa besar (*large language model*) — dapat diimplementasikan secara efektif dalam konteks pengecekan fakta berbahasa Indonesia. Pendekatan ini membuka peluang bagi penelitian selanjutnya dalam bidang *Natural Language Processing* (NLP), *Computational Journalism*, dan *Human-Computer Interaction* (HCI) di lingkungan akademik Indonesia.

Selain itu, penggunaan metodologi **SDLC** (*Software Development Life Cycle*) dalam pengembangan aplikasi berbasis AI terbukti menghasilkan produk yang terstruktur, teruji, dan memiliki tingkat usabilitas yang baik. Hal ini memberikan landasan metodologis bagi penelitian pengembangan (*research and development*) perangkat lunak berbasis AI di masa mendatang.

### 2. Implikasi Teknologi

Dari perspektif teknologi, penelitian ini menunjukkan bahwa integrasi antara **Google Custom Search Engine** dan **Gemini AI** dapat dilakukan secara langsung dari sisi klien (*client-side*) tanpa memerlukan infrastruktur server yang kompleks dan mahal. Pola arsitektur ini menjadi alternatif yang ekonomis dan skalabel untuk pengembangan aplikasi verifikasi informasi, terutama bagi pengembang independen atau institusi dengan anggaran terbatas.

Implementasi Flutter sebagai platform juga menunjukkan bahwa pengembangan aplikasi lintas platform yang modern, responsif, dan berkinerja tinggi dapat dicapai dengan satu basis kode yang sama, sehingga efisiensi pengembangan meningkat secara signifikan.

### 3. Implikasi Sosial

Dari sisi masyarakat, kehadiran aplikasi Klarip memiliki potensi yang signifikan dalam **memberdayakan literasi digital** pengguna media sosial, khususnya generasi muda yang aktif mengonsumsi dan menyebarkan informasi di platform digital. Di tengah maraknya peredaran hoaks dan disinformasi — terutama terkait isu-isu politik, kesehatan, dan kebijakan publik — ketersediaan alat verifikasi yang cepat, mudah, dan gratis dapat menjadi salah satu solusi preventif yang efektif.

Pengurangan waktu verifikasi dari rata-rata enam menit menjadi kurang dari delapan detik secara langsung menurunkan **hambatan (friction)** bagi pengguna awam untuk melakukan pengecekan fakta sebelum menyebarkan informasi lebih lanjut. Hal ini sejalan dengan upaya pemerintah, platform digital, dan organisasi masyarakat sipil dalam membangun ekosistem informasi yang lebih sehat dan bertanggung jawab di Indonesia.

---

## C. Saran

Berdasarkan temuan, keterbatasan, dan pengalaman dalam penelitian ini, berikut adalah saran yang diajukan untuk perbaikan dan pengembangan ke depan:

### 1. Saran untuk Pengembangan Aplikasi Lebih Lanjut

**a. Penambahan Fitur Onboarding Tutorial**
Berdasarkan hasil SUS, beberapa responden masih merasa kurang percaya diri saat pertama kali menggunakan aplikasi. Oleh karena itu, sangat disarankan untuk menambahkan fitur panduan interaktif (*onboarding tutorial*) yang muncul secara otomatis pada sesi pertama penggunaan, guna membantu pengguna baru memahami cara kerja aplikasi dengan lebih cepat.

**b. Penambahan Dukungan Multibahasa**
Saat ini aplikasi Klarip hanya mendukung bahasa Indonesia. Pengembangan selanjutnya dapat menambahkan dukungan bahasa daerah atau bahasa Inggris agar jangkauan pengguna semakin luas.

**c. Implementasi Fitur Berbagi Hasil Verifikasi**
Menambahkan fitur untuk membagikan hasil analisis langsung ke platform media sosial (WhatsApp, Instagram, X) dapat meningkatkan fungsi aplikasi sebagai alat pencegah penyebaran hoaks secara viral.

**d. Pengembangan ke Platform iOS**
Versi saat ini telah dikembangkan dan diuji pada platform Android. Pengembangan untuk platform iOS perlu dilakukan agar aplikasi dapat menjangkau pengguna perangkat Apple yang jumlahnya juga signifikan di Indonesia.

**e. Integrasi dengan Basis Data Hoaks Terverifikasi**
Aplikasi dapat ditingkatkan dengan mengintegrasikan basis data hoaks yang telah terverifikasi dari lembaga terpercaya seperti Mafindo, Cek Fakta Kompas, atau Turn Back Hoax, sehingga proses verifikasi tidak hanya mengandalkan pencarian real-time namun juga dapat mencocokkan klaim dengan arsip hoaks yang sudah ada.

### 2. Saran untuk Penelitian Selanjutnya

**a. Perluasan Jumlah Sampel Responden**
Pengujian SUS dalam penelitian ini melibatkan 20 responden. Penelitian selanjutnya disarankan untuk memperluas sampel hingga minimal 50–100 responden dengan latar belakang yang lebih beragam (usia, tingkat pendidikan, wilayah geografis) agar hasil evaluasi usabilitas lebih representatif dan dapat digeneralisasi.

**b. Pengujian Akurasi Verifikasi Klaim**
Penelitian ini berfokus pada aspek fungsionalitas, efisiensi waktu, dan usabilitas. Penelitian selanjutnya dapat menambahkan dimensi pengujian **akurasi** sistem verifikasi, yaitu dengan mengukur seberapa tepat *verdict* yang dihasilkan Gemini AI dibandingkan dengan keputusan pengecekan fakta dari lembaga resmi (*ground truth*).

**c. Pengujian Performa pada Jaringan dengan Kecepatan Bervariasi**
Pengukuran *Time on Task* dalam penelitian ini dilakukan dalam kondisi jaringan internet yang stabil. Penelitian selanjutnya dapat menguji performa respons aplikasi pada berbagai kondisi jaringan (3G, 4G, 5G, Wi-Fi) untuk mendapatkan gambaran yang lebih komprehensif.

**d. Implementasi Metode Pengujian Tambahan**
Penelitian selanjutnya dapat melengkapi pengujian usabilitas dengan metode tambahan seperti *Think Aloud Protocol*, *Eye Tracking*, atau wawancara mendalam (*in-depth interview*) pasca penggunaan untuk memperoleh data kualitatif yang lebih kaya mengenai pengalaman pengguna.

### 3. Saran untuk Institusi dan Pemangku Kepentingan

Pemerintah, lembaga pendidikan, dan organisasi masyarakat sipil disarankan untuk mendukung pengembangan dan adopsi alat-alat verifikasi berbasis kecerdasan buatan seperti Klarip sebagai bagian dari program literasi digital nasional. Integrasi alat semacam ini ke dalam kurikulum pendidikan media dan literasi digital di sekolah menengah dan perguruan tinggi dapat menjadi langkah strategis dalam membentuk generasi muda yang kritis, bijak, dan bertanggung jawab dalam mengonsumsi serta menyebarkan informasi di ruang digital.

---

## D. Penutup

Penelitian ini telah berhasil mengembangkan aplikasi Klarip sebagai solusi teknologi yang inovatif, efisien, dan mudah digunakan dalam upaya membantu masyarakat memverifikasi kebenaran informasi yang beredar di media sosial. Meskipun masih terdapat ruang untuk penyempurnaan, hasil penelitian secara keseluruhan menunjukkan bahwa pemanfaatan kecerdasan buatan — khususnya melalui integrasi Google Custom Search Engine dan Gemini AI — memiliki potensi yang sangat besar dalam memerangi penyebaran hoaks dan disinformasi di era digital.

Peneliti berharap bahwa hasil penelitian ini dapat memberikan kontribusi yang berarti bagi pengembangan ilmu pengetahuan di bidang teknologi informasi dan komunikasi, serta menjadi inspirasi bagi peneliti-peneliti selanjutnya untuk terus berinovasi dalam membangun ekosistem informasi digital yang lebih sehat, akuntabel, dan berdaya guna bagi seluruh lapisan masyarakat Indonesia.
