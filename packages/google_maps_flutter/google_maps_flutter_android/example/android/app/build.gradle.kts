plugins {
  id("com.android.application")
  id("dev.flutter.flutter-gradle-plugin")
}

val agpMajorVersion = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION.substringBefore('.').toInt()
val builtInKotlinProperty = providers.gradleProperty("android.builtInKotlin").orNull
val isBuiltInKotlinEnabled =
    agpMajorVersion >= 9 && (builtInKotlinProperty == null || builtInKotlinProperty.toBoolean())

if (!isBuiltInKotlinEnabled) {
  apply(plugin = "org.jetbrains.kotlin.android")
}

android {
  namespace = "io.flutter.plugins.googlemapsexample"
  compileSdk = flutter.compileSdkVersion

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }

  if (!isBuiltInKotlinEnabled) {
    withGroovyBuilder {
      "kotlinOptions" { setProperty("jvmTarget", JavaVersion.VERSION_17.toString()) }
    }
  }

  defaultConfig {
    applicationId = "io.flutter.plugins.googlemapsexample"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    manifestPlaceholders["mapsApiKey"] = System.getenv("MAPS_API_KEY") ?: ""
  }

  buildTypes { release { signingConfig = signingConfigs.getByName("debug") } }
  lint { disable.add("InvalidPackage") }

  testOptions { unitTests { isIncludeAndroidResources = true } }
}

flutter { source = "../.." }

dependencies {
  testImplementation("junit:junit:4.13.2")
  androidTestImplementation("androidx.test:runner:1.2.0")
  androidTestImplementation("androidx.test.espresso:espresso-core:3.2.0")
  api("androidx.test:core:1.4.0")
  testImplementation("com.google.android.gms:play-services-maps:17.0.0")
  testImplementation("com.google.maps.android:android-maps-utils:4.0.0")
}
