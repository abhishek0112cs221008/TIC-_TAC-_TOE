// This section configures the buildscript itself, including the repositories and plugins
// required to build your project.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

// This section declares the plugins and their versions that are available to all modules.
// The 'apply false' keyword ensures that the plugins are not automatically applied
// to this top-level file, but are instead available for sub-projects to use.
plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

// This section applies the repositories to all sub-projects, ensuring they can
// access dependencies from Google's and Maven Central's repositories.
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// This sets the root project's build directory and configures all sub-projects.
rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

subprojects {
    project.evaluationDependsOn(":app")
}

// This task is a standard utility to clean the project build directories,
// which is often necessary to resolve build issues.
tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
