import 'package:provider/provider.dart';
import 'package:weather_app/auth/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  WeatherData? _weatherData;
  List<DailyForecast>? _forecastData;
  List<HourlyForecast>? _hourlyForecast;
  bool _isLoading = false;
  String? _errorMessage;
  OverlayEntry? _menuOverlay;

  @override
  void initState() {
    super.initState();
    _loadDefaultWeather();
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeMenuOverlay();
    super.dispose();
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
      final hourly = await _weatherService.fetchHourlyForecast('Dhaka');

      if (data == null || forecast == null || hourly == null) {
        throw Exception('Failed to fetch default weather data');
      }

      setState(() {
        _weatherData = data;
        _forecastData = forecast;
        _hourlyForecast = hourly;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load weather data';
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
      final hourly = await _weatherService.fetchHourlyForecast(city);

      if (data == null || forecast == null || hourly == null) {
        throw Exception('Failed to fetch weather data');
      }

      setState(() {
        _weatherData = data;
        _forecastData = forecast;
        _hourlyForecast = hourly;
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

  void _navigateToProfile() {
    _removeMenuOverlay();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  String _getWeatherAnimation() {
    if (_weatherData == null) return 'assets/animations/sunny.json';
    final condition = _weatherData!.condition.toLowerCase();

    if (condition.contains('rain')) return 'assets/animations/rainy.json';
    if (condition.contains('sun') || condition.contains('clear')) {
      return 'assets/animations/sunny.json';
    }
    if (condition.contains('cloud')) return 'assets/animations/cloudy.json';
    if (condition.contains('snow')) return 'assets/animations/snow.json';
    if (condition.contains('thunder')) return 'assets/animations/thunder.json';
    if (condition.contains('fog') || condition.contains('mist')) {
      return 'assets/animations/fog.json';
    }
    return 'assets/animations/sunny.json';
  }

  LinearGradient _getBackgroundGradient(bool isDarkMode) {
    if (_weatherData == null) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDarkMode
            ? [Colors.blueGrey[900]!, Colors.grey[900]!]
            : [Colors.lightBlue[400]!, Colors.blue[200]!],
      );
    }

    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 18;
    final condition = _weatherData!.condition.toLowerCase();

    if (isNight) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDarkMode
            ? [Colors.blueGrey[900]!, Colors.grey[900]!]
            : [Colors.indigo[800]!, Colors.purple[800]!],
      );
    } else if (condition.contains('rain')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDarkMode
            ? [Colors.blueGrey[800]!, Colors.grey[700]!]
            : [Colors.blueGrey[600]!, Colors.grey[500]!],
      );
    } else if (condition.contains('sun') || condition.contains('clear')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDarkMode
            ? [Colors.blue[900]!, Colors.blue[700]!]
            : [Colors.blue[400]!, Colors.lightBlue[200]!],
      );
    } else if (condition.contains('cloud')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDarkMode
            ? [Colors.blueGrey[700]!, Colors.grey[600]!]
            : [Colors.blueGrey[300]!, Colors.grey[200]!],
      );
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDarkMode
          ? [Colors.blueGrey[800]!, Colors.grey[700]!]
          : [Colors.lightBlue[400]!, Colors.blue[200]!],
    );
  }

  void _showMenuOverlay() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _menuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + kToolbarHeight,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuOption(
                  icon: Icons.person,
                  text: 'Profile',
                  onTap: _navigateToProfile,
                  isDarkMode: isDarkMode,
                ),
                _buildMenuOption(
                  icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  text: isDarkMode ? 'Light Mode' : 'Dark Mode',
                  onTap: () {
                    themeProvider.toggleTheme();
                    _removeMenuOverlay();
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildMenuOption(
                  icon: Icons.logout,
                  text: 'Logout',
                  onTap: _logout,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_menuOverlay!);
  }

  void _removeMenuOverlay() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black87),
      title: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          const Expanded(
            child: Center(
              child: Text(
                'Global Weather',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              if (_menuOverlay == null) {
                _showMenuOverlay();
              } else {
                _removeMenuOverlay();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDarkMode
              ? Colors.grey[800]!.withOpacity(0.5)
              : Colors.white.withOpacity(0.8),
          hintText: 'Search city...',
          suffixIcon: IconButton(
            icon: Icon(Icons.search,
                color: isDarkMode ? Colors.white70 : Colors.blue),
            onPressed: _getWeather,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          hintStyle:
              TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        onSubmitted: (_) => _getWeather(),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: Colors.red[200], fontSize: 16),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Lottie.asset(
            'assets/animations/sunny.json',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.wb_sunny,
                size: 100,
                color: isDarkMode ? Colors.white : Colors.amber,
              );
            },
          ),
          Text(
            'Search for a city to see weather',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            _weatherData!.cityName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_weatherData!.region}, ${_weatherData!.country}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                _getWeatherAnimation(),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.wb_sunny,
                    size: 60,
                    color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : Colors.amber,
                  );
                },
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Text(
                    '${_weatherData!.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _weatherData!.condition,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'H: ${_weatherData!.maxTemp?.toStringAsFixed(1)}°',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 16),
              Text(
                'L: ${_weatherData!.minTemp?.toStringAsFixed(1)}°',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Feels like ${_weatherData!.feelsLikeTemp?.toStringAsFixed(1)}°C',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(bool isDarkMode) {
    if (_hourlyForecast == null || _hourlyForecast!.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Hourly Forecast',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _hourlyForecast!.length,
              itemBuilder: (context, index) {
                final hour = _hourlyForecast![index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[800]!.withOpacity(0.5)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hour.time,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Image.network(
                        hour.iconUrl,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.wb_sunny,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.amber,
                          );
                        },
                      ),
                      Text(
                        '${hour.temp.toStringAsFixed(0)}°',
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (hour.chanceOfRain > 0)
                        Text(
                          '${hour.chanceOfRain}%',
                          style: TextStyle(
                            color: Colors.lightBlue[200],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(bool isDarkMode) {
    if (_forecastData == null || _forecastData!.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '3-Day Forecast',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: _forecastData!
                  .take(3)
                  .map((day) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                day.date,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Image.network(
                              day.iconUrl,
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.wb_sunny,
                                  size: 30,
                                  color: isDarkMode ? Colors.white : Colors.amber,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${day.maxTemp.toStringAsFixed(0)}°',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${day.minTemp.toStringAsFixed(0)}°',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6)),
                            ),
                            const SizedBox(width: 16),
                            if (day.chanceOfRain > 0)
                              Row(
                                children: [
                                  Icon(Icons.water_drop,
                                      size: 16, color: Colors.lightBlue[200]),
                                  Text(
                                    '${day.chanceOfRain}%',
                                    style:
                                        TextStyle(color: Colors.lightBlue[200]),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails(bool isDarkMode) {
    if (_weatherData == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDetailCard(
                icon: Icons.water_drop,
                title: 'Humidity',
                value: '${_weatherData!.humidity}%',
                isDarkMode: isDarkMode,
              ),
              _buildDetailCard(
                icon: Icons.air,
                title: 'Wind',
                value:
                    '${_weatherData!.windKph?.toStringAsFixed(1) ?? 'N/A'} km/h',
                isDarkMode: isDarkMode,
              ),
              _buildDetailCard(
                icon: Icons.speed,
                title: 'Pressure',
                value: '${_weatherData!.pressureMb ?? 'N/A'} hPa',
                isDarkMode: isDarkMode,
              ),
              _buildDetailCard(
                icon: Icons.visibility,
                title: 'Visibility',
                value: '${_weatherData!.visKm ?? 'N/A'} km',
                isDarkMode: isDarkMode,
              ),
              _buildDetailCard(
                icon: Icons.umbrella,
                title: 'Precipitation',
                value:
                    '${_weatherData!.precipMm?.toStringAsFixed(1) ?? '0'} mm',
                isDarkMode: isDarkMode,
              ),
              _buildDetailCard(
                icon: Icons.light_mode,
                title: 'UV Index',
                value: '${_weatherData!.uv?.toStringAsFixed(1) ?? 'N/A'}',
                isDarkMode: isDarkMode,
              ),
              if (_weatherData!.airQuality != null)
                _buildDetailCard(
                  icon: Icons.air,
                  title: 'Air Quality',
                  value: _getAirQualityText(_weatherData!.airQuality!),
                  isDarkMode: isDarkMode,
                ),
              _buildDetailCard(
                icon: Icons.wb_sunny,
                title: 'Sunrise',
                value: _weatherData!.sunrise,
                isDarkMode: isDarkMode,
              ),
              _buildDetailCard(
                icon: Icons.wb_sunny,
                title: 'Sunset',
                value: _weatherData!.sunset,
                isDarkMode: isDarkMode,
              ),
              _buildDetailCard(
                icon: Icons.update,
                title: 'Last Updated',
                value: _weatherData!.lastUpdated != null
                    ? DateFormat('h:mm a')
                        .format(DateTime.parse(_weatherData!.lastUpdated!))
                    : 'N/A',
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isDarkMode,
  }) {
    return Card(
      color: isDarkMode
          ? Colors.grey[800]!.withOpacity(0.5)
          : Colors.white.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAirQualityText(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(isDarkMode),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _getWeather(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildSearchBar(isDarkMode),
                        if (_errorMessage != null) _buildErrorMessage(),
                        if (_isLoading) _buildLoadingIndicator(),
                        if (_weatherData != null) ...[
                          _buildCurrentWeather(),
                          _buildHourlyForecast(isDarkMode),
                          _buildDailyForecast(isDarkMode),
                          _buildWeatherDetails(isDarkMode),
                        ] else if (!_isLoading)
                          _buildEmptyState(isDarkMode),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}