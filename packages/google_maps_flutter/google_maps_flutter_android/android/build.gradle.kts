import org.jetbrains.kotlin.gradle.dsl.JvmTarget

group = "io.flutter.plugins.googlemaps"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.3.20"
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
    namespace = "io.flutter.plugins.googlemaps"
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
        implementation("com.google.android.gms:play-services-maps:20.0.0")
        implementation("com.google.maps.android:android-maps-utils:4.1.0")
        androidTestImplementation("androidx.test:runner:1.7.0")
        androidTestImplementation("androidx.test:rules:1.7.0")
        androidTestImplementation("androidx.test.espresso:espresso-core:3.7.0")
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
                // The org.gradle.jvmargs property that may be set in gradle.properties does not impact
                // the Java heap size when running the Android unit tests. The following property here
                // sets the heap size to a size large enough to run the robolectric tests across
                // multiple SDK levels.
                it.jvmArgs("-Xmx4G")
            }
        }
    }
}
