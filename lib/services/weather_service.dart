import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/model_weather.dart';


class WeatherService {
  static const url = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey = '8ab20daaa787ac228a044bae62b39fae';

  Future<Weather> getWeather(double lat, double lng) async {
    final response = await http.get(Uri.parse('$url?lat=$lat&lon=$lng&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}