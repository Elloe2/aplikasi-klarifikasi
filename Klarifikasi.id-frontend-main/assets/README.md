# Assets Folder - Klarifikasi.id

## Icons (assets/icons/)

Berisi icon-icon yang digunakan dalam aplikasi:

### Navigation Icons
- `search.png` - Icon untuk tab Search (24x24px) - **DETAILED SPECS BELOW**
- `search.svg` - Icon search dalam format SVG (24x24px) - **READY TO USE**
- `history.png` - Icon untuk tab History (24x24px) - **DETAILED SPECS BELOW**
- `history.svg` - Icon history dalam format SVG (24x24px) - **READY TO USE**
- `settings.png` - Icon untuk tab Settings (24x24px) - **DETAILED SPECS BELOW**
- `user.png` - Icon untuk profil user (24x24px) - **DETAILED SPECS BELOW**

### SVG Icons (Recommended)
✅ **search.svg** - Clean magnifying glass icon (white stroke)
✅ **history.svg** - Simple clock icon (white stroke)

## Images (assets/images/)

Berisi gambar-gambar aplikasi:

- `logo.png` - Logo aplikasi (192x192px) - **DETAILED SPECS BELOW**

## 🎨 **DETAILED ICON SPECIFICATIONS**

### **Search Icon (🔍)**
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <circle cx="11" cy="11" r="8" stroke="white" stroke-width="2"/>
  <line x1="21" y1="21" x2="16.65" y2="16.65" stroke="white" stroke-width="2"/>
</svg>
```

### **History Icon (📚)**
```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <circle cx="12" cy="12" r="10" stroke="white" stroke-width="2"/>
  <line x1="12" y1="6" x2="12" y2="12" stroke="white" stroke-width="2"/>
  <line x1="12" y1="12" x2="16" y2="12" stroke="white" stroke-width="2"/>
</svg>
```

## 🚀 **CARA MENGGUNAKAN**

### **1. Flutter Built-in Icons (Recommended)**
```dart
// Icons yang sudah tersedia di Flutter
Icon(Icons.search)           // Search icon
Icon(Icons.history)          // History icon
Icon(Icons.settings)         // Settings icon
Icon(Icons.person)           // User icon
```

### **2. Custom SVG Icons (Alternative)**
```dart
// Tambahkan dependency flutter_svg di pubspec.yaml terlebih dahulu
dependencies:
  flutter_svg: ^2.0.9

// Kemudian gunakan SVG icons
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset('assets/icons/search.svg')
SvgPicture.asset('assets/icons/history.svg')
```

### **3. PNG Icons (Jika menggunakan file gambar)**
```dart
// Setelah download PNG icons
Image.asset('assets/icons/search.png', width: 24, height: 24)
```

## 📥 **MENDAPATKAN ICONS**

### **Quick Setup (Gunakan SVG yang sudah ada)**
```dart
// SVG icons sudah ready di assets/icons/
✅ search.svg - Clean magnifying glass
✅ history.svg - Simple clock

// Hanya perlu tambahkan dependency flutter_svg di pubspec.yaml
dependencies:
  flutter_svg: ^2.0.9
```

### **Custom Icons dari Web**
- 🌐 **Flaticon**: https://www.flaticon.com/
- 🎨 **Icons8**: https://icons8.com/
- 📱 **Material Icons**: https://fonts.google.com/icons

### **Format yang Disarankan**
- **SVG** (Recommended) - Scalable, crisp, small file size
- **PNG** (Alternative) - Jika perlu transparency

## 🛠️ **TECHNICAL USAGE**

### **Navigation Bar Icons**
```dart
NavigationDestination(
  icon: SvgPicture.asset('assets/icons/search.svg', width: 24, height: 24),
  selectedIcon: SvgPicture.asset('assets/icons/search.svg', width: 24, height: 24, color: Colors.white),
  label: 'Cari',
)
```

### **Color Theming**
```dart
// Untuk dark theme
SvgPicture.asset('assets/icons/search.svg', color: Colors.white)

// Untuk active state
SvgPicture.asset('assets/icons/search.svg', color: Color(0xFF00d4ff))
```

## 🎯 **REKOMENDASI**

### **Untuk Development Cepat**
✅ **Gunakan SVG icons yang sudah ada** - Simple, clean, professional
✅ **Fallback ke Material Icons** - Jika SVG tidak diperlukan

### **Untuk Production**
📥 **Download custom icons** dari sumber terpercaya
🎨 **Ikuti brand guidelines** aplikasi
⚡ **Optimasi ukuran file** untuk performa

## ✅ **CURRENT STATUS**

- ✅ **SVG Icons**: Created dan ready to use
- ✅ **PNG Placeholders**: Detailed specifications provided
- ✅ **Assets Config**: Updated in pubspec.yaml
- ✅ **Documentation**: Complete usage guide

**Icons sekarang siap digunakan! Pilih antara SVG icons yang sudah ada atau download custom icons sesuai kebutuhan.** 🎉
