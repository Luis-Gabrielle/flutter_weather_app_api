import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'iWeather',
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = "San Fernando"; // Default location
  String apiKey = "23ec576e0cb233b4859f980695554e0a";
  Map<String, dynamic>? weatherData;
  IconData weatherStatus = CupertinoIcons.cloud;

  Future<void> fetchWeather() async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric"); // Celsius

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          updateWeatherIcon(weatherData!['weather'][0]['description']);
        });
      } else {
        throw Exception("Failed to load weather data");
      }
    } catch (e) {
      print("Error: $e");
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
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: const Text("iWeather", style: TextStyle(color: CupertinoColors.white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.settings, color: CupertinoColors.white, size: 24),
          onPressed: () {}, // Add settings logic
        ),
      ),
      child: Center(
        child: weatherData == null
            ? const CupertinoActivityIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("My Location", style: TextStyle(fontSize: 22, color: CupertinoColors.white)),
            Text(city, style: const TextStyle(fontSize: 18, color: CupertinoColors.systemGrey)),
            const SizedBox(height: 10),
            Text(
              "${weatherData!['main']['temp'].round()}°C",
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: CupertinoColors.white),
            ),
            Icon(weatherStatus, size: 80, color: CupertinoColors.systemRed),
            const SizedBox(height: 10),
            Text(
              weatherData!['weather'][0]['description'],
              style: const TextStyle(fontSize: 20, color: CupertinoColors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "H: ${weatherData!['main']['humidity']}%  W: ${weatherData!['wind']['speed']} kph",
              style: const TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
            ),
            const SizedBox(height: 20),
            // CupertinoButton.filled(
            //   onPressed: fetchWeather,
            //   child: const Text("Refresh"),
            // ),
          ],
        ),
      ),
    );
  }
}
