group = "io.flutter.plugins.imagepicker"
version = "1.0-SNAPSHOT"

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.13.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "io.flutter.plugins.imagepicker"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        minSdk = 24
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    lint {
        checkAllWarnings = true
        warningsAsErrors = true
        disable.addAll(setOf("AndroidGradlePluginVersion", "InvalidPackage", "GradleDependency", "NewerVersionAvailable"))
    }

    dependencies {
        implementation("androidx.core:core:1.18.0")
        implementation("androidx.annotation:annotation:1.9.1")
        implementation("androidx.exifinterface:exifinterface:1.4.2")
        implementation("androidx.activity:activity:1.12.4")

        testImplementation("junit:junit:4.13.2")
        testImplementation("org.mockito:mockito-core:5.23.0")
        testImplementation("androidx.test:core:1.7.0")
        testImplementation("org.robolectric:robolectric:4.16")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            isReturnDefaultValues = true
            all {
                it.outputs.upToDateWhen { false }
                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}
