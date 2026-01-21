plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    // Gunakan '=' untuk penugasan di Kotlin DSL
    namespace = "com.example.firefit"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Gunakan 'is' dan '=' untuk properti boolean
        isCoreLibraryDesugaringEnabled = true
        
        // Gunakan '=' untuk compatibility
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        // Pastikan nilai String menggunakan tanda petik
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.firefit"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Gunakan '=' untuk multiDex
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // Gunakan getByName untuk mengakses build type di KTS
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Sintaksis fungsi untuk dependencies di KTS
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
    implementation("com.google.firebase:firebase-analytics")
}