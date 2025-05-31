import 'package:flutter/material.dart';
import 'package:weather_app/auth/api_service.dart';
import 'package:weather_app/auth/profile_page.dart';
import 'package:weather_app/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  List<DailyForecast>? _forecastData;
  bool _isLoading = false;
  bool _isDarkMode = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDefaultWeather();
  }

  void _loadDefaultWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _controller.text = 'Dhaka';
      final data = await _weatherService.fetchWeather('Dhaka');
      final forecast = await _weatherService.fetchForecast('Dhaka');

      if (data == null || forecast == null) {
        throw Exception('Failed to fetch default weather data');
      }

      setState(() {
        _weatherData = data;
        _forecastData = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load Bangladesh weather';
      });
    }
  }

  void _getWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final city = _controller.text.trim();
    if (city.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    try {
      final data = await _weatherService.fetchWeather(city);
      final forecast = await _weatherService.fetchForecast(city);

      if (data == null || forecast == null) {
        throw Exception('Failed to fetch weather data');
      }

      setState(() {
        _weatherData = data;
        _forecastData = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load weather data. Please try again.';
        if (e.toString().contains('API key')) {
          _errorMessage = 'Weather API service unavailable';
        }
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _toggleDarkMode() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[800],
            dialogBackgroundColor: Colors.grey[800],
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.grey[50],
            cardColor: Colors.white,
            primaryColor: Colors.blue[700],
          );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: Center(
            child: Text(
              'Global Weather',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true, // This centers the title
          backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.blue[700],
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: Colors.white),
              color: _isDarkMode ? Colors.grey[700] : Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person,
                        color: _isDarkMode ? Colors.white : Colors.black),
                    title: Text('Profile',
                        style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black)),
                  ),
                ),
                PopupMenuItem(
                  value: 'dark_mode',
                  child: ListTile(
                    leading: Icon(Icons.brightness_6,
                        color: _isDarkMode ? Colors.white : Colors.black),
                    title: Text('Dark Mode',
                        style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black)),
                    trailing: Switch(
                      value: _isDarkMode,
                      onChanged: (value) => _toggleDarkMode(),
                      activeColor: Colors.blue,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout,
                        color: _isDarkMode ? Colors.white : Colors.black),
                    title: Text('Logout',
                        style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black)),
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(),
                      settings: RouteSettings(
                        arguments: _isDarkMode,
                      ),
                    ),
                  );
                } else if (value == 'logout') {
                  _logout();
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter city name',
                    hintText: 'e.g. Dhaka, Chittagong',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search,
                          color:
                              _isDarkMode ? Colors.white70 : Colors.grey[700]),
                      onPressed: _getWeather,
                    ),
                  ),
                  style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black),
                  onSubmitted: (_) => _getWeather(),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Current Weather Display
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_weatherData != null)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isDarkMode
                              ? [Colors.blueGrey[800]!, Colors.grey[900]!]
                              : [Colors.blue[100]!, Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _weatherData!.cityName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: _isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Image.network(
                            _weatherData!.iconUrl,
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              Text(
                                '${_weatherData!.temperature}°C',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              if (_weatherData!.maxTemp != null &&
                                  _weatherData!.minTemp != null)
                                Text(
                                  'H: ${_weatherData!.maxTemp}°  L: ${_weatherData!.minTemp}°',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[700],
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            _weatherData!.condition,
                            style: TextStyle(
                              fontSize: 20,
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildWeatherDetail(
                                icon: Icons.water_drop,
                                value: '${_weatherData!.humidity}%',
                                label: 'Humidity',
                              ),
                              if (_weatherData!.windKph != null)
                                _buildWeatherDetail(
                                  icon: Icons.air,
                                  value:
                                      '${_weatherData!.windKph!.toStringAsFixed(1)} km/h',
                                  label: 'Wind',
                                ),
                              _buildWeatherDetail(
                                icon: Icons.thermostat,
                                value:
                                    '${_weatherData!.feelsLikeTemp?.toStringAsFixed(1) ?? 'N/A'}°C',
                                label: 'Feels Like',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 10-Day Forecast Section
                    Text(
                      '03-Day Forecast',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _forecastData == null || _forecastData!.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Column(
                              children: _forecastData!
                                  .map((day) => _buildForecastDay(day))
                                  .toList(),
                            ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const SizedBox(height: 100),
                    Icon(
                      Icons.cloud,
                      size: 80,
                      color: _isDarkMode ? Colors.white54 : Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Search for a city to see weather',
                      style: TextStyle(
                        fontSize: 18,
                        color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon,
            color: _isDarkMode ? Colors.white70 : Colors.blue[700], size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: _isDarkMode ? Colors.white60 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastDay(DailyForecast day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  day.date,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Image.network(
                  day.iconUrl,
                  width: 40,
                  height: 40,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  day.condition,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${day.maxTemp}°',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${day.minTemp}°',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildForecastDetail('Precip', '${day.precipMm} mm'),
              const SizedBox(width: 16),
              _buildForecastDetail('Humidity', '${day.avgHumidity}%'),
              const SizedBox(width: 16),
              _buildForecastDetail('UV', day.uv.toStringAsFixed(1)),
            ],
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }

  Widget _buildForecastDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _isDarkMode ? Colors.white60 : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
