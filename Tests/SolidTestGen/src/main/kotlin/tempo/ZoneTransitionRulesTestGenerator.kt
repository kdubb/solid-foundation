package io.github.solidswift.tempo

import java.time.LocalDateTime
import java.time.ZoneId
import java.time.zone.ZoneRules


class ZoneTransitionRuleTestGenerator : TempoTestGenerator() {

  private val year = 2501

  override fun generateTestCasesForZone(zone: ZoneId, rules: ZoneRules): List<Map<String, Any?>>? {
    if (rules.transitionRules.isEmpty()) {
      verbose("-- No projection rules, skipping")
      return null
    }
    verbose("-- ${rules.transitionRules.size} projection rules")

    val startOfYear = LocalDateTime.of(year, 1, 1, 0, 0, 0)
    val endOfYear = LocalDateTime.of(year, 12, 31, 0, 0, 0)
    val firstTransition = rules.nextTransition(startOfYear.atZone(zone).toInstant())
    val secondTransition = rules.nextTransition(firstTransition.instant.plusSeconds(60 * 60 * 12))
    val locals = listOf(
      startOfYear,
      firstTransition.dateTimeBefore.minusNanos(1),
      firstTransition.dateTimeBefore,
      firstTransition.dateTimeBefore.plus(firstTransition.duration),
      secondTransition.dateTimeBefore.minusNanos(1),
      secondTransition.dateTimeBefore,
      secondTransition.dateTimeBefore.plus(secondTransition.duration),
      endOfYear,
    )
    return locals.map { local ->
      val instant = local.atZone(zone).toInstant()
      mapOf(
        "local" to local,
        "instant" to instant.toBigEpoch(),
        "localOffset" to rules.getOffset(local).totalSeconds,
        "instantOffset" to rules.getOffset(instant).totalSeconds,
        "localValidOffsets" to rules.getValidOffsets(local).map { it.totalSeconds },
        "localApplicableTransition" to rules.getTransition(local)?.toMap(),
        "instantNextTransition" to rules.nextTransition(instant)?.toMap(),
        "instantPriorTransition" to rules.previousTransition(instant)?.toMap(),
        "instantDstDuration" to rules.getDaylightSavings(instant).toNanos(),
        "designation" to designation(instant, zone)
      )
    }
  }

}
