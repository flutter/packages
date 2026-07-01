allprojects {
    repositories {
        // See https://github.com/flutter/flutter/blob/master/docs/ecosystem/Plugins-and-Packages-repository-structure.md#gradle-structure for more info.
        val artifactRepoKey = "ARTIFACT_HUB_REPOSITORY"
        val artifactRepoUrl = System.getenv(artifactRepoKey)
        if (artifactRepoUrl != null) {
            println("Using artifact hub")
            maven {
                url = uri(artifactRepoUrl)
            }
        }
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Build the plugin project with warnings enabled. This is here rather than
// in the plugin itself to avoid breaking clients that have different
// warnings (e.g., deprecation warnings from a newer SDK than this project
// builds with).
gradle.projectsEvaluated {
    project(":video_player_android") {
        tasks.withType<JavaCompile> {
            options.compilerArgs.addAll(listOf("-Xlint:all", "-Werror"))
        }
        // Workaround for several warnings when building
        // that the above turns into errors, coming from
        // org.checkerframework.checker.nullness.qual and
        // com.google.errorprone.annotations:
        //
        //   warning: Cannot find annotation method 'value()' in type
        //   'EnsuresNonNull': class file for
        //   org.checkerframework.checker.nullness.qual.EnsuresNonNull not found
        //
        //   warning: Cannot find annotation method 'replacement()' in type
        //   'InlineMe': class file for
        //   com.google.errorprone.annotations.InlineMe not found
        //
        // The dependency version are taken from:
        // https://github.com/google/ExoPlayer/blob/r2.18.1/constants.gradle
        //
        // For future reference the dependencies are excluded here:
        // https://github.com/google/ExoPlayer/blob/r2.18.1/library/common/build.gradle#L33-L34
        dependencies {
            add("implementation", "org.checkerframework:checker-qual:3.13.0")
            add("implementation", "com.google.errorprone:error_prone_annotations:2.10.0")
        }
    }
}
