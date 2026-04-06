import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
var configured = true
try {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
} catch (e: java.io.IOException) {
    configured = false
    logger.error("Release signing information not found.")
}

val appId = keystoreProperties.getProperty("appId") ?: "io.flutter.plugins.inapppurchaseexample.DEFAULT_DO_NOT_USE"
val keystoreStoreFile = if (configured) rootProject.file(keystoreProperties.getProperty("storeFile")) else null
val keystoreStorePassword = keystoreProperties.getProperty("storePassword")
val keystoreKeyAlias = keystoreProperties.getProperty("keyAlias")
val keystoreKeyPassword = keystoreProperties.getProperty("keyPassword")
val versionCodeVal = keystoreProperties.getProperty("versionCode")?.toInt() ?: 1
val versionNameVal = keystoreProperties.getProperty("versionName") ?: "0.0.1"

if (appId == "io.flutter.plugins.inapppurchaseexample.DEFAULT_DO_NOT_USE") {
    configured = false
    logger.error("Unique package name not set, defaulting to \"io.flutter.plugins.inapppurchaseexample.DEFAULT_DO_NOT_USE\".")
}

if (!configured) {
    logger.error("The app could not be configured for release signing. In app purchases will not be testable. See `example/README.md` for more info and instructions.")
}

android {
    namespace = "io.flutter.plugins.inapppurchaseexample"
    compileSdk = flutter.compileSdkVersion
    
    signingConfigs {
        create("release") {
            storeFile = keystoreStoreFile
            storePassword = keystoreStorePassword
            keyAlias = keystoreKeyAlias
            keyPassword = keystoreKeyPassword
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = appId
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = versionCodeVal
        versionName = versionNameVal
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        getByName("debug") {
            if (configured) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
        getByName("release") {
            if (configured) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

    testOptions {
        unitTests {
            isReturnDefaultValues = true
        }
    }

    lint {
        disable.add("InvalidPackage")
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.android.billingclient:billing:3.0.2")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:5.0.0")
    testImplementation("org.json:json:20251224")
    androidTestImplementation("androidx.test:runner:1.1.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.1.1")
}
