import 'package:flutter/material.dart';

class WeatherInfo extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherInfo({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final temp = weatherData['main']['temp'].toString();
    final description = weatherData['weather'][0]['description'];
    final cityName = weatherData['name'];
    final iconCode = weatherData['weather'][0]['icon'];

    return Column(
      children: [
        Text(cityName,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Image.network('https://openweathermap.org/img/wn/$iconCode@2x.png'),
        Text('$temp°C',
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(description,
            style: const TextStyle(fontSize: 20, color: Colors.white)),
      ],
    );
  }
}
