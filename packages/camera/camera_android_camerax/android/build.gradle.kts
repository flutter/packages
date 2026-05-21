import org.jetbrains.kotlin.gradle.dsl.JvmTarget

group = "io.flutter.plugins.camerax"
version = "1.0"

buildscript {
    val kotlinVersion = "2.3.0"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.13.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
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
    id("kotlin-android")
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.fromTarget(JavaVersion.VERSION_17.toString())
    }
}

android {
    namespace = "io.flutter.plugins.camerax"
    // CameraX dependencies require compilation against version 33 or later.
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // CameraX APIs require API 23 or later.
        minSdk = 23
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
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
                // The org.gradle.jvmargs property that may be set in gradle.properties does not impact
                // the Java heap size when running the Android unit tests. The following property here
                // sets the heap size to a size large enough to run the robolectric tests across
                // multiple SDK levels.
                it.jvmArgs("-Xmx1G")
            }
        }
    }

    lint {
        checkAllWarnings = true
        warningsAsErrors = true
        disable.addAll(setOf("AndroidGradlePluginVersion", "GradleDependency", "InvalidPackage", "NewerVersionAvailable"))
        baseline = file("lint-baseline.xml")
    }
}

dependencies {
    // CameraX core library using the camera2 implementation must use same version number.
    val cameraxVersion = "1.6.0"
    implementation("androidx.camera:camera-core:${cameraxVersion}")
    implementation("androidx.camera:camera-camera2:${cameraxVersion}")
    implementation("androidx.camera:camera-lifecycle:${cameraxVersion}")
    implementation("androidx.camera:camera-video:${cameraxVersion}")
    implementation("com.google.guava:guava:33.5.0-android")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:5.23.0")
    testImplementation("org.mockito:mockito-inline:5.2.0")
    testImplementation("androidx.test:core:1.7.0")
    testImplementation("org.robolectric:robolectric:4.16")
}
