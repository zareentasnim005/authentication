import 'package:flutter/material.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = false;

  void _getWeather() async {
    setState(() => _isLoading = true);
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
      final data = await _weatherService.fetchWeather(city);
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Weather')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter city name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _getWeather,
                ),
              ),
              onSubmitted: (_) => _getWeather(),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_weatherData != null)
              Column(
                children: [
                  Text(
                    _weatherData!.cityName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Image.network(_weatherData!.iconUrl),
                  Text(
                    '${_weatherData!.temperature}°C',
                    style: const TextStyle(fontSize: 32),
                  ),
                  Text(
                    _weatherData!.condition,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              )
            else
              const Text('No weather data'),
          ],
        ),
      ),
    );
  }
}
