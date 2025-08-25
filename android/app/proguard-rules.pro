# Configuration ProGuard pour NawaraBloom WebView

# WebView et JavaScript Interface - CRITIQUE
-keepattributes JavascriptInterface
-keep class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Classes WebView Android
-keep class androidx.webkit.** { *; }
-keep class android.webkit.** { *; }

# Plugin WebView Flutter
-keep class io.flutter.plugins.webviewflutter.** { *; }
-keep class io.flutter.plugins.webviewflutter_android.** { *; }

# Flutter core pour WebView
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Classes avec annotations Keep
-keep @androidx.annotation.Keep class * { *; }
-keep class * {
    @androidx.annotation.Keep <fields>;
    @androidx.annotation.Keep <methods>;
}

# Classes de votre application
-keep class com.nawarabloom.** { *; }

# Reflection utilisée par WebView
-keepclassmembers class * {
    void *(android.webkit.WebView, java.lang.String, java.lang.String);
}

# Configuration réseau
-keep class javax.net.ssl.** { *; }
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**
-dontwarn javax.net.ssl.**

# Désactiver l'obfuscation agressive qui cause des problèmes
-dontobfuscate
-dontoptimize
-dontshrink

# Garder les stack traces lisibles
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task