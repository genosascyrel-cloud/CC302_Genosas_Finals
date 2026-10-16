import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class Weather {
  final double temp;
  final double wind;
  final int code;
  const Weather(this.temp, this.wind, this.code);

  String get label {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 82) return 'Showers';
    return 'Thunderstorm';
  }

  IconData get icon {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.wb_cloudy;
    if (code <= 48) return Icons.cloud;
    if (code <= 82) return Icons.water_drop;
    return Icons.flash_on;
  }
}

/// Data comes from two free, key-less public APIs:
///  - Wikipedia REST API (attraction summaries + photos)
///  - Open-Meteo (live weather in Tagbilaran, Bohol)
class BoholApi {
  static const categories = ['All', 'Nature', 'Beach', 'Heritage', 'Wildlife', 'Town'];

  static const _spots = <String, String>{
    'Chocolate Hills': 'Nature',
    'Philippine tarsier': 'Wildlife',
    'Panglao': 'Beach',
    'Alona Beach': 'Beach',
    'Baclayon Church': 'Heritage',
    'Loboc, Bohol': 'Town',
    'Hinagdanan Cave': 'Nature',
    'Balicasag Island': 'Beach',
    'Anda, Bohol': 'Beach',
    'Bilar, Bohol': 'Nature',
    'Tagbilaran': 'Town',
    'Dauis, Bohol': 'Heritage',
  };

  static const _headers = {'User-Agent': 'BoholExplorer/1.0 (CC302 student project)'};

  Future<List<Place>> fetchPlaces() async {
    final results = await Future.wait(_spots.entries.map((e) => _fetchOne(e.key, e.value)));
    final places = results.whereType<Place>().toList();
    if (places.isEmpty) {
      throw ApiException('Could not load attractions. Check your internet connection and try again.');
    }
    return places;
  }

  Future<Place?> _fetchOne(String title, String category) async {
    try {
      final uri = Uri.parse(
          'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title)}');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      return Place.fromWikiSummary(jsonDecode(res.body) as Map<String, dynamic>, category);
    } catch (_) {
      return null; // one failed item should not break the whole list
    }
  }

  Future<Weather> fetchWeather() async {
    try {
      final uri = Uri.parse('https://api.open-meteo.com/v1/forecast'
          '?latitude=9.65&longitude=123.85&current=temperature_2m,weather_code,wind_speed_10m');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw ApiException('Weather unavailable');
      final c = (jsonDecode(res.body) as Map<String, dynamic>)['current'] as Map<String, dynamic>;
      return Weather((c['temperature_2m'] as num).toDouble(),
          (c['wind_speed_10m'] as num).toDouble(), (c['weather_code'] as num).toInt());
    } catch (_) {
      throw ApiException('Weather unavailable');
    }
  }
}
