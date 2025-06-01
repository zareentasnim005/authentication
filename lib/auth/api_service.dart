import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'weather_model.dart';

class WeatherService {
  Future<WeatherData?> fetchWeather(String cityName) async {
    final url =
        Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$cityName&days=10');
    try {
      final response = await http.get(url);
      print('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final location = data['location'];
        final forecastDay = data['forecast']['forecastday'][0]['day'];

        return WeatherData(
          cityName: location['name'],
          region: location['region'],
          country: location['country'],
          temperature: current['temp_c'].toDouble(),
          condition: current['condition']['text'],
          iconUrl: 'https:${current['condition']['icon']}',
          humidity: current['humidity'],
          windKph: current['wind_kph']?.toDouble(),
          feelsLikeTemp: current['feelslike_c']?.toDouble(),
          maxTemp: forecastDay['maxtemp_c']?.toDouble(),
          minTemp: forecastDay['mintemp_c']?.toDouble(),
          uv: current['uv']?.toDouble(),
          pressureMb: current['pressure_mb']?.toInt(),
          visKm: current['vis_km']?.toInt(),
          precipMm: current['precip_mm']?.toDouble(),
          gustKph: current['gust_kph']?.toDouble(),
          isDay: current['is_day'] == 1,
          lastUpdated: current['last_updated'],
          sunrise: data['forecast']['forecastday'][0]['astro']['sunrise'],
          sunset: data['forecast']['forecastday'][0]['astro']['sunset'],
          airQuality: current['air_quality']?['us-epa-index']?.toInt(),
        );
      } else {
        print('API Error: ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchWeather: $e');
      rethrow;
    }
  }

  Future<List<DailyForecast>?> fetchForecast(String cityName) async {
    final url =
        Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$cityName&days=10');
    try {
      final response = await http.get(url);
      print('Forecast API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['forecast'] == null ||
            data['forecast']['forecastday'] == null) {
          print('No forecast data in response');
          return null;
        }

        final forecastDays = data['forecast']['forecastday'] as List;
        print('Received ${forecastDays.length} forecast days');

        final forecasts = <DailyForecast>[];

        for (var day in forecastDays) {
          try {
            forecasts.add(DailyForecast(
              date: _formatDate(day['date']),
              condition: day['day']['condition']['text'],
              iconUrl: 'https:${day['day']['condition']['icon']}',
              maxTemp: day['day']['maxtemp_c']?.toDouble() ?? 0.0,
              minTemp: day['day']['mintemp_c']?.toDouble() ?? 0.0,
              precipMm: day['day']['totalprecip_mm']?.toDouble() ?? 0.0,
              avgHumidity: day['day']['avghumidity']?.toInt() ?? 0,
              uv: day['day']['uv']?.toDouble() ?? 0.0,
              chanceOfRain: day['day']['daily_chance_of_rain']?.toInt() ?? 0,
              sunrise: day['astro']['sunrise'],
              sunset: day['astro']['sunset'],
            ));
          } catch (e) {
            print('Error parsing forecast day: $e');
          }
        }

        return forecasts;
      } else {
        print('Forecast API Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in fetchForecast: $e');
      return null;
    }
  }

  Future<List<HourlyForecast>?> fetchHourlyForecast(String cityName) async {
    final url =
        Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$cityName&days=2');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hours = data['forecast']['forecastday'][0]['hour'] as List;

        return hours
            .map((hour) => HourlyForecast(
                  time: hour['time'].split(' ').last,
                  temp: hour['temp_c'].toDouble(),
                  condition: hour['condition']['text'],
                  iconUrl: 'https:${hour['condition']['icon']}',
                  chanceOfRain: hour['chance_of_rain'],
                  isDay: hour['is_day'] == 1,
                ))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching hourly forecast: $e');
      return null;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final weekday = date.weekday;
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${date.day}/${date.month} (${days[weekday - 1]})';
    } catch (e) {
      print('Error formatting date: $e');
      return dateStr;
    }
  }
}

class WeatherData {
  final String cityName;
  final String region;
  final String country;
  final double temperature;
  final String condition;
  final String iconUrl;
  final int humidity;
  final double? windKph;
  final double? feelsLikeTemp;
  final double? maxTemp;
  final double? minTemp;
  final double? uv;
  final int? pressureMb;
  final int? visKm;
  final double? precipMm;
  final double? gustKph;
  final bool isDay;
  final String lastUpdated;
  final String sunrise;
  final String sunset;
  final int? airQuality;

  WeatherData({
    required this.cityName,
    required this.region,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.humidity,
    this.windKph,
    this.feelsLikeTemp,
    this.maxTemp,
    this.minTemp,
    this.uv,
    this.pressureMb,
    this.visKm,
    this.precipMm,
    this.gustKph,
    required this.isDay,
    required this.lastUpdated,
    required this.sunrise,
    required this.sunset,
    this.airQuality,
  });
}

class DailyForecast {
  final String date;
  final String condition;
  final String iconUrl;
  final double maxTemp;
  final double minTemp;
  final double precipMm;
  final int avgHumidity;
  final double uv;
  final int chanceOfRain;
  final String sunrise;
  final String sunset;

  DailyForecast({
    required this.date,
    required this.condition,
    required this.iconUrl,
    required this.maxTemp,
    required this.minTemp,
    required this.precipMm,
    required this.avgHumidity,
    required this.uv,
    required this.chanceOfRain,
    required this.sunrise,
    required this.sunset,
  });
}

class HourlyForecast {
  final String time;
  final double temp;
  final String condition;
  final String iconUrl;
  final int chanceOfRain;
  final bool isDay;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.condition,
    required this.iconUrl,
    required this.chanceOfRain,
    required this.isDay,
  });
}
