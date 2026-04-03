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

val appId: String = keystoreProperties.getProperty("appId") ?: "io.flutter.plugins.inapppurchaseexample.DEFAULT_DO_NOT_USE"
val keystoreStoreFile: File? = if (configured) rootProject.file(keystoreProperties.getProperty("storeFile")) else null
val keystoreStorePassword = keystoreProperties.getProperty("storePassword")
val keystoreKeyAlias = keystoreProperties.getProperty("keyAlias")
val keystoreKeyPassword = keystoreProperties.getProperty("keyPassword")
val vCode: Int = keystoreProperties.getProperty("versionCode")?.toInt() ?: 1
val vName: String = keystoreProperties.getProperty("versionName") ?: "0.0.1"

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

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            storeFile = keystoreStoreFile
            storePassword = keystoreStorePassword
            keyAlias = keystoreKeyAlias
            keyPassword = keystoreKeyPassword
        }
    }

    defaultConfig {
        applicationId = appId
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = vCode
        versionName = vName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        debug {
            if (configured) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
        release {
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
    implementation("com.android.billingclient:billing:6.1.0")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:5.1.1")
    testImplementation("org.json:json:20251224")
    androidTestImplementation("androidx.test:runner:1.1.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.1.1")
}
