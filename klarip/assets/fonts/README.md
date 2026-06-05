# Font SpotifyMix

## Instruksi Penggunaan Font SpotifyMix

### 1. Download Font Files
Silakan download file font SpotifyMix dari sumber resmi dan letakkan di folder ini dengan nama:

- `SpotifyMix-Regular.ttf` (Weight: 400)
- `SpotifyMix-Light.ttf` (Weight: 300)
- `SpotifyMix-Medium.ttf` (Weight: 500)
- `SpotifyMix-SemiBold.ttf` (Weight: 600)
- `SpotifyMix-Bold.ttf` (Weight: 700)
- `SpotifyMix-ExtraBold.ttf` (Weight: 800)
- `SpotifyMix-Black.ttf` (Weight: 900)

### 2. Struktur File yang Diperlukan
```
assets/fonts/
├── SpotifyMix-Regular.ttf
├── SpotifyMix-Light.ttf
├── SpotifyMix-Medium.ttf
├── SpotifyMix-SemiBold.ttf
├── SpotifyMix-Bold.ttf
├── SpotifyMix-ExtraBold.ttf
├── SpotifyMix-Black.ttf
└── README.md (file ini)
```

### 3. Font Weights yang Didukung
- **300**: Light
- **400**: Regular (default)
- **500**: Medium
- **600**: SemiBold
- **700**: Bold
- **800**: ExtraBold
- **900**: Black

### 4. Penggunaan di Flutter
Font sudah dikonfigurasi di `pubspec.yaml` dan `lib/theme/app_theme.dart`. 
Aplikasi akan otomatis menggunakan font SpotifyMix untuk semua text.

### 5. Hot Reload
Setelah menambahkan file font, jalankan:
```bash
flutter clean
flutter pub get
flutter run
```

### Catatan
- Pastikan semua file font memiliki nama yang tepat sesuai konfigurasi
- Font harus dalam format `.ttf` atau `.otf`
- Jika ada masalah dengan font, periksa nama file dan struktur folder
