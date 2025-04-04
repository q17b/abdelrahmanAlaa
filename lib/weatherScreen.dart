import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'compare_weather_screen.dart';
import 'weatherInfo.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  static const String apiKey = '495d8644fcc262f1c978e66a85b74c9d';
  static const String apiUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  TextEditingController _cityController = TextEditingController();
  String city = 'Cairo';
  Map<String, dynamic>? weatherData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLastCity();
  }

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('$apiUrl?q=$city&appid=$apiKey&units=metric&lang=ar'));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
        _saveLastCity();
      } else {
        setState(() {
          weatherData = null;
        });
      }
    } catch (e) {
      setState(() {
        weatherData = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateCity(String newCity) {
    setState(() {
      city = newCity;
    });
    fetchWeather();
  }

  Future<void> _saveLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lastCity', city);
  }

  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      city = prefs.getString('lastCity') ?? 'Cairo';
    });
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق للطقس'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmA-xHB-nhwz4YUho3NTAzR_-dMj-eNP6FrQ8YilIPuMWRPPib87aE72sN&s=10'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'أدخل اسم المدينة',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      updateCity(_cityController.text);
                      _cityController.clear();
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : weatherData != null
                    ? WeatherInfo(weatherData: weatherData!)
                    : const Text('لم يتم العثور على بيانات الطقس',
                        style: TextStyle(fontSize: 18, color: Colors.white)),

            const Spacer(), // يجعل الزر في الأسفل دائمًا

            // **✅ زر مقارنة مدينتين بأسفل الشاشة وعريض بالكامل**
            SizedBox(
              width: double.infinity, // عرض الزر يملأ الشاشة بالكامل
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CompareWeatherScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.transparent, // لون الخلفية لبني (أزرق فاتح)
                  padding: const EdgeInsets.symmetric(
                      vertical: 15), // زيادة الطول ليكون أكثر وضوحًا
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0), // بدون زوايا مستديرة ليبدو كزر سفلي ثابت
                  ),
                ),
                child: const Text(
                  'مقارنة مدينتين',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
