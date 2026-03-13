plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.example.ridenowapps"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    buildFeatures {
        compose = true
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    defaultConfig {
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode()
        versionName = flutter.versionName()
        multiDexEnabled = true
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/*.kotlin_module",
                "META-INF/versions/9/OSGI-INF/MANIFEST.MF"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Lifecycle components for Compose compatibility
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.7")
    implementation("androidx.savedstate:savedstate:1.2.1")
    
    // Activity KTX for lifecycle support
    implementation("androidx.activity:activity-ktx:1.9.3")
    
    // Core lifecycle for ViewTreeLifecycleOwner
    implementation("androidx.lifecycle:lifecycle-common:2.8.7")
    
    // Material Design for Smile ID Themes
    implementation("com.google.android.material:material:1.12.0")
    
    // Note: Smile ID SDK is managed by the Flutter smile_id package
    // Do not add manual dependency here to avoid version conflicts
}