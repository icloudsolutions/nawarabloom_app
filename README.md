Sure! Here's the **full updated `README.md`** with your Flutter GitHub Actions release setup and the **contact info for iCloud Solutions** included at the end:

---

````markdown
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
````

### 2. Add the GitHub Actions Workflow

The file `.github/workflows/flutter-apk-release.yml` is already included.
If not, create it with this content:

```yaml
name: Build and Release Flutter APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.x'

      - name: Install dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK to GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 🏁 How to Release a Version

### Step 1: Commit your code

```bash
git add .
git commit -m "Prepare v1.0.0 release"
git push
```

### Step 2: Tag the release and push

```bash
git tag v1.0.0
git push origin v1.0.0
```

### ✅ Done!

GitHub Actions will run, build your APK, and attach it to a new release under the [Releases](./releases) section.

---

## 📂 Output

After a successful run, you’ll find the generated APK here:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---

## 📞 Contact

**📧 Email:** [contact@icloud-solutions.net](mailto:contact@icloud-solutions.net)
**🌍 Website:** [www.icloud-solutions.net](https://www.icloud-solutions.net)
**📱 WhatsApp:** [+216 50 271 737](https://wa.me/21650271737)
**🏢 Company:** [iCloud Solutions](https://www.icloud-solutions.net)

```

---

Let me know if you also want a version with badges (e.g., build status, Flutter version) or multilingual (French or Arabic) support.
```
