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
  namespace = "io.flutter.plugins.quickactionsexample"
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
    applicationId = "io.flutter.plugins.quickactionsexample"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
  }

  buildTypes { release { signingConfig = signingConfigs.getByName("debug") } }
  lint { disable.add("InvalidPackage") }
}

flutter { source = "../.." }

val androidXTestVersion = "1.4.0"

dependencies {
  testImplementation("junit:junit:4.13.2")
  androidTestImplementation("androidx.test.espresso:espresso-core:3.2.0")
  api("androidx.test:core:$androidXTestVersion")
  androidTestImplementation("androidx.test:runner:$androidXTestVersion")
  androidTestImplementation("androidx.test.uiautomator:uiautomator:2.2.0")
  androidTestImplementation("androidx.test.ext:junit:1.0.0")
  androidTestImplementation("org.mockito:mockito-core:5.0.0")
  androidTestImplementation("org.mockito:mockito-android:5.0.0")
}
