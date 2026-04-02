group = "io.flutter.plugins.camera"
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

tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:deprecation")
    options.compilerArgs.add("-Xlint:unchecked")
}

plugins {
    id("com.android.library")
}

android {
    buildFeatures {
        buildConfig = true
    }
    namespace = "io.flutter.plugins.camera"
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

dependencies {
    implementation("androidx.annotation:annotation:1.9.1")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:5.23.0")
    testImplementation("androidx.test:core:1.7.0")
    testImplementation("org.robolectric:robolectric:4.16")
}
