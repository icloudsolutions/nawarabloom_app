# 🚀 Flutter Project with GitHub Actions APK Release

This Flutter project is configured to automatically build a release APK and upload it to GitHub Releases whenever a new version tag is pushed.

## 📦 Features

- ✅ Build Flutter APK in release mode  
- ✅ Automate APK builds with GitHub Actions  
- ✅ Automatically attach APK to GitHub Release  
- ✅ Tag-based deployment (e.g., `v1.0.0`)

---

## 🛠️ How It Works

A GitHub Actions workflow is set up in `.github/workflows/flutter-apk-release.yml`.

When you push a tag like `v1.0.0`, it will:
1. Clone the project  
2. Set up Flutter  
3. Run `flutter pub get`  
4. Build `app-release.apk`  
5. Upload the APK to a new GitHub Release

---

## 🚀 Getting Started

### 1. Install Flutter and set up your project

Make sure your environment is working by running:

```bash
flutter doctor
