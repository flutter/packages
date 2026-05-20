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
  namespace = "dev.flutter.plugins.file_selector_example"
  compileSdk = flutter.compileSdkVersion
  ndkVersion = flutter.ndkVersion

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
    applicationId = "dev.flutter.plugins.file_selector_example"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
  }

  buildTypes { release { signingConfig = signingConfigs.getByName("debug") } }
}

flutter { source = "../.." }
