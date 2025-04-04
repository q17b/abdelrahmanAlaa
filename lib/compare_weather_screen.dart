import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompareWeatherScreen extends StatefulWidget {
  @override
  _CompareWeatherScreenState createState() => _CompareWeatherScreenState();
}

class _CompareWeatherScreenState extends State<CompareWeatherScreen> {
  static const String apiKey = '495d8644fcc262f1c978e66a85b74c9d';
  static const String apiUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  TextEditingController city1Controller = TextEditingController();
  TextEditingController city2Controller = TextEditingController();

  Map<String, dynamic>? weatherData1;
  Map<String, dynamic>? weatherData2;
  bool isLoading = false;

  Future<void> fetchWeather(String city, bool isFirstCity) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('$apiUrl?q=$city&appid=$apiKey&units=metric&lang=ar'));

      if (response.statusCode == 200) {
        setState(() {
          if (isFirstCity) {
            weatherData1 = json.decode(response.body);
          } else {
            weatherData2 = json.decode(response.body);
          }
        });
      }
    } catch (e) {
      setState(() {
        if (isFirstCity) {
          weatherData1 = null;
        } else {
          weatherData2 = null;
        }
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('مقارنة الطقس بين مدينتين'),
          backgroundColor: Colors.blueAccent),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmA-xHB-nhwz4YUho3NTAzR_-dMj-eNP6FrQ8YilIPuMWRPPib87aE72sN&s=10'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: city1Controller,
                      decoration: InputDecoration(
                        labelText: 'المدينة الأولى',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white70),
                    onPressed: () => fetchWeather(city1Controller.text, true),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: city2Controller,
                      decoration: InputDecoration(
                        labelText: 'المدينة الثانية',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white70),
                    onPressed: () => fetchWeather(city2Controller.text, false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : weatherData1 != null && weatherData2 != null
                      ? WeatherComparison(
                          weatherData1: weatherData1!,
                          weatherData2: weatherData2!)
                      : const Text('أدخل المدينتين للبدء بالمقارنة',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherComparison extends StatelessWidget {
  final Map<String, dynamic> weatherData1;
  final Map<String, dynamic> weatherData2;

  const WeatherComparison(
      {super.key, required this.weatherData1, required this.weatherData2});

  @override
  Widget build(BuildContext context) {
    final temp1 = weatherData1['main']['temp'].toString();
    final temp2 = weatherData2['main']['temp'].toString();
    final cityName1 = weatherData1['name'];
    final cityName2 = weatherData2['name'];
    final description1 = weatherData1['weather'][0]['description'];
    final description2 = weatherData2['weather'][0]['description'];

    return Column(
      children: [
        Text('$cityName1 VS $cityName2',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text('$temp1°C',
                    style: const TextStyle(fontSize: 28, color: Colors.white)),
                Text(description1,
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
              ],
            ),
            Column(
              children: [
                Text('$temp2°C',
                    style: const TextStyle(fontSize: 28, color: Colors.white)),
                Text(description2,
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
