# Keep Flutter platform channel classes
-keepclasseswithmembernames class * {
    native <methods>;
}

-keep class android.webkit.** { *; }
-keep class androidx.webkit.** { *; }
-keep class com.android.internal.webkit.** { *; }
-keep class org.chromium.** { *; }
-keep interface android.webkit.** { *; }
-keep interface androidx.webkit.** { *; }
-keep interface org.chromium.** { *; }
-dontwarn android.webkit.**
-dontwarn androidx.webkit.**
-dontwarn org.chromium.**

-keep class com.smileid.** { *; }
-keep interface com.smileid.** { *; }
-keep class com.smileid.*.* { *; }
-keepclasseswithmembernames class com.smileid.** {
    native <methods>;
}
-keepattributes *Annotation*
-dontwarn com.smileid.**

-keep class java.lang.** { *; }
-keep interface java.lang.** { *; }
-keepclasseswithmembernames class java.lang.** {
    native <methods>;
}

# Google Play Services
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# Kotlin specific
-keep class kotlin.** { *; }
-keep class kotlin.internal.** { *; }
-keep interface kotlin.** { *; }
-dontwarn kotlin.**

# Generic rules
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
