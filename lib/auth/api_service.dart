import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class WeatherService {
  Future<WeatherData?> fetchWeather(String cityName) async {
    final url = Uri.parse('$baseUrl/current.json?key=$apiKey&q=$cityName');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        print('Error fetching weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching weather: $e');
    }
    return null;
  }
}

class WeatherData {
  final String cityName;
  final double temperature;
  final String condition;
  final String iconUrl;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['location']['name'],
      temperature: json['current']['temp_c'].toDouble(),
      condition: json['current']['condition']['text'],
      iconUrl: 'https:${json['current']['condition']['icon']}',
    );
  }
}
