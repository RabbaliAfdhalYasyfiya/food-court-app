class Weather {
  final String nameCity;
  final String mainCondition;
  final String descCondition;
  final double temp;
  final double tempHigh;
  final double tempLow;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int timezone;

  Weather({
    required this.nameCity,
    required this.mainCondition,
    required this.descCondition,
    required this.temp,
    required this.tempHigh,
    required this.tempLow,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.timezone,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      nameCity: json['name'].toString(),
      mainCondition: json['weather'][0]['main'].toString(),
      descCondition: json['weather'][0]['description'].toString(),
      temp: json['main']['temp'].toDouble(),
      tempHigh: json['main']['temp_max'].toDouble(),
      tempLow: json['main']['temp_min'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      humidity: json['main']['humidity'].toInt(),
      timezone: json['timezone'].toInt(),
    );
  }
}
