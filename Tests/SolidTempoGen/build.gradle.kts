plugins {
  kotlin("jvm") version "2.1.20"
  application
}

group = "io.solidfoundation"
version = "1.0-SNAPSHOT"

repositories {
  mavenCentral()
}

dependencies {
  implementation("com.github.ajalt.clikt:clikt:5.0.3")
  implementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.18.3")
  implementation("com.fasterxml.jackson.datatype:jackson-datatype-jsr310:2.18.3")
  testImplementation(kotlin("test"))
}

tasks.test {
  useJUnitPlatform()
}
kotlin {
  jvmToolchain(21)
}
application {
  mainClass = "io.solidfoundation.MainKt"
}
