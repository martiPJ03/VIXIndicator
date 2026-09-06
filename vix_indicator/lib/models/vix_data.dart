class VixData {
 	final double currentValue;
	final double valueChange;
	final double valueChangePercent;
	final DateTime lastTradeTime;

	VixData({
		required this.currentValue,
		required this.valueChange,
		required this.valueChangePercent,
		required this.lastTradeTime,
  	});

	factory VixData.fromJson(Map<String, dynamic> jsonFromCboe) {
    final data = jsonFromCboe['data'] as Map<String, dynamic>;
    return VixData(
		currentValue: (data['current_price'] as num).toDouble(),
		valueChange: (data['price_change'] as num).toDouble(),
		valueChangePercent: (data['price_change_percent'] as num).toDouble(),
		lastTradeTime: DateTime.parse(data['last_trade_time'] as String),
    );
  }
}