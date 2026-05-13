group = "io.flutter.plugins.quickactions"
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
    namespace = "io.flutter.plugins.quickactions"
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
        implementation("androidx.annotation:annotation:1.9.1")
        testImplementation("junit:junit:4.13.2")
        testImplementation("org.mockito:mockito-core:5.23.0")
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
