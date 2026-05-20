plugins {
  id("com.android.application")
  id("dev.flutter.flutter-gradle-plugin")
  id("com.google.gms.google-services")
}

val agpMajorVersion = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION.substringBefore('.').toInt()
val builtInKotlinProperty = providers.gradleProperty("android.builtInKotlin").orNull
val isBuiltInKotlinEnabled =
    agpMajorVersion >= 9 && (builtInKotlinProperty == null || builtInKotlinProperty.toBoolean())

if (!isBuiltInKotlinEnabled) {
  apply(plugin = "org.jetbrains.kotlin.android")
}

android {
  namespace = "io.flutter.plugins.googlesigninexample"
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
    applicationId = "io.flutter.plugins.googlesigninexample"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
  }

  buildTypes { release { signingConfig = signingConfigs.getByName("debug") } }

  testOptions { unitTests { isReturnDefaultValues = true } }
  lint { disable.add("InvalidPackage") }
}

flutter { source = "../.." }

dependencies {
  implementation("com.google.android.gms:play-services-auth:16.0.1")
  testImplementation("junit:junit:4.12")
  androidTestImplementation("androidx.test:runner:1.2.0")
  androidTestImplementation("androidx.test.espresso:espresso-core:3.2.0")
  api("androidx.test:core:1.4.0")
}
