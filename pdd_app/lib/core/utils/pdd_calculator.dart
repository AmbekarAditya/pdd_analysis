class PDDCalculator {
  /// Parses a PDD string like "0:45", "1:20", "45m", or "2h 5m" into a [Duration].
  static Duration parsePDD(String pdd) {
    pdd = pdd.toLowerCase().trim();
    if (pdd.isEmpty || pdd == '0:00' || pdd == '00:00') return Duration.zero;

    try {
      // Handle "H:MM" or "HH:MM" format
      if (pdd.contains(':')) {
        final parts = pdd.split(':');
        if (parts.length == 2) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          return Duration(hours: hours, minutes: minutes);
        }
      }

      // Handle "Xm" or "Xh Ym" format
      int hours = 0;
      int minutes = 0;

      if (pdd.contains('h')) {
        final hPart = pdd.split('h')[0].trim();
        hours = int.tryParse(hPart) ?? 0;
        pdd = pdd.split('h')[1].trim();
      }

      if (pdd.contains('m')) {
        final mPart = pdd.split('m')[0].trim();
        minutes = int.tryParse(mPart) ?? 0;
      } else if (pdd.isNotEmpty && !pdd.contains(':')) {
        // Assume raw number is minutes if no units
        minutes = int.tryParse(pdd) ?? 0;
      }

      return Duration(hours: hours, minutes: minutes);
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Formats a [Duration] into "H:MM" format.
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  /// Calculates the difference in minutes between two timestamps in HH:MM format.
  /// Handles midnight crossing by adding 1440 minutes if the result is negative.
  static int calculateMinutesBetweenTimes(String? laterStr, String? earlierStr) {
    if (laterStr == null || earlierStr == null || !laterStr.contains(':') || !earlierStr.contains(':')) {
      return 0;
    }

    final laterParts = laterStr.split(':');
    final earlierParts = earlierStr.split(':');
    
    if (laterParts.length != 2 || earlierParts.length != 2) return 0;

    final laterH = int.tryParse(laterParts[0]) ?? 0;
    final laterM = int.tryParse(laterParts[1]) ?? 0;
    final earlierH = int.tryParse(earlierParts[0]) ?? 0;
    final earlierM = int.tryParse(earlierParts[1]) ?? 0;

    final laterTotal = (laterH * 60) + laterM;
    final earlierTotal = (earlierH * 60) + earlierM;

    return calculateMinutesDifference(laterTotal, earlierTotal);
  }

  /// Calculates the difference between two minute values, handling midnight crossing.
  static int calculateMinutesDifference(int later, int earlier) {
    int diff = later - earlier;
    if (diff < 0) diff += 1440;
    return diff;
  }

  /// Calculates the average [Duration] from a list of strings.
  static Duration calculateAverage(List<String> pddList) {
    if (pddList.isEmpty) return Duration.zero;

    final totalSeconds = pddList
        .map((s) => parsePDD(s).inSeconds)
        .fold(0, (sum, seconds) => sum + seconds);

    return Duration(seconds: totalSeconds ~/ pddList.length);
  }
}
