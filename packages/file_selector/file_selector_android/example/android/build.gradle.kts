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
    project(":file_selector_android") {
        // Workaround for a warning when building that the above turns into
        // an error:
        //   Cannot find annotation method 'api()' in type 'RequiresApi': class
        //   file for android.annotation.RequiresApi not found
        tasks.withType<JavaCompile> {
            options.compilerArgs.addAll(listOf("-Xlint:all", "-Werror", "-Xlint:-classfile"))
        }
    }
}
