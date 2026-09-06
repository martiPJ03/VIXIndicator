import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vix_data.dart';

class VixService {
    static const String cboeApiURL = 'https://cdn.cboe.com/api/global/delayed_quotes/quotes/_VIX.json';

    Future<VixData> fetchVixData() async {
        final response = await http.get(Uri.parse(cboeApiURL));

        if (response.statusCode == 200) {
            final jsonData = json.decode(response.body) as Map<String, dynamic>;
            return VixData.fromJson(jsonData);
        } else {
            throw Exception('Failed to load VIX data (${response.statusCode})');
        }
    }
    
}