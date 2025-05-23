package io.github.solidswift

import com.github.ajalt.clikt.core.Abort
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.Context
import com.github.ajalt.clikt.core.MultiUsageError
import com.github.ajalt.clikt.core.UsageError
import com.github.ajalt.clikt.parameters.options.default
import com.github.ajalt.clikt.parameters.options.flag
import com.github.ajalt.clikt.parameters.options.multiple
import com.github.ajalt.clikt.parameters.options.option
import com.github.ajalt.clikt.parameters.types.path
import java.nio.file.Path
import java.util.*
import kotlin.io.path.exists


class SolidTestGenerator : CliktCommand("solid-test-generator") {

  override fun help(context: Context) =
    """
    Generates test cases for Solid's Numeric and Tempo classes.
    """.trimIndent()

  private val verbose by option("--verbose", "-v")
    .flag(default = false)

  private val outputDir by option("--output-dir", "-o")
    .path(mustExist = true, canBeFile = false)
    .default(Path.of("."))

  private val pkgPrefix by option("--pkg-prefix")
    .default("Solid")

  private val pkgSuffix by option("--pkg-suffix")
    .default("Tests")

  private val pkgResDir by option("--pkg-res-dir")
    .default("Resources")

  private val filter: List<String> by option(
    "--filter",
    help = """
      Packages and classes to generate tests for as `<pkg>[/cls]`, if no class is specified, test cases for all
      classes in the package will be generated.
    """
  ).multiple(default = listOf())

  private val filterPackages: List<String>
    get() = filter.map { it.substringBefore("/") }

  private val filterClasses: List<String>
    get() = filter.mapNotNull { if (it.contains("/")) it.substringAfter("/") else null }

  private val generators: List<TestGenerator>
    get() = ServiceLoader.load(TestGenerator::class.java).toList()

  override fun run() {
    val errors = buildList {
      val generators = generators.groupBy { it.testPkgName }
      if (generators.isEmpty()) {
        echo("No test generators found", err = true)
        throw Abort()
      }
      for ((pkgName, pkgGenerators) in generators) {
        try {
          runPkg(pkgName, pkgGenerators)
        } catch (e: UsageError) {
          add(e)
        }
      }
    }
    MultiUsageError.buildOrNull(errors)?.let { throw it }
  }

  private fun runPkg(name: String, generators: List<TestGenerator>) {
    if (filterPackages.isNotEmpty() && name !in filterPackages) {
      if (verbose) {
        echo("Skipping package $name")
      }
      return
    }

    echo("Package $name...")

    val pkgOutputDir = outputDir.resolve("$pkgPrefix$name$pkgSuffix").resolve(pkgResDir)
    if (!pkgOutputDir.exists()) {
      throw UsageError("Output directory $pkgOutputDir does not exist")
    }

    for (generator in generators) {
      run(generator, pkgOutputDir)
    }
  }

  private fun run(generator: TestGenerator, pkgOutputDir: Path) {
    if (filterClasses.isNotEmpty() && generator.testClassName !in filterClasses) {
      if (verbose) {
        echo("Skipping ${generator.testClassName}")
      }
      return
    }

    val config =
      TestGenerator.Config(
        pkgOutputDir,
        echo = { msg, newline -> echo(msg.split("\n").joinToString { "  $it" }, newline) },
        verbose = { msg, newline -> if (verbose) echo(msg.split("\n").joinToString { "  $it" }, newline) }
      )

    generator.generate(config)
  }

}
