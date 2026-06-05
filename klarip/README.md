# 🌟 Klarip v2.4.0

[![Flutter](https://img.shields.io/badge/Flutter-3.35.3-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2.svg)](https://dart.dev)
[![Gemini AI](https://img.shields.io/badge/Gemini-2.5--flash--lite-green.svg)](https://ai.google.dev)
[![Version](https://img.shields.io/badge/Version-2.4.0-green.svg)](https://github.com/Elloe2/aplikasi-klarifikasi)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Aplikasi fact-checking modern dengan AI Gemini** — dibangun dengan Flutter untuk membantu pengguna memverifikasi kebenaran informasi dan klaim secara real-time menggunakan teknologi AI terdepan. Dilengkapi sistem autentikasi lokal dan manajemen profil pengguna.

## 📝 Ringkasan Singkat

- **Apa ini?** Aplikasi fact-checking berbasis Android untuk menganalisis klaim dengan bantuan Google Gemini AI dan Google Custom Search.
- **Tech stack utama:** Flutter 3.35.3, Google Gemini 2.5-flash-lite, Google CSE, SQLite (local storage).
- **Arsitektur:** Fully client-side — semua API dipanggil langsung dari Flutter, data disimpan lokal di SQLite.
- **Autentikasi:** Sistem login/register lokal berbasis SQLite dengan session persistence menggunakan SharedPreferences.
- **GitHub Repository:** [github.com/Elloe2/aplikasi-klarifikasi](https://github.com/Elloe2/aplikasi-klarifikasi)

---

## 🚀 Quick Start

**Jalankan di emulator Android / perangkat:**

```bash
flutter clean
flutter pub get
flutter run -d android
```

**Jalankan di browser (web):**

```bash
flutter run -d chrome --web-port 8000
```

**Build APK produksi:**

```bash
flutter build apk --release
```

Output APK akan tersimpan di `build/app/outputs/flutter-apk/app-release.apk`.

---

## ✨ Fitur Unggulan

### 🤖 **AI-Powered Fact-Checking**
- **Gemini AI Integration**: Google Gemini 2.5-flash-lite untuk analisis klaim cerdas
- **Real-time Search**: Pencarian informasi dengan Google Custom Search Engine
- **Smart Analysis**: AI memberikan penjelasan dan sumber terpercaya
- **Verdict System**: `DIDUKUNG_DATA` / `TIDAK_DIDUKUNG_DATA` / `MEMERLUKAN_VERIFIKASI`

### 🔐 **Autentikasi & Profil Pengguna**
- **Login & Register**: Sistem autentikasi lokal berbasis SQLite
- **Session Persistence**: Sesi login tersimpan dengan SharedPreferences
- **Edit Profile**: Ubah nama lengkap, username, usia, dan pendidikan
- **Change Password**: Ganti password dengan verifikasi password lama
- **Logout**: Keluar dari akun dengan hapus sesi lokal

### 🔍 **Advanced Search System**
- **Google CSE**: Integrasi langsung (client-side) dengan Google Custom Search Engine
- **Rich Results**: Preview hasil pencarian dengan thumbnail dan snippet
- **Rate Limiting**: Cooldown 5 detik untuk mencegah spam
- **Social Media Detection**: Format khusus untuk link Instagram, X, YouTube, dll.

### 💾 **Local Storage System**
- **SQLite Database**: Penyimpanan analisis dan data pengguna secara lokal
- **CRUD Operations**: Simpan, baca, edit catatan, dan hapus koleksi
- **Favorite System**: Tandai koleksi favorit
- **Personal Notes**: Tambah catatan pribadi pada setiap koleksi

### 🎨 **Modern UI/UX**
- **Spotify-Inspired Design**: Dark theme dengan SpotifyMix font family
- **Responsive Design**: Optimized untuk desktop, tablet, dan mobile
- **Custom Branding**: Logo Klarip untuk favicon dan PWA icons
- **Loading Animations**: Smooth loading states dengan custom animations
- **Error Handling**: Comprehensive error dialogs dan feedback

### 📱 **Multi-Platform Support**
- **Android App**: Native Android application dengan APK build
- **Flutter Web**: Aplikasi web modern (experimental)
- **PWA Ready**: Progressive Web App dengan service worker

---

## 📋 Changelog

### **v2.4.0** - Authentication & Profile Management (Current)
- 🔐 **Local Auth System**: Login, register, dan logout berbasis SQLite
- 👤 **User Profile**: Edit profil (nama, username, usia, pendidikan)
- 🔑 **Change Password**: Ganti password dengan validasi password lama
- 💾 **Session Persistence**: SharedPreferences untuk menjaga sesi login
- 🗃️ **Database Migration**: Tabel `users` baru dengan schema versioning (v2)
- 🏠 **Auth-Aware Navigation**: Redirect otomatis ke login jika belum masuk

### **v2.2.0** - Local Storage Focus
- 💾 **Local-Only Architecture**: Semua data disimpan lokal, tanpa backend server
- 🗄️ **SQLite Integration**: CRUD koleksi dengan sqflite
- ⭐ **Favorite & Notes**: Fitur favorit dan catatan pribadi
- 🤖 **Gemini 2.5-flash-lite**: Upgrade model AI terbaru

### **v2.0.0** - Major Update
- ✨ **Gemini AI Integration**: Integrasi Google Gemini AI untuk fact-checking
- 🎨 **Custom Gemini Logo**: Branding Google Gemini dengan diamond shape
- 🔄 **Collapsible UI**: Gemini chatbot menggunakan ExpansionTile
- 🗑️ **Simplified Analysis**: Fokus pada penjelasan AI
- 🎯 **Enhanced UX**: Loading states dan error handling yang lebih baik

### **v1.0.0** - Initial Release
- 🎉 **Core Features**: Search dan basic fact-checking
- 📱 **Responsive**: Mobile-first design
- 🎨 **Modern UI**: Spotify-inspired dark theme

---

## 🏗️ Arsitektur Aplikasi

### **📐 System Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    🌐 USER LAYER                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│  📱 Flutter Android App           │  🌐 Flutter Web App    │  🌐 PWA Browser     │
│  • Native Android APK             │  • Chrome/Safari       │  • Service Worker   │
│  • SQLite Full Support            │  • Responsive Design   │  • App-like Exp.    │
│  • Material Design                │  • PWA Features        │  • Offline Cap.     │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                🎨 PRESENTATION LAYER                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│  🎯 Flutter Frontend (Multi-Platform, Client-Side Only)                         │
│  ├── 🔐 Auth Pages                                                              │
│  │   ├── login_page.dart              # Halaman login pengguna                 │
│  │   └── register_page.dart           # Halaman registrasi akun baru           │
│  ├── 📱 Main Pages                                                              │
│  │   ├── search_page.dart             # Pencarian + analisis AI                │
│  │   ├── saved_page.dart              # Koleksi analisis tersimpan (CRUD)      │
│  │   └── settings_page.dart           # Profil pengguna & info aplikasi        │
│  ├── 👤 Profile Pages                                                           │
│  │   ├── edit_profile_page.dart       # Edit profil pengguna                   │
│  │   └── change_password_page.dart    # Ganti password                         │
│  ├── 🧩 Widgets Layer                                                           │
│  │   ├── gemini_chatbot.dart          # AI analysis display widget             │
│  │   ├── gemini_logo.dart             # Custom Gemini logo widget              │
│  │   ├── search_result_card.dart      # Card hasil pencarian                   │
│  │   ├── source_details_list.dart     # Detail sumber per-analisis             │
│  │   └── error_banner.dart            # Error handling UI                      │
│  ├── 🔄 State Management                                                       │
│  │   ├── auth_provider.dart           # Auth state (login/register/profile)    │
│  │   └── saved_analysis_provider.dart # Koleksi state (ChangeNotifier)         │
│  └── 🌐 Services Layer                                                         │
│      ├── search_api.dart              # Google CSE API calls (direct)          │
│      ├── gemini_service.dart          # Google Gemini AI API calls (direct)    │
│      └── database_helper.dart         # SQLite database (users + analyses)     │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                              ┌─────────┴─────────┐
                              ▼                   ▼
┌─────────────────────────────────────┐ ┌─────────────────────────────────────┐
│        🤖 AI SERVICES LAYER         │ │       💾 LOCAL STORAGE LAYER         │
├─────────────────────────────────────┤ ├─────────────────────────────────────┤
│  🧠 Google Gemini AI Service        │ │  🗄️ SQLite Database (v2)            │
│  ├── Model: gemini-2.5-flash-lite   │ │  ├── users table                    │
│  ├── Prompt Engineering (ID)        │ │  │   ├── id, username, email        │
│  ├── Response Parsing (JSON)        │ │  │   ├── password, full_name        │
│  └── Verdict + Analysis Output      │ │  │   ├── age, education             │
│                                     │ │  │   └── created_at                 │
│  🔍 Google Custom Search Engine     │ │  ├── saved_analyses table           │
│  ├── Real-time web search           │ │  │   ├── id, title, claim           │
│  ├── Thumbnail extraction           │ │  │   ├── verdict, explanation       │
│  ├── Indonesian language priority   │ │  │   ├── analysis, confidence       │
│  └── API quota management           │ │  │   ├── source_url, user_note      │
│                                     │ │  │   ├── saved_at, is_favorite      │
│                                     │ │  └── Session: SharedPreferences     │
└─────────────────────────────────────┘ └─────────────────────────────────────┘
```

### **🔄 Data Flow Architecture**

```
1. 🔐 AUTHENTICATION
   User login/register → AuthProvider → DatabaseHelper → SQLite (users table)
   Session saved → SharedPreferences (user_email)

2. 📱 USER INTERACTION
   User enters claim/query → Flutter UI captures input

3. 🔍 GOOGLE CSE SEARCH (Direct API Call)
   Flutter → HTTP GET → Google Custom Search API
   → Returns: List<SearchResult> (title, snippet, link, thumbnail)

4. 🤖 GEMINI AI ANALYSIS (Direct API Call)
   Flutter → HTTP POST → Google Gemini API
   → Input: Claim + Search Results
   → Returns: GeminiAnalysis (verdict, explanation, confidence)

5. 📊 UI DISPLAY
   PageView[0] = Gemini AI Analysis (verdict, explanation)
   PageView[1] = Search Results (list of sources)

6. 💾 OPTIONAL LOCAL SAVE
   User saves analysis → SavedAnalysisProvider → DatabaseHelper → SQLite
   User can add personal notes and toggle favorites
```

---

## 📁 Project Structure

```
Klarip Frontend/
├── 📱 lib/                                    # Main application code
│   ├── 🎯 app/                               # Application structure
│   │   ├── app.dart                          # Root widget (MultiProvider + Auth routing)
│   │   └── home_shell.dart                   # Bottom navigation shell (3 tabs)
│   ├── 📊 models/                            # Data models & serialization
│   │   ├── user.dart                         # User model (auth + profile)
│   │   ├── search_result.dart                # Google CSE result model
│   │   ├── gemini_analysis.dart              # Gemini AI analysis model
│   │   ├── saved_analysis.dart               # Saved collection model (CRUD)
│   │   └── source_analysis.dart              # Source stance analysis model
│   ├── 📱 pages/                             # UI Pages & screens
│   │   ├── auth/                             # Authentication pages
│   │   │   ├── login_page.dart               # Login dengan email & password
│   │   │   └── register_page.dart            # Registrasi akun baru
│   │   ├── profile/                          # Profile management pages
│   │   │   ├── edit_profile_page.dart        # Edit profil pengguna
│   │   │   └── change_password_page.dart     # Ganti password
│   │   ├── search_page.dart                  # Main search + AI analysis
│   │   ├── saved_page.dart                   # Koleksi tersimpan (CRUD)
│   │   └── settings_page.dart                # Profil, info app & sumber terpercaya
│   ├── 🔄 providers/                         # State management
│   │   ├── auth_provider.dart                # Auth state (ChangeNotifier)
│   │   └── saved_analysis_provider.dart      # Koleksi state (ChangeNotifier)
│   ├── 🌐 services/                          # API services & local DB
│   │   ├── search_api.dart                   # Google CSE direct API calls
│   │   ├── gemini_service.dart               # Google Gemini direct API calls
│   │   └── database_helper.dart              # SQLite database helper (v2)
│   ├── 🎨 theme/                             # App theming & styling
│   │   └── app_theme.dart                    # Dark theme (Spotify-inspired)
│   ├── 🧩 widgets/                           # Reusable UI components
│   │   ├── gemini_chatbot.dart               # Gemini AI chatbot widget
│   │   ├── gemini_logo.dart                  # Custom Gemini logo widget
│   │   ├── search_result_card.dart           # Search result card widget
│   │   ├── source_details_list.dart          # Source analysis details
│   │   └── error_banner.dart                 # Error handling UI
│   ├── ⚙️ config.dart                        # API keys configuration
│   └── 🎬 main.dart                          # Application entry point
├── 📦 pubspec.yaml                           # Dependencies & metadata
├── 🎨 assets/                                # Static assets
│   ├── logo/                                # Klarip & Gemini logos
│   ├── icons/                               # Navigation icons
│   ├── images/                              # App images
│   └── font/                                # Custom fonts (SpotifyMix)
├── 📱 android/                               # Android-specific configuration
├── 🌐 web/                                   # Web-specific configuration
│   ├── index.html                            # Main HTML file
│   ├── manifest.json                         # PWA manifest
│   └── favicon.png                           # Custom favicon
└── 📋 README.md                              # Documentation
```

---

## 🛠️ Tech Stack

### **Flutter App (Client-Side)**
| Technology | Version | Purpose |
|---|---|---|
| Flutter | 3.35.3 | Cross-platform UI framework |
| Dart | ^3.9.2 | Programming language |
| Provider | ^6.1.2 | State management |
| sqflite | ^2.4.2 | SQLite local database |
| shared_preferences | ^2.5.4 | Session persistence (login state) |
| http | ^1.2.2 | HTTP client for API calls |
| url_launcher | ^6.3.0 | Open URLs in browser |
| flutter_svg | ^2.0.9 | SVG rendering |
| intl | ^0.19.0 | Internationalization |
| path | ^1.9.1 | File path utilities |
| collection | ^1.18.0 | Collection utilities |

### **External APIs (Direct Client-Side Calls)**
| Service | Purpose |
|---|---|
| Google Gemini AI (`gemini-2.5-flash-lite`) | AI-powered claim analysis |
| Google Custom Search Engine | Web search for fact sources |

### **Design System**
- **Theme**: Dark mode (Spotify-inspired)
- **Primary Color**: `#1DB954` (Spotify Green)
- **Font**: SpotifyMix (custom, 7 weights)
- **Design Framework**: Material 3

---

## 📋 Prerequisites

Sebelum memulai, pastikan Anda memiliki:

- **Flutter SDK** (3.9.2+) — [Download](https://flutter.dev/docs/get-started/install)
- **Android Studio / VS Code** — untuk development
- **Android Emulator atau Perangkat** — untuk menjalankan aplikasi
- **Google Custom Search API Key** — [Get Key](https://console.cloud.google.com/)
- **Google Gemini API Key** — [Get Key](https://ai.google.dev/)

---

## 💾 Database Schema (SQLite Local)

### **Users Table** *(v2.4.0 — NEW)*
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    password TEXT,
    full_name TEXT,
    age INTEGER,
    education TEXT,
    created_at TEXT
);
```

### **Saved Analyses Table**
```sql
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
    is_favorite INTEGER DEFAULT 0
);
```

---

## 📊 Build Information

```
App Name        : Klarip
Version         : 2.4.0+1
Framework       : Flutter 3.35.3
Language        : Dart ^3.9.2
AI Model        : Google Gemini 2.5-flash-lite
Local DB        : SQLite (sqflite) — Database Version 2
Session         : SharedPreferences
Architecture    : Client-side only (no backend server)
State Mgmt      : Provider (ChangeNotifier)
```

---

## 🎯 Key Features v2.4.0

### **🔐 Authentication System**
- **Login**: Autentikasi dengan email & password (SQLite)
- **Register**: Buat akun baru dengan validasi email unik
- **Auto-Login**: Session persistence dengan SharedPreferences
- **Auth Routing**: Redirect otomatis ke login jika belum masuk
- **Logout**: Hapus sesi dan kembali ke halaman login

### **👤 Profile Management**
- **Edit Profile**: Ubah nama lengkap, username, usia, pendidikan
- **Change Password**: Verifikasi password lama sebelum mengubah
- **User Model**: Data lengkap (id, username, email, fullName, age, education)

### **🤖 Gemini AI Integration**
- **Smart Analysis**: AI menganalisis klaim dan memberikan penjelasan
- **Custom Logo**: Google Gemini logo dengan fallback gradient
- **Tabbed UI**: PageView untuk switch antara AI analysis dan search results
- **Verdict System**: 3 verdict (DIDUKUNG_DATA, TIDAK_DIDUKUNG_DATA, MEMERLUKAN_VERIFIKASI)

### **💾 Local Collection System**
- **Save Analysis**: Simpan hasil analisis AI ke SQLite
- **Save Search Result**: Simpan hasil pencarian web ke koleksi
- **Personal Notes**: Tambah/edit catatan pribadi per-koleksi
- **Favorites**: Tandai koleksi sebagai favorit
- **Delete**: Hapus koleksi dengan konfirmasi dialog

### **🎨 Enhanced UI/UX**
- **Spotify-Inspired Design**: Dark theme dengan SpotifyMix font
- **Custom Branding**: Logo Klarip untuk semua platform
- **Responsive Design**: Mobile-first dengan desktop optimization
- **Loading States**: Smooth animations dan error handling

---

## 📝 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

## 👥 Authors & Contributors

- **Elloe** — *Project Creator & Maintainer*

## 🙏 Acknowledgments

- **Google Gemini AI** — AI-powered fact-checking capabilities
- **Google Custom Search API** — Untuk search functionality
- **Flutter Team** — Amazing cross-platform framework
- **Indonesian Fact-Checking Community** — Inspiration dan support
- **Spotify Design System** — UI/UX inspiration dan font family

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

[![GitHub stars](https://img.shields.io/github/stars/Elloe2/aplikasi-klarifikasi.svg?style=social&label=Star)](https://github.com/Elloe2/aplikasi-klarifikasi)
[![GitHub forks](https://img.shields.io/github/forks/Elloe2/aplikasi-klarifikasi.svg?style=social&label=Fork)](https://github.com/Elloe2/aplikasi-klarifikasi/fork)

**Made with ❤️ for the Indonesian fact-checking community**

</div>
