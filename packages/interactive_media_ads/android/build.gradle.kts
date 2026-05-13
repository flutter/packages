import org.jetbrains.kotlin.gradle.dsl.JvmTarget

group = "dev.flutter.packages.interactive_media_ads"
version = "1.0-SNAPSHOT"

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
    namespace = "dev.flutter.packages.interactive_media_ads"

    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdk = 24
    }

    dependencies {
        implementation("androidx.annotation:annotation:1.9.1")
        implementation("androidx.core:core-ktx:1.18.0")
        implementation("com.google.ads.interactivemedia.v3:interactivemedia:3.39.0")
        testImplementation("junit:junit:4.13.2")
        testImplementation("org.jetbrains.kotlin:kotlin-test")
        testImplementation("org.mockito.kotlin:mockito-kotlin:6.2.3")
        testImplementation("org.mockito:mockito-inline:5.2.0")
        testImplementation("androidx.test:core:1.7.0")
    }

    lint {
        checkAllWarnings = true
        warningsAsErrors = true
        disable.addAll(setOf("AndroidGradlePluginVersion", "InvalidPackage", "GradleDependency", "NewerVersionAvailable"))
        baseline = file("lint-baseline.xml")
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            isReturnDefaultValues = true
            all {
                it.useJUnitPlatform()
                it.outputs.upToDateWhen { false }
                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}
