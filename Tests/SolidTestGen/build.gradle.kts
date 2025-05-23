plugins {
  kotlin("jvm") version "2.1.20"
  application
  id("com.github.harbby.gradle.serviceloader") version "1.1.9"
}

group = "io.github.swift-solid"
version = "1.0-SNAPSHOT"

repositories {
  mavenCentral()
  maven("https://repo.kotlin.link")
}

dependencies {
    implementation("com.github.ajalt.clikt:clikt:5.0.3")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.18.3")
    implementation("com.fasterxml.jackson.datatype:jackson-datatype-jsr310:2.18.3")
    implementation("com.fasterxml.jackson.core:jackson-databind:2.18.3")
    implementation("space.kscience:kmath-core-jvm:0.3.1")
    testImplementation(kotlin("test"))
}

tasks.test {
  useJUnitPlatform()
}

kotlin {
  jvmToolchain(21)
}

serviceLoader {
  serviceInterface("io.github.solidswift.TestGenerator")
}
tasks.test.configure {
  dependsOn(tasks.serviceLoaderBuild)
}

application {
  mainClass = "io.github.solidswift.MainKt"
}
