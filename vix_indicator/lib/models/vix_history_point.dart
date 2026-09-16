class VixHistoryPoint {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;

  VixHistoryPoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory VixHistoryPoint.fromCsvRow(String row) {
    final fields = row.split(',');
    if (fields.length < 5) {
      throw FormatException('Malformed VIX history row: $row');
    }
 
    final dateParts = fields[0].split('/');
    final month = int.parse(dateParts[0]);
    final day = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);
 
    return VixHistoryPoint(
      date: DateTime(year, month, day),
      open: double.parse(fields[1]),
      high: double.parse(fields[2]),
      low: double.parse(fields[3]),
      close: double.parse(fields[4]),
    );
  }
}