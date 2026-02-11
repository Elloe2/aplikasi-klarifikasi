# 🌟 Klarifikasi.id v2.2.0

[![Flutter](https://img.shields.io/badge/Flutter-3.35.3-blue.svg)](https://flutter.dev)
[![Gemini AI](https://img.shields.io/badge/Gemini-AI%20Powered-green.svg)](https://ai.google.dev)
[![Version](https://img.shields.io/badge/Version-2.2.0-green.svg)](https://github.com/Elloe2/Klarifikasi.id)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Aplikasi fact-checking modern dengan AI Gemini** yang dibangun dengan Flutter untuk membantu pengguna memverifikasi kebenaran informasi dan klaim secara real-time menggunakan teknologi AI terdepan. Semua data disimpan secara lokal di perangkat pengguna.

## 📝 Ringkasan Singkat

- **Apa ini?** Aplikasi fact-checking berbasis web & Android untuk menganalisis klaim dengan bantuan Google Gemini AI dan Google Custom Search.
- **Tech stack utama:** Flutter 3.35.3, Google Gemini 2.5-flash-lite, Google CSE, SQLite (local storage).
- **Arsitektur:** Fully client-side — semua API dipanggil langsung dari Flutter, tanpa backend server.
- **Frontend produksi:**
  - Cloudhebat: `https://www.klarifikasi.rj22d.my.id/`
  - GitHub Pages: `https://elloe2.github.io/Klarifikasi.id/`

**Cara jalanin lokal (web):**

```bash
flutter clean
flutter pub get
flutter run -d chrome --web-port 8000
```

**Build untuk produksi (web):**

```bash
flutter build web --release
```

Output akan tersimpan di `build/web` dan bisa di-copy ke hosting.

---

## ✨ Fitur Unggulan

### 🤖 **AI-Powered Fact-Checking**
- **Gemini AI Integration**: Google Gemini AI untuk analisis klaim cerdas
- **Real-time Search**: Pencarian informasi dengan Google Custom Search Engine
- **Smart Analysis**: AI memberikan penjelasan dan sumber terpercaya
- **Verdict System**: DIDUKUNG_DATA / TIDAK_DIDUKUNG_DATA / MEMERLUKAN_VERIFIKASI

### 🔍 **Advanced Search System**
- **Google CSE**: Integrasi langsung (client-side) dengan Google Custom Search Engine
- **Rich Results**: Preview hasil pencarian dengan thumbnail dan snippet
- **Rate Limiting**: Cooldown 5 detik untuk mencegah spam
- **Social Media Detection**: Format khusus untuk link Instagram, X, YouTube, dll.

### 💾 **Local Storage System**
- **SQLite Database**: Penyimpanan analisis secara lokal di perangkat
- **CRUD Operations**: Simpan, baca, edit catatan, dan hapus koleksi
- **Favorite System**: Tandai koleksi favorit
- **Personal Notes**: Tambah catatan pribadi pada setiap koleksi

### 🎨 **Modern UI/UX**
- **Spotify-Inspired Design**: Dark theme dengan SpotifyMix font family
- **Responsive Design**: Optimized untuk desktop, tablet, dan mobile
- **Custom Branding**: Logo Klarifikasi.id untuk favicon dan PWA icons
- **Loading Animations**: Smooth loading states dengan custom animations
- **Error Handling**: Comprehensive error dialogs dan feedback

### 📱 **Multi-Platform Support**
- **Flutter Web**: Aplikasi web modern dengan performa tinggi
- **Android App**: Native Android application dengan APK build
- **PWA Ready**: Progressive Web App dengan service worker
- **Cross-Platform**: Satu codebase untuk semua platform

## 📋 Changelog

### **v2.2.0** - Local Storage Focus (Current)
- 💾 **Local-Only Architecture**: Semua data disimpan lokal, tanpa backend server
- 🗄️ **SQLite Integration**: CRUD koleksi dengan sqflite
- ⭐ **Favorite & Notes**: Fitur favorit dan catatan pribadi
- 🤖 **Gemini 2.5-flash-lite**: Upgrade model AI terbaru

### **v2.0.0** - Major Update
- ✨ **Gemini AI Integration**: Added Google Gemini AI for intelligent fact-checking
- 🎨 **Custom Gemini Logo**: Authentic Google Gemini branding with diamond shape
- 🔄 **Collapsible UI**: Gemini chatbot now uses ExpansionTile for better UX
- 🗑️ **Simplified Analysis**: Removed HOAX/FAKTA system, focus on explanations
- 🎯 **Enhanced UX**: Better loading states and error handling

### **v1.0.0** - Initial Release
- 🎉 **Core Features**: Search and basic fact-checking
- 📱 **Responsive**: Mobile-first design with Flutter
- 🎨 **Modern UI**: Spotify-inspired dark theme

## 🌐 Production URLs

- **Frontend (Cloudhebat)**: https://www.klarifikasi.rj22d.my.id/
- **Frontend (GitHub Pages)**: https://elloe2.github.io/Klarifikasi.id/
- **GitHub Repository**: https://github.com/Elloe2/Klarifikasi.id

## 🏗️ Arsitektur Aplikasi

### **📐 System Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    🌐 USER LAYER                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│  📱 Flutter Web App          │  📱 Flutter Android App    │  🌐 PWA Browser     │
│  • Chrome/Safari/Firefox     │  • Native Android APK     │  • Service Worker   │
│  • Responsive Design         │  • Offline Capability     │  • App-like Exp.    │
│  • PWA Features              │  • Material Design        │  • Push Notif.      │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                🎨 PRESENTATION LAYER                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│  🎯 Flutter Frontend (Multi-Platform, Client-Side Only)                         │
│  ├── 📱 Pages Layer                                                             │
│  │   ├── search_page.dart          # Main search interface with Gemini AI     │
│  │   ├── saved_page.dart           # Koleksi analisis tersimpan (CRUD)        │
│  │   └── settings_page.dart        # Info aplikasi & sumber terpercaya        │
│  ├── 🧩 Widgets Layer                                                          │
│  │   ├── gemini_chatbot.dart       # AI analysis display widget               │
│  │   ├── gemini_logo.dart          # Custom Gemini logo widget                │
│  │   ├── search_result_card.dart   # Card hasil pencarian                     │
│  │   ├── source_details_list.dart  # Detail sumber per-analisis               │
│  │   └── error_banner.dart         # Error handling UI                        │
│  ├── 🔄 State Management                                                       │
│  │   └── saved_analysis_provider   # Koleksi state provider (ChangeNotifier)  │
│  └── 🌐 Services Layer                                                         │
│      ├── search_api.dart           # Google CSE API calls (direct)            │
│      ├── gemini_service.dart       # Google Gemini AI API calls (direct)      │
│      └── database_helper.dart      # SQLite local database operations         │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                              ┌─────────┴─────────┐
                              ▼                   ▼
┌─────────────────────────────────────┐ ┌─────────────────────────────────────┐
│        🤖 AI SERVICES LAYER         │ │       💾 LOCAL STORAGE LAYER         │
├─────────────────────────────────────┤ ├─────────────────────────────────────┤
│  🧠 Google Gemini AI Service        │ │  🗄️ SQLite Database                 │
│  ├── Model: gemini-2.5-flash-lite   │ │  ├── saved_analyses table           │
│  ├── Prompt Engineering (ID)        │ │  │   ├── id (Primary Key)           │
│  ├── Response Parsing (JSON)        │ │  │   ├── title, claim               │
│  └── Verdict + Analysis Output      │ │  │   ├── verdict, explanation       │
│                                     │ │  │   ├── analysis, confidence       │
│  🔍 Google Custom Search Engine     │ │  │   ├── source_url, user_note      │
│  ├── Real-time web search           │ │  │   ├── saved_at                   │
│  ├── Thumbnail extraction           │ │  │   └── is_favorite                │
│  ├── Indonesian language priority   │ │  └── CRUD Operations                │
│  └── API quota management           │ │      ├── Insert, Query, Update      │
│                                     │ │      └── Delete, Toggle Favorite    │
└─────────────────────────────────────┘ └─────────────────────────────────────┘
```

### **🔄 Data Flow Architecture**

```
1. 📱 USER INTERACTION
   User enters claim/query → Flutter UI captures input

2. 🔍 GOOGLE CSE SEARCH (Direct API Call)
   Flutter → HTTP GET → Google Custom Search API
   → Returns: List<SearchResult> (title, snippet, link, thumbnail)

3. 🤖 GEMINI AI ANALYSIS (Direct API Call)
   Flutter → HTTP POST → Google Gemini API
   → Input: Claim + Search Results
   → Returns: GeminiAnalysis (verdict, explanation, confidence)

4. 📊 UI DISPLAY
   PageView[0] = Gemini AI Analysis (verdict, explanation)
   PageView[1] = Search Results (list of sources)

5. 💾 OPTIONAL LOCAL SAVE
   User saves analysis → SavedAnalysisProvider → DatabaseHelper → SQLite
   User can add personal notes and toggle favorites
```

## 📁 Project Structure

### **🎯 Flutter App Structure**

```
Klarifikasi.id Frontend/
├── 📱 lib/                                    # Main application code
│   ├── 🎯 app/                               # Application structure
│   │   ├── app.dart                          # Main app widget with providers
│   │   └── home_shell.dart                   # Bottom navigation shell (3 tabs)
│   ├── 📊 models/                            # Data models & serialization
│   │   ├── search_result.dart                # Google CSE result model
│   │   ├── gemini_analysis.dart              # Gemini AI analysis model
│   │   ├── saved_analysis.dart               # Saved collection model (CRUD)
│   │   └── source_analysis.dart              # Source stance analysis model
│   ├── 📱 pages/                             # UI Pages & screens
│   │   ├── search_page.dart                  # Main search + AI analysis
│   │   ├── saved_page.dart                   # Koleksi tersimpan (CRUD)
│   │   └── settings_page.dart                # Info app & sumber terpercaya
│   ├── 🔄 providers/                         # State management
│   │   └── saved_analysis_provider.dart      # Koleksi state (ChangeNotifier)
│   ├── 🌐 services/                          # API services & local DB
│   │   ├── search_api.dart                   # Google CSE direct API calls
│   │   ├── gemini_service.dart               # Google Gemini direct API calls
│   │   └── database_helper.dart              # SQLite database helper
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
│   ├── logo/                                # Klarifikasi.id & Gemini logos
│   └── fonts/                               # Custom fonts (SpotifyMix)
├── 📱 android/                               # Android-specific configuration
├── 🌐 web/                                   # Web-specific configuration
│   ├── index.html                            # Main HTML file
│   ├── manifest.json                         # PWA manifest
│   └── favicon.png                           # Custom favicon
└── 📋 README.md                              # Documentation
```

## 🛠️ Tech Stack

### **Flutter App (Client-Side)**
| Technology | Version | Purpose |
|-----------|---------|---------|
| Flutter | 3.35.3 | Cross-platform UI framework |
| Dart | ^3.9.2 | Programming language |
| Provider | ^6.1.2 | State management |
| sqflite | ^2.4.2 | SQLite local database |
| http | ^1.2.2 | HTTP client for API calls |
| url_launcher | ^6.3.1 | Open URLs in browser |
| flutter_svg | ^2.0.9 | SVG rendering |
| intl | ^0.19.0 | Internationalization |

### **External APIs (Direct Client-Side Calls)**
| Service | Purpose |
|---------|---------|
| Google Gemini AI (gemini-2.5-flash-lite) | AI-powered claim analysis |
| Google Custom Search Engine | Web search for fact sources |

### **Design System**
- **Theme**: Dark mode (Spotify-inspired)
- **Primary Color**: `#1DB954` (Spotify Green)
- **Font**: SpotifyMix (custom, 7 weights)
- **Design Framework**: Material 3

## 📋 Prerequisites

Sebelum memulai, pastikan Anda memiliki:

- **Flutter SDK** (3.9.2+) - [Download](https://flutter.dev/docs/get-started/install)
- **Google Custom Search API Key** - [Get Key](https://console.cloud.google.com/)
- **Google Gemini API Key** - [Get Key](https://ai.google.dev/)

## 💾 Database Schema (SQLite Local)

### **Saved Analyses Table**
```sql
CREATE TABLE saved_analyses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    claim TEXT,
    verdict TEXT,
    explanation TEXT,
    analysis TEXT,
    confidence TEXT,
    source_url TEXT,
    user_note TEXT,
    saved_at TEXT,
    is_favorite INTEGER
);
```

## 🚀 Deployment Status

### **✅ Production Ready**
- **Frontend**: ✅ Deployed di GitHub Pages dan Cloudhebat
- **AI Integration**: ✅ Gemini AI fully integrated (client-side)
- **Local Storage**: ✅ SQLite untuk Android, in-memory untuk Web
- **Custom Branding**: ✅ Logo Klarifikasi.id applied
- **Automated Deployment**: ✅ PowerShell script ready

### **🌐 Live URLs**
- **GitHub Pages**: https://elloe2.github.io/Klarifikasi.id/
- **Cloudhebat**: https://www.klarifikasi.rj22d.my.id/

### **📊 Build Information**
```
Framework: Flutter 3.35.3
AI Model: Google Gemini 2.5-flash-lite
Local DB: SQLite (sqflite)
Architecture: Client-side only (no backend)
Deployment: Automated via PowerShell
```

## 🎯 Key Features v2.2.0

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
- **Custom Branding**: Logo Klarifikasi.id untuk semua platform
- **Responsive Design**: Mobile-first dengan desktop optimization
- **Loading States**: Smooth animations dan error handling

### **🔧 Technical Architecture**
- **Client-Side Only**: No backend server required
- **Direct API Calls**: Google CSE & Gemini API called directly from Flutter
- **Local Persistence**: SQLite for saving analyses and collections
- **Provider Pattern**: ChangeNotifier for reactive state management
- **PWA Support**: Service worker untuk offline capability

## 📝 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

## 👥 Authors & Contributors

- **Elloe** - *Project Creator & Maintainer*

## 🙏 Acknowledgments

- **Google Gemini AI** - AI-powered fact-checking capabilities
- **Google Custom Search API** - Untuk search functionality
- **Flutter Team** - Amazing cross-platform framework
- **Indonesian Fact-Checking Community** - Inspiration dan support
- **Spotify Design System** - UI/UX inspiration dan font family

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

[![GitHub stars](https://img.shields.io/github/stars/Elloe2/Klarifikasi.id.svg?style=social&label=Star)](https://github.com/Elloe2/Klarifikasi.id)
[![GitHub forks](https://img.shields.io/github/forks/Elloe2/Klarifikasi.id.svg?style=social&label=Fork)](https://github.com/Elloe2/Klarifikasi.id/fork)

**Made with ❤️ for the Indonesian fact-checking community**

</div>
