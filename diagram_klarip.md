# Diagram Mermaid — Perancangan Alur Kerja Sistem Klarip (Revisi)
## Untuk BAB 4 Sub-bab 2b: Perancangan Alur Kerja Sistem

---

## DIAGRAM 1 — Use Case Diagram

> Salin kode di bawah ini ke: https://mermaid.live

```mermaid
---
title: Use Case Diagram Aplikasi Klarip
---
flowchart LR
    User(["👤 Pengguna\n(Generasi Z)"])

    subgraph SYS ["🔷 SISTEM APLIKASI KLARIP"]
        direction TB
        UC1("📝 Daftar Akun\n(Register)")
        UC2("🔐 Masuk Aplikasi\n(Login)")
        UC3("🔍 Verifikasi Klaim\nBerita")
        UC4("💾 Menyimpan Hasil\nVerifikasi")
        UC5("📂 Melihat Riwayat\nKoleksi")
        UC6("⭐ Menandai Favorit\nKoleksi")
        UC7("✏️ Mengedit Catatan\nKoleksi")
        UC8("🗑️ Menghapus\nKoleksi")
        UC9("👤 Mengelola Profil")
        UC10("🔑 Mengganti\nKata Sandi")
        UC11("🚪 Keluar Aplikasi\n(Logout)")
    end

    subgraph EXT ["⚙️ LAYANAN EKSTERNAL"]
        direction TB
        CSE[("🌐 Google Custom\nSearch Engine API")]
        GEM[("🤖 Google Gemini\n2.5 Flash-Lite API")]
    end

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8
    User --> UC9
    User --> UC10
    User --> UC11

    UC3 -.->|"include"| CSE
    UC3 -.->|"include"| GEM
    UC4 -.->|"extend"| UC3
```

---

## DIAGRAM 2 — Flowchart Sistem (Alur Keseluruhan Aplikasi)

> **Catatan Revisi:** Flowchart ini telah dirapikan menggunakan blok `subgraph` agar alurnya tersusun lurus dari atas ke bawah (Top-Down) per modul, sehingga tidak terlihat berantakan atau bertabrakan garisnya.
> Salin kode di bawah ini ke: https://mermaid.live

```mermaid
---
title: Flowchart Sistem Keseluruhan Aplikasi Klarip
config:
  layout: elk
---
flowchart TD
    %% INISIALISASI
    START([▶ MULAI]) --> INIT[Buka Aplikasi]
    INIT --> CEK_SESI{Sesi Aktif?}

    %% MODUL AUTENTIKASI
    subgraph AUTH [Modul Autentikasi]
        direction TB
        LOGIN_PAGE[Tampil Halaman Login]
        CEK_AKUN{Punya Akun?}
        REG_PAGE[Halaman Register]
        INPUT_REG[Input Data Diri]
        SIMPAN_USER[Simpan ke SQLite]
        INPUT_LOGIN[Input Email & Password]
        CEK_KREDENSIAL{Kredensial Valid?}
        ERR_LOGIN[Pesan: Email/Password Salah]
        SET_SESI[Simpan Sesi ke SharedPreferences]

        LOGIN_PAGE --> CEK_AKUN
        CEK_AKUN -->|Belum| REG_PAGE
        REG_PAGE --> INPUT_REG
        INPUT_REG --> SIMPAN_USER
        SIMPAN_USER --> LOGIN_PAGE
        CEK_AKUN -->|Sudah| INPUT_LOGIN
        INPUT_LOGIN --> CEK_KREDENSIAL
        CEK_KREDENSIAL -->|Tidak| ERR_LOGIN
        ERR_LOGIN --> INPUT_LOGIN
        CEK_KREDENSIAL -->|Ya| SET_SESI
    end

    CEK_SESI -->|Tidak| LOGIN_PAGE

    %% MODUL MENU UTAMA
    subgraph MENU [Navigasi Utama]
        direction TB
        HOME[HomeShell Utama]
        PILIH_TAB{Pilih Tab Navigasi}
        HOME --> PILIH_TAB
    end

    CEK_SESI -->|Ya| HOME
    SET_SESI --> HOME

    %% MODUL CEK FAKTA
    subgraph CEK_FAKTA [Modul Cari & Verifikasi Klaim]
        direction TB
        HAL_CARI[Tampil Halaman Cari]
        INPUT_KLAIM[Input Teks Klaim]
        TOMBOL_CARI[Tekan Cari]
        RATE_LIMIT{Cooldown < 5 detik?}
        ERR_SPAM[Pesan: Spamming Dicegah]
        LOAD_CSE[Loading: Mencari Bukti...]
        API_CSE[Request Google CSE API]
        CEK_HASIL{Ada Hasil?}
        ERR_NIL[Pesan: Tidak Ada Hasil]
        LOAD_AI[Loading: Menganalisis...]
        API_GEMINI[Request Gemini AI]
        SIMPAN_AUTO[Simpan Otomatis ke SQLite]
        TAMPIL_HASIL[Render Kartu Verdict & Bukti]

        HAL_CARI --> INPUT_KLAIM
        INPUT_KLAIM --> TOMBOL_CARI
        TOMBOL_CARI --> RATE_LIMIT
        RATE_LIMIT -->|Terlalu Cepat| ERR_SPAM
        ERR_SPAM --> INPUT_KLAIM
        RATE_LIMIT -->|Aman| LOAD_CSE
        LOAD_CSE --> API_CSE
        API_CSE --> CEK_HASIL
        CEK_HASIL -->|Tidak Ada| ERR_NIL
        ERR_NIL --> INPUT_KLAIM
        CEK_HASIL -->|Ada| LOAD_AI
        LOAD_AI --> API_GEMINI
        API_GEMINI --> SIMPAN_AUTO
        SIMPAN_AUTO --> TAMPIL_HASIL
    end

    PILIH_TAB -->|Tab Cari| HAL_CARI

    %% MODUL KOLEKSI
    subgraph KOLEKSI [Modul Riwayat Koleksi]
        direction TB
        HAL_KOL[Tampil Halaman Koleksi]
        LOAD_DB[Ambil Data dari SQLite]
        AKSI_KOL{Aksi Pengguna?}
        LIHAT_KOL[Lihat Detail Verifikasi]
        FAV_KOL[Toggle Bintang Favorit]
        EDIT_KOL[Edit Catatan Pribadi]
        HAPUS_KOL[Hapus Data dari SQLite]

        HAL_KOL --> LOAD_DB
        LOAD_DB --> AKSI_KOL
        AKSI_KOL -->|Tap Item| LIHAT_KOL
        AKSI_KOL -->|Tap Ikon Favorit| FAV_KOL
        AKSI_KOL -->|Pilih Edit Note| EDIT_KOL
        AKSI_KOL -->|Pilih Hapus| HAPUS_KOL
        FAV_KOL --> LOAD_DB
        EDIT_KOL --> LOAD_DB
        HAPUS_KOL --> LOAD_DB
    end

    PILIH_TAB -->|Tab Koleksi| HAL_KOL

    %% MODUL PROFIL
    subgraph PROFIL [Modul Profil & Pengaturan]
        direction TB
        HAL_PROFIL[Tampil Halaman Profil]
        AKSI_PROFIL{Aksi Pengguna?}
        EDIT_USER[Update Data di SQLite]
        GANTI_PASS[Update Password di SQLite]
        LOGOUT[Hapus Sesi SharedPreferences]

        HAL_PROFIL --> AKSI_PROFIL
        AKSI_PROFIL -->|Edit Profil| EDIT_USER
        AKSI_PROFIL -->|Ganti Password| GANTI_PASS
        AKSI_PROFIL -->|Logout| LOGOUT
        EDIT_USER --> HAL_PROFIL
        GANTI_PASS --> HAL_PROFIL
    end

    PILIH_TAB -->|Tab Profil| HAL_PROFIL
    LOGOUT --> LOGIN_PAGE

    TAMPIL_HASIL --> END([⏹ SELESAI])
```

---

## DIAGRAM 3 — Sequence Diagram (Khusus Alur Verifikasi Klaim)

> Sequence Diagram ini HANYA menampilkan alur proses komputasi CSE dan AI yang berjalan di balik layar saat memverifikasi klaim. Salin kode di bawah ini ke: https://mermaid.live

```mermaid
---
title: Sequence Diagram Proses Verifikasi Klaim — Aplikasi Klarip
---
sequenceDiagram
    autonumber
    actor PG as Pengguna
    participant UI as Flutter App<br/>(UI & Provider)
    participant CSE as Google CSE API
    participant GEM as Gemini 2.5<br/>Flash-Lite AI
    participant DB as SQLite Lokal

    PG->>UI: Masukkan teks klaim berita
    PG->>UI: Tekan tombol "Cari"

    UI->>UI: Cek Rate-Limit (cooldown 5 detik)

    alt Spamming Terdeteksi
        UI-->>PG: Tampil pesan error "Spamming dicegah"
    else Dalam Batas Aman
        UI-->>PG: Tampil Skeleton Loading "Mencari bukti..."

        UI->>CSE: HTTP GET /customsearch/v1<br/>(query=klaim, key=API_KEY, cx=CX_ID)
        CSE-->>UI: Return array metadata artikel<br/>[{title, link, snippet}, ...]

        alt Tidak Ada Hasil CSE
            UI-->>PG: Tampil pesan "Tidak ada hasil ditemukan"
        else Hasil CSE Tersedia
            UI-->>PG: Update Loading "Menganalisis kalimat..."

            UI->>GEM: POST /generateContent<br/>Prompt = Klaim + Array Bukti Web (RAG)
            GEM-->>UI: Return JSON Response<br/>{verdict, explanation, confidence, sources}

            UI->>DB: INSERT INTO saved_analyses<br/>(claim, verdict, explanation, user_email)
            DB-->>UI: Konfirmasi: Data tersimpan (id=N)

            UI-->>PG: Render Hasil Analisis<br/>• Kartu Verdict (Didukung / Tidak / Perlu Cek)<br/>• Penjelasan AI<br/>• Daftar Tautan Bukti Artikel
        end
    end
```

---

## DIAGRAM 4 — Sequence Diagram (Khusus Operasi CRUD Koleksi)

> Diagram ini adalah **tambahan** untuk memperlihatkan bagaimana interaksi aplikasi dengan Database SQLite untuk memuat, mengedit, memfavoritkan, dan menghapus riwayat analisis (CRUD). Salin kode di bawah ini ke: https://mermaid.live

```mermaid
---
title: Sequence Diagram Operasi CRUD Riwayat Koleksi (Saved Analyses)
---
sequenceDiagram
    autonumber
    actor PG as Pengguna
    participant UI as Halaman Koleksi<br/>(Flutter UI)
    participant PROV as SavedAnalysisProvider
    participant DB as DatabaseHelper<br/>(SQLite)

    %% Skenario READ (Load Data)
    rect rgb(30, 40, 50)
    Note over PG,DB: 1. SKENARIO READ (Memuat Daftar Koleksi)
    PG->>UI: Buka Tab Koleksi
    UI->>PROV: Panggil loadAnalyses()
    PROV->>DB: queryAll('saved_analyses', where user_email)
    DB-->>PROV: Return List of Maps (Data Koleksi)
    PROV->>PROV: Sortir data (Favorit di atas, Terbaru di atas)
    PROV-->>UI: notifyListeners() (Update List)
    UI-->>PG: Tampilkan daftar riwayat analisis
    end

    %% Skenario UPDATE FAVORITE
    rect rgb(30, 50, 40)
    Note over PG,DB: 2. SKENARIO UPDATE (Toggle Favorit)
    PG->>UI: Tekan Ikon Bintang (Favorit) pada Item A
    UI->>PROV: Panggil toggleFavorite(id)
    PROV->>PROV: Update State Lokal secara Optimis (Ubah Icon)
    PROV-->>UI: notifyListeners() (Render Bintang Penuh)
    PROV->>DB: update('saved_analyses', is_favorite = 1, where id)
    DB-->>PROV: Konfirmasi baris di-update
    end

    %% Skenario UPDATE NOTE
    rect rgb(50, 40, 30)
    Note over PG,DB: 3. SKENARIO UPDATE (Edit Catatan Pribadi)
    PG->>UI: Pilih Menu "Edit Catatan", Masukkan teks
    PG->>UI: Tekan "Simpan"
    UI->>PROV: Panggil updateNote(id, "Teks baru")
    PROV->>DB: update('saved_analyses', user_note = "Teks baru", where id)
    DB-->>PROV: Konfirmasi baris di-update
    PROV->>PROV: Perbarui State Lokal
    PROV-->>UI: notifyListeners() (Update Teks UI)
    UI-->>PG: Tampilkan pesan "Catatan berhasil diperbarui"
    end

    %% Skenario DELETE
    rect rgb(50, 30, 30)
    Note over PG,DB: 4. SKENARIO DELETE (Hapus Koleksi)
    PG->>UI: Pilih Menu "Hapus" pada Item A
    UI-->>PG: Tampil Dialog Konfirmasi Hapus
    PG->>UI: Tekan "Ya, Hapus"
    UI->>PROV: Panggil deleteAnalysis(id)
    PROV->>DB: delete('saved_analyses', where id)
    DB-->>PROV: Konfirmasi baris dihapus
    PROV->>PROV: Hapus Item A dari State Lokal
    PROV-->>UI: notifyListeners() (Hilangkan Item dari UI)
    UI-->>PG: Tampilkan pesan "Analisis dihapus"
    end
```

---

## DIAGRAM 5 — Sequence Diagram (Khusus Operasi CRUD Data Pengguna)

> Diagram ini memperlihatkan interaksi **Modul Autentikasi dan Profil** dengan Database SQLite untuk memproses pendaftaran (Create), login (Read), dan pembaruan data pengguna/kata sandi (Update). Salin kode di bawah ini ke: https://mermaid.live

```mermaid
---
title: Sequence Diagram Operasi CRUD Data Pengguna (Auth & Profil)
---
sequenceDiagram
    autonumber
    actor PG as Pengguna
    participant UI as Flutter UI<br/>(Auth/Profil)
    participant PROV as AuthProvider
    participant DB as DatabaseHelper<br/>(SQLite)

    %% Skenario REGISTER (Create)
    rect rgb(30, 40, 50)
    Note over PG,DB: 1. SKENARIO CREATE (Register Akun Baru)
    PG->>UI: Input Nama, Username, Email, Password
    PG->>UI: Tekan "Daftar"
    UI->>PROV: Panggil register(...)
    PROV->>DB: getUserByEmail(email)
    
    alt Email Sudah Ada
        DB-->>PROV: Return User Data
        PROV-->>UI: Return Error "Email sudah terdaftar"
        UI-->>PG: Tampil Snackbar Error
    else Email Belum Ada
        DB-->>PROV: Return null
        PROV->>DB: insert('users', newUserMap)
        DB-->>PROV: Konfirmasi (id=N)
        PROV->>PROV: Auto Login via SharedPreferences
        PROV-->>UI: Return Success
        UI-->>PG: Pindah ke Halaman Home
    end
    end

    %% Skenario LOGIN (Read Session)
    rect rgb(30, 50, 40)
    Note over PG,DB: 2. SKENARIO READ (Login & Sesi Aktif)
    PG->>UI: Input Email & Password
    PG->>UI: Tekan "Masuk"
    UI->>PROV: Panggil login(email, password)
    PROV->>DB: query('users', where email & password)
    
    alt Kredensial Salah
        DB-->>PROV: Return null
        PROV-->>UI: Return Error "Email/password salah"
        UI-->>PG: Tampil Pesan Error
    else Kredensial Benar
        DB-->>PROV: Return User Data
        PROV->>PROV: Simpan Email ke SharedPreferences
        PROV->>PROV: Set State _currentUser
        PROV-->>UI: Return Success
        UI-->>PG: Pindah ke Halaman Home
    end
    end

    %% Skenario UPDATE PROFIL
    rect rgb(50, 40, 30)
    Note over PG,DB: 3. SKENARIO UPDATE (Edit Profil)
    PG->>UI: Ubah Nama atau Username
    PG->>UI: Tekan "Simpan Perubahan"
    UI->>PROV: Panggil updateProfile(updatedUser)
    PROV->>DB: update('users', updatedMap, where id)
    DB-->>PROV: Konfirmasi baris di-update
    PROV->>PROV: Perbarui State _currentUser
    PROV-->>UI: notifyListeners()
    UI-->>PG: Tampil Pesan "Profil diperbarui"
    end

    %% Skenario UPDATE PASSWORD
    rect rgb(50, 30, 30)
    Note over PG,DB: 4. SKENARIO UPDATE (Ganti Kata Sandi)
    PG->>UI: Input Password Lama & Baru
    PG->>UI: Tekan "Ganti Password"
    UI->>PROV: Panggil changePassword(id, old, new)
    
    alt Password Lama Salah
        PROV-->>UI: Return Error "Password lama salah"
    else Password Lama Benar
        PROV->>DB: update('users', password=new, where id)
        DB-->>PROV: Konfirmasi baris di-update
        PROV->>PROV: Perbarui State Lokal
        PROV-->>UI: Return Success
        UI-->>PG: Tampil Pesan "Password berhasil diganti"
    end
    end

    %% Skenario LOGOUT (Hapus Sesi)
    rect rgba(100, 100, 100, 1)
    Note over PG,DB: 5. SKENARIO LOGOUT (Keluar Sesi)
    PG->>UI: Tekan "Logout"
    UI->>PROV: Panggil logout()
    PROV->>PROV: Hapus 'user_email' dari SharedPreferences
    PROV->>PROV: Set State _currentUser = null
    PROV-->>UI: notifyListeners()
    UI-->>PG: Pindah ke Halaman Login
    end
```
