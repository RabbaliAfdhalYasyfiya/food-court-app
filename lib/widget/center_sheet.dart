import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../services/models/model_weather.dart';
import 'button.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({
    super.key,
    required this.addressLocation,
    required this.weather,
    required this.getWeatherIcon,
  });

  final String? addressLocation;
  final Weather? weather;
  final String Function(String?, int) getWeatherIcon;

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  String capitalizeWords(String? str) {
    if (str!.isEmpty) return str;
    return str.split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Iconsax.location,
                    size: 19,
                  ),
                  const Gap(7),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.addressLocation!,
                        style: const TextStyle(
                          fontSize: 21,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                      ),
                      Text(
                        '${capitalizeWords(widget.weather?.descCondition)} · ${DateFormat('EEEE, MMM d').format(DateTime.now())}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.weather?.feelsLike.round() ?? ''}°',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        fontSize: 65,
                        height: 1.05,
                      ),
                    ),
                    const Gap(5),
                    SvgPicture.asset(
                      widget.getWeatherIcon(
                          widget.weather?.mainCondition ?? '', widget.weather?.timezone ?? 0),
                      width: 65,
                      height: 65,
                    ),
                  ],
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.weather?.mainCondition ?? ''} · ',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 13.5,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/weathers/windy_breezy.svg',
                      width: 25,
                      height: 25,
                      color: Colors.grey.shade500,
                    ),
                    Text(
                      ' ${widget.weather?.windSpeed.round() ?? ''} KpH · ',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 13.5,
                      ),
                    ),
                    Image.asset(
                      'assets/weathers/humidity.png',
                      width: 17.5,
                      height: 17.5,
                      color: Colors.grey.shade500,
                    ),
                    Text(
                      ' ${widget.weather?.humidity.round() ?? ''}%',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(25),
            GestureDetector(
              onTap: () {
                try {
                  var url = 'https://openweathermap.org/';
                  final Uri uri = Uri.parse(url);
                  launchUrl(uri);
                } catch (e) {
                  debugPrint('Error : $e');
                }
              },
              child: Text(
                'openweathermap.org',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            //https://openweathermap.org/
            const Gap(15),
            ButtonDelete(
              text: 'Close',
              color: Colors.white,
              borderColor: Colors.black54,
              textColor: Theme.of(context).primaryColor,
              smallText: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
