plugins {
    id("com.android.application") // Apply the Android Application plugin
    kotlin("android") // Apply the Kotlin Android plugin
    id("dev.flutter.flutter-gradle-plugin") // <--- ADD THIS LINE HERE
    // IMPORTANT: Do NOT add 'id("dev.flutter.flutter-gradle-plugin")' here again.
    // It's handled by your root settings.gradle.kts including the Flutter SDK.
}

android {
    namespace = "com.example.tekeray" // <<-- VERIFY THIS IS YOUR ACTUAL PACKAGE NAME -->>
    compileSdk = flutter.compileSdkVersion // Use flutter's defined compileSdkVersion

    defaultConfig {
        minSdk = flutter.minSdkVersion // Use flutter's defined minSdkVersion
        targetSdk = flutter.targetSdkVersion // Use flutter's defined targetSdkVersion
        versionCode = flutter.versionCode // Use flutter's defined versionCode
        versionName = flutter.versionName // Use flutter's defined versionName

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for release builds.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    // --- This is the NDK version line you needed to add for the plugins ---
    ndkVersion = "27.0.12077973"
    // ---------------------------------------------------------------------
}

flutter {
    source="../.." // Points to the root of your Flutter project
}

dependencies {
    // These are common default dependencies. If you had others from before, add them here.
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}