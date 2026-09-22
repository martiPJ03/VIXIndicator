class IntradayPoint {
  final DateTime timestamp;
  final double value;

  IntradayPoint({
    required this.timestamp,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'value': value,
      };

  factory IntradayPoint.fromJson(Map<String, dynamic> json) {
    return IntradayPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}