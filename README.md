# Absensi App Using Flutter

Aplikasi ini menampilkan kemampuan pengembangan aplikasi mobile modern, integrasi REST API, serta penerapan struktur kode yang terorganisir.

## Project Overview

Aplikasi ini dirancang untuk mencatat kehadiran pengguna secara digital melalui perangkat mobile. Fokus utama proyek adalah:

* implementasi UI Flutter yang rapi,
* komunikasi data menggunakan REST API,
* dan pengelolaan alur aplikasi (authentication & attendance flow).

## Key Features

* User Login & Logout
* Absensi harian berbasis API
* Pengambilan dan pengiriman data ke backend (REST API)
* UI mobile sederhana dan responsif

## Tech Stack

* **Flutter**
* **Dart**
* **REST API**
* Android Emulator / Physical Device

## Project Highlights 

* Clean and structured Flutter project
* Separation of UI, service, and model layers
* API integration using HTTP request
* Suitable as a base for scalable attendance systems

## Getting Started

### Prerequisites

* Flutter SDK (stable version)
* Android Studio / VS Code
* Active backend API endpoint

### Run Locally

```bash
git clone 
cd absensi_app_using_flutter
flutter pub get
flutter run
```

> Pastikan base URL API telah disesuaikan dengan backend yang digunakan.

## Project Structure

```
lib/
├── main.dart
├── screens/     # UI pages
├── models/      # Data models
├── services/    # API services
├── widgets/     # Reusable components
assets/
pubspec.yaml
```

## Notes

* Repository ini hanya berisi **frontend Flutter**
* Backend/API disiapkan secara terpisah
---