import org.gradle.api.tasks.Delete
import org.gradle.kotlin.dsl.*

buildscript {
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10") // ✅ Updated Kotlin version
        classpath("com.android.tools.build:gradle:7.4.0") 
        
             // ✅ Updated Android Gradle plugin
    }

    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Set new unified build directory outside of module
val newBuildDir = layout.buildDirectory.dir("../../build").get()
layout.buildDirectory.set(newBuildDir)

// Ensure all subprojects share the same build dir
subprojects {
    val subprojectBuildDir = newBuildDir.dir(name)
    layout.buildDirectory.set(subprojectBuildDir)

    evaluationDependsOn(":app")
}

// Register the clean task
tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}
