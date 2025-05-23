package io.github.solidswift

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.util.DefaultPrettyPrinter
import com.fasterxml.jackson.core.util.Separators
import com.fasterxml.jackson.core.util.Separators.*
import com.fasterxml.jackson.databind.JsonSerializer
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.SerializationFeature
import com.fasterxml.jackson.databind.SerializerProvider
import com.fasterxml.jackson.databind.module.SimpleModule
import java.math.BigDecimal
import java.math.MathContext
import java.math.RoundingMode
import java.nio.file.Path
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.*


abstract class TestGenerator {

  data class Config(
    val outputDir: Path,
    val echo: (message: String, trailingNewline: Boolean) -> Unit,
    val verbose: (message: String, trailingNewline: Boolean) -> Unit
  )

  abstract val testPkgName: String
  open val testClassName: String get() = this::class.simpleName!!.removeSuffix("TestGenerator")

  private var currentConfig: Config? = null
  private val config: Config
    get() = currentConfig ?: error("Context not initialized")

  open fun generate(config: Config) {
    currentConfig = config
    echo("Generating $outputName tests...")
    generate()
  }

  abstract fun generate()

  open val outputName: String
    get() = this::class.simpleName!!.removeSuffix("TestGenerator")

  fun output(tests: Any) {
    val outputFile = config.outputDir.resolve("${outputName}TestData.json")
    objectWriter.writeValue(outputFile.toFile(), tests)
    echo("Output: $outputFile")
  }

  fun echo(message: String, trailingNewline: Boolean = true) {
    config.echo(message, trailingNewline)
  }

  fun verbose(message: String, trailingNewline: Boolean = true) {
    config.verbose(message, trailingNewline)
  }

  class Serializers : SimpleModule() {
    override fun setupModule(context: SetupContext) {
      addSerializer(Double::class.javaObjectType, DoubleSerializer())
      addSerializer(Double::class.javaPrimitiveType, DoubleSerializer())
      super.setupModule(context)
    }

    class DoubleSerializer : JsonSerializer<Double>() {
      private val sciFormat = DecimalFormat("#0.################E0").apply {
        decimalFormatSymbols = DecimalFormatSymbols(Locale.ROOT).apply { exponentSeparator = "e" }
      }
      private val plainFormat = DecimalFormat("#0.0#")
      override fun serialize(value: Double, gen: JsonGenerator, serializers: SerializerProvider) {
        val bd = BigDecimal(value, MathContext(17, RoundingMode.HALF_EVEN)).stripTrailingZeros()
        val str = if (bd.precision() - bd.scale() > 16 && bd.scale() < 1)
          sciFormat.format(value)
        else
          plainFormat.format(bd)
        gen.writeRawValue(
          if (str.contains("e-"))
            str
          else
            str.replace("e", "e+")
        )
      }
    }
  }

  private val objectMapper =
    ObjectMapper()
      .findAndRegisterModules()
      .registerModule(Serializers())
      .configure(SerializationFeature.INDENT_OUTPUT, true)
      .setDefaultPrettyPrinter(
        DefaultPrettyPrinter()
          .withSeparators(
            Separators()
              .withObjectFieldValueSpacing(Spacing.AFTER)
              .withObjectEntrySpacing(Spacing.NONE)
              .withObjectEmptySeparator("")
              .withArrayValueSpacing(Spacing.NONE)
              .withArrayEmptySeparator("")
          )
          .withObjectIndenter(
            object : DefaultPrettyPrinter.Indenter {
              override fun isInline(): Boolean = false
              override fun writeIndentation(g: JsonGenerator, level: Int) = g.writeRaw("\n" + "  ".repeat(level))
            }
          )
          .withArrayIndenter(
            object : DefaultPrettyPrinter.Indenter {
              override fun isInline(): Boolean = false
              override fun writeIndentation(g: JsonGenerator, level: Int) = g.writeRaw("\n" + "  ".repeat(level))
            }
          )
      )

  private val objectWriter =
    objectMapper.writer()
      .with(JsonGenerator.Feature.WRITE_BIGDECIMAL_AS_PLAIN)

}
