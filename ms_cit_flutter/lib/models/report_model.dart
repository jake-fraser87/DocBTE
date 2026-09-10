class CorporationVolume {
  final String corporationCode;
  final int count;
  final int maxScaleCount; // used to size the bar relative to the top entry

  const CorporationVolume({
    required this.corporationCode,
    required this.count,
    required this.maxScaleCount,
  });

  double get ratio => maxScaleCount == 0 ? 0 : count / maxScaleCount;
}

class TurnaroundStats {
  final double avgDays;
  final int slaPercent;
  final int closedToday;

  const TurnaroundStats({
    required this.avgDays,
    required this.slaPercent,
    required this.closedToday,
  });
}
