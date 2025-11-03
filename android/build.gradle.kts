buildscript {
    extra.apply {
        set("kotlin_version", "2.1.0")
    }
    
    repositories {
        google()
        mavenCentral()
    }
    
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0")
        classpath(kotlin("gradle-plugin", version = "${rootProject.extra["kotlin_version"]}"))
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_17.toString()
        }
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
