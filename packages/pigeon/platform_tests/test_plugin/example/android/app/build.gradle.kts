plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.test_plugin_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    lint {
        baseline = file("lint-baseline.xml")
    }

    defaultConfig {
        applicationId = "com.example.test_plugin_example"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
// Gradle stub for listing dependencies in JNIgen. If found in
// android/build.gradle.kts, please delete the following task.
tasks.register<DefaultTask>("getReleaseCompileClasspath") {
  // Tell Gradle to complete the configuration phase of all subprojects (eg
  // Flutter plugins) before continuing configuration of this project.
  allprojects {
    if (this != rootProject) {
      evaluationDependsOn(path)
    }
  }

  // Fetch all the dependencies and extract the JARs.
  allprojects {
    val config = configurations.findByName("releaseCompileClasspath") ?: return@allprojects
    try {
      // Find all JARs.
      val jarView = config.incoming.artifactView {
        attributes {
          attribute(org.gradle.api.attributes.Attribute.of("artifactType", String::class.java), "jar")
        }
        lenient(true)
      }
      inputs.files(jarView.files)

      // Also find all JARs stored in AARs.
      val aarView = config.incoming.artifactView {
        attributes {
          attribute(org.gradle.api.attributes.Attribute.of("artifactType", String::class.java), "android-classes-jar")
        }
        lenient(true)
      }
      inputs.files(aarView.files)
    } catch (e: Exception) {}
  }

  // Find all the JARs and print their paths.
  doLast {
    try {
      val cp = mutableListOf<File>()

      // JNIgen uses the first version of a class it finds, so the order we list
      // the JARs in is important.
      val mainProject = allprojects.find { project ->
        project.plugins.hasPlugin("com.android.application")
      } ?: project

      // Start with the android bootClasspath. This contains things like java.*
      // and android.*.
      val android = mainProject.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
      android?.bootClasspath?.let { file -> cp.addAll(file) }

      // Next, add the main project's JARs, followed by all the other project's
      // JARs.
      val projects = (listOf(mainProject) + allprojects).distinct()
      projects.forEach { project ->
        val config = project.configurations.findByName("releaseCompileClasspath") ?: return@forEach
        try {
          // Add all JARs.
          cp.addAll(config.incoming.artifactView {
            attributes {
              attribute(org.gradle.api.attributes.Attribute.of("artifactType", String::class.java), "jar")
            }
            lenient(true)
          }.files)

          // Add all JARs that were contained in AARs.
          cp.addAll(config.incoming.artifactView {
            attributes {
              attribute(org.gradle.api.attributes.Attribute.of("artifactType", String::class.java), "android-classes-jar")
            }
            lenient(true)
          }.files)
        } catch (e: Exception) {}
      }

      // Dedupe and print the absolute paths to all the JARs.
      cp.map { file -> file.absolutePath }.distinct().forEach {
        path -> println(path)
      }
    } catch (e: Exception) {
      System.err.println("Gradle stub cannot find JAR libraries.")
      throw e
    }
  }
  System.err.println("If you are seeing this error in `flutter build` output, it is likely that JNIgen left some stubs in the build.gradle file. Please restore that file from your version control system or manually remove the stub functions named getReleaseCompileClasspath and / or getSources.")
}
