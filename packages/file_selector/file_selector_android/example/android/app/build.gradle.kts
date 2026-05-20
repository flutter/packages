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
  namespace = "dev.flutter.packages.file_selector_android_example"
  compileSdk = flutter.compileSdkVersion
  ndkVersion = flutter.ndkVersion

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }

  defaultConfig {
    applicationId = "dev.flutter.packages.file_selector_android_example"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
  }

  buildTypes { release { signingConfig = signingConfigs.getByName("debug") } }
}

flutter { source = "../.." }

dependencies {
  testImplementation("junit:junit:4.13.2")
  androidTestImplementation("androidx.test.espresso:espresso-intents:3.4.0")
  androidTestImplementation("androidx.test:runner:1.4.0")
  androidTestImplementation("androidx.test:rules:1.4.0")
  androidTestImplementation("androidx.test.espresso:espresso-core:3.4.0")
  implementation(project(":file_selector_android"))
  implementation(project(":espresso"))
  api("androidx.test:core:1.4.0")
}
