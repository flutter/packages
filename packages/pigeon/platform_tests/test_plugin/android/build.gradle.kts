import org.jetbrains.kotlin.gradle.dsl.JvmTarget

group = "com.example.test_plugin"
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
        allWarningsAsErrors = true
    }
}

android {
    namespace = "com.example.test_plugin"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdk = 24
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

    lint {
        checkAllWarnings = true
        warningsAsErrors = true
        disable.addAll(setOf("AndroidGradlePluginVersion", "InvalidPackage", "GradleDependency", "NewerVersionAvailable"))
        baseline = file("lint-baseline.xml")
    }

    dependencies {
        compileOnly("javax.annotation:javax.annotation-api:1.3.2")
        testImplementation("junit:junit:4.13.2")
        testImplementation("io.mockk:mockk:1.14.9")
        // org.jetbrains.kotlin:kotlin-bom artifact purpose is to align kotlin stdlib and related code versions.
        // See: https://youtrack.jetbrains.com/issue/KT-55297/kotlin-stdlib-should-declare-constraints-on-kotlin-stdlib-jdk8-and-kotlin-stdlib-jdk7
        implementation(platform("org.jetbrains.kotlin:kotlin-bom:2.3.10"))
    }
}
