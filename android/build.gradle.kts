buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.4.1") // 버전은 프로젝트에 맞게 조정 가능
        classpath("com.google.gms:google-services:4.3.15") // Firebase 구글 서비스 플러그인
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 기존 내용 유지
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
// 로그인 구현을 위한 플러그인 추가
plugins {
    id("com.google.gms.google-services")
}
