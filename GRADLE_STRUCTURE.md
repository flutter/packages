# Gradle Structure

package/example/android/settings.gradle imports the flutter tooling, includes the app directory, and configures GoogleCloudPlatform/artifact-registry-maven-tools for use in ci.

This repo has a GCP instance that mirrors dependencies available from `google()` and `mavenCentral()` used by ci (or googlers). This gives us redundant uptime for dependency availability.

Using this cache is not intended or avaiable for contributors outside of CI. We protect that execution with an environment variable `ARTIFACT_HUB_REPOSITORY` to ensure that by default users do not see rejected cloud credentials or errors in builds.

Googlers can debug locally by setting `ARTIFACT_HUB_REPOSITORY` to the valid artifact hub value and authenticating with GCP. To authenticate run `gcloud auth application-default login`. To find artifact hub url use `<url>` section of go/artifact-hub#maven or inspect the value on CI servers. CI uses a service account for billing. That is defined in go/artifact-hub-service-account (googler access only).

## Useful links for debuging
https://github.com/GoogleCloudPlatform/artifact-registry-maven-tools/blob/master/README.md
https://docs.gradle.org/current/userguide/declaring_repositories.html
https://docs.gradle.org/current/userguide/viewing_debugging_dependencies.html

Comamnd to force refresh of dependencies `./gradlew app:dependencies --configuration <SOME_TASK> --refresh-dependencies`