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

// #docregion android_desugaring
android {
  // #enddocregion android_desugaring
  namespace = "dev.flutter.packages.interactive_media_ads_example"
  compileSdk = flutter.compileSdkVersion
  ndkVersion = flutter.ndkVersion

  // #docregion android_desugaring
  compileOptions {
    isCoreLibraryDesugaringEnabled = true
    // #enddocregion android_desugaring
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    // #docregion android_desugaring
  }
  // #enddocregion android_desugaring

  if (!isBuiltInKotlinEnabled) {
    withGroovyBuilder {
      "kotlinOptions" { setProperty("jvmTarget", JavaVersion.VERSION_17.toString()) }
    }
  }

  defaultConfig {
    applicationId = "dev.flutter.packages.interactive_media_ads_example"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
  }

  buildTypes { release { signingConfig = signingConfigs.getByName("debug") } }
  // #docregion android_desugaring
}

// #enddocregion android_desugaring

flutter { source = "../.." }

// #docregion android_desugaring
dependencies {
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
  // #enddocregion android_desugaring
  testImplementation("junit:junit:4.13.2")
  androidTestImplementation("androidx.test:runner:1.2.0")
  androidTestImplementation("androidx.test.espresso:espresso-core:3.2.0")
  api("androidx.test:core:1.4.0")
  // #docregion android_desugaring
}// #enddocregion android_desugaring
