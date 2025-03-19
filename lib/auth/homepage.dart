import 'package:flutter/material.dart';
import 'package:weather_app/auth/signup.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  String city = "Pabna";
  String temperature = "Loading...";
  String weather = "Loading...";

  final Map<String, Map<String, String>> weatherData = {
    "New York": {"temperature": "25°C", "weather": "Sunny"},
    "London": {"temperature": "18°C", "weather": "Cloudy"},
    "Paris": {"temperature": "22°C", "weather": "Partly Cloudy"},
    "Tokyo": {"temperature": "28°C", "weather": "Clear Sky"},
    "Sydney": {"temperature": "24°C", "weather": "Sunny"},
    "Dhaka": {"temperature": "30°C", "weather": "Sunny"},
    "Pabna": {"temperature": "29°C", "weather": "Sunny"},
  };

  void updateWeather() {
    String enteredCity = _controller.text.trim();

    if (enteredCity.isEmpty) {
      showErrorDialog("Please enter a city name.");
      return;
    }

    setState(() {
      city = enteredCity;
      temperature = "Loading...";
      weather = "Loading...";
    });

    if (weatherData.containsKey(city)) {
      setState(() {
        temperature = weatherData[city]!["temperature"]!;
        weather = weatherData[city]!["weather"]!;
      });
    } else {
      showErrorDialog("City not found. Please enter a valid city.");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error", style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Text(
            "Weather App - $city",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Enter City Name",
                hintStyle: const TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.pinkAccent),
                  onPressed: updateWeather,
                ),
              ),
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              color: Colors.white.withOpacity(0.25),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                child: Column(
                  children: [
                    Icon(
                      weather.toLowerCase().contains("sun")
                          ? Icons.wb_sunny
                          : weather.toLowerCase().contains("cloud")
                              ? Icons.cloud
                              : Icons.wb_cloudy, // Default icon
                      color: Colors.yellowAccent,
                      size: 80,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      city,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      temperature,
                      style: const TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      weather,
                      style: const TextStyle(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Signup Screen Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Go to Signup",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
