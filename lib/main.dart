import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'settings.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'iWeather',
      theme: CupertinoThemeData(
        brightness: settings.lightMode ? Brightness.light : Brightness.dark,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = "23ec576e0cb233b4859f980695554e0a";
  Map<String, dynamic>? weatherData;
  IconData weatherStatus = CupertinoIcons.cloud;
  String? errorMessage;
  bool showErrorDialog = false;
  bool isLoading = false;

  Future<void> fetchWeather() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      showErrorDialog = false;
    });

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=${settings.location}&appid=$apiKey&units=${settings.metricSystem ? 'metric' : 'imperial'}");

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw "No internet connection";
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          updateWeatherIcon(weatherData!['weather'][0]['description']);
        });
      } else if (response.statusCode == 404) {
        throw "City not found";
      } else {
        throw "Error fetching weather data";
      }
    } on http.ClientException catch (_) {
      setState(() {
        errorMessage = "Network error occurred";
        showErrorDialog = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        showErrorDialog = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorDialog() {
    if (showErrorDialog && errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Message"),
            content: Text(errorMessage!),
            actions: [
              CupertinoDialogAction(
                child: const Text("Please Try Again",
                    style: TextStyle(color: CupertinoColors.systemGreen)),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() => showErrorDialog = false);
                  fetchWeather();
                },
              ),
              // Show Retry ONLY for No internet connection
              if (errorMessage == "No internet connection")
                CupertinoDialogAction(
                  child: const Text("Please Try Again",
                      style: TextStyle(color: CupertinoColors.systemGreen)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => showErrorDialog = false);
                    fetchWeather();
                  },
                ),
            ],
          ),
        );
      });
    }
  }

  void updateWeatherIcon(String weather) {
    if (weather.contains("clear")) {
      weatherStatus = CupertinoIcons.sun_max;
    } else if (weather.contains("cloud")) {
      weatherStatus = CupertinoIcons.cloud;
    } else if (weather.contains("haze")) {
      weatherStatus = CupertinoIcons.sun_haze;
    } else if (weather.contains("rain")) {
      weatherStatus = CupertinoIcons.cloud_rain;
    } else {
      weatherStatus = CupertinoIcons.cloud;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsProvider>(context);
    settings.addListener(fetchWeather);
  }

  @override
  void dispose() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.removeListener(fetchWeather);
    super.dispose();
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final settings = Provider.of<SettingsProvider>(context);
    final textColor = settings.lightMode ? CupertinoColors.black : CupertinoColors.white;
    final secondaryTextColor = settings.lightMode
        ? CupertinoColors.darkBackgroundGray
        : CupertinoColors.systemGrey;

    if (weatherData == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("My Location",
            style: TextStyle(fontSize: 22, color: textColor)),
        Text(settings.location,
            style: TextStyle(fontSize: 18, color: secondaryTextColor)),
        const SizedBox(height: 10),
        Text(
          "${weatherData!['main']['temp'].round()}°${settings.metricSystem ? 'C' : 'F'}",
          style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: textColor
          ),
        ),
        Icon(weatherStatus, size: 80, color: settings.iconColor),
        const SizedBox(height: 10),
        Text(
          weatherData!['weather'][0]['description'],
          style: TextStyle(fontSize: 20, color: textColor),
        ),
        const SizedBox(height: 10),
        Text(
          "H: ${weatherData!['main']['humidity']}%  "
              "W: ${weatherData!['wind']['speed'].round()} "
              "${settings.metricSystem ? 'kph' : 'mph'}",
          style: TextStyle(fontSize: 16, color: secondaryTextColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _showErrorDialog();
    final settings = Provider.of<SettingsProvider>(context);
    final textColor = settings.lightMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: settings.lightMode
            ? CupertinoColors.extraLightBackgroundGray
            : CupertinoColors.darkBackgroundGray,
        middle: Text("iWeather", style: TextStyle(color: textColor)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.gear, color: textColor, size: 24),
          onPressed: _navigateToSettings,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: isLoading
              ? const CupertinoActivityIndicator()
              : weatherData == null && errorMessage == null
              ? const CupertinoActivityIndicator()
              : _buildWeatherContent(),
        ),
      ),
    );
  }
}