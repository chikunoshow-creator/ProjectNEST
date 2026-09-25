// lib/services/weather_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'translation_service.dart';

class WeatherService {
  // インメモリキャッシュ
  String? _cachedRegion;
  String? _cachedSummary;
  DateTime? _lastFetchTime;

  // キャッシュ有効期間（2時間）
  static const Duration cacheDuration = Duration(hours: 2);

  /// 指定地域名から天気を取得し、サマリー文字列（例: 「晴れ (18℃)」）を返す
  /// 失敗時・未設定時はサイレントフォールバックとして null を返却
  Future<String?> fetchWeather({
    required String region,
    required String lang,
  }) async {
    final cleanRegion = region.trim();
    if (cleanRegion.isEmpty) return null;

    // 1. インメモリキャッシュの確認
    if (_cachedRegion == cleanRegion &&
        _cachedSummary != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      debugPrint("[WeatherService] Memory Cache Hit: $_cachedSummary");
      return _cachedSummary;
    }

    // 2. SharedPreferences永続キャッシュの確認
    final prefs = await SharedPreferences.getInstance();
    final savedRegion = prefs.getString('weather_cached_region');
    final savedSummary = prefs.getString('weather_cached_summary');
    final savedTimeStr = prefs.getString('weather_cached_time');

    if (savedRegion == cleanRegion &&
        savedSummary != null &&
        savedTimeStr != null) {
      final savedTime = DateTime.tryParse(savedTimeStr);
      if (savedTime != null &&
          DateTime.now().difference(savedTime) < cacheDuration) {
        _cachedRegion = savedRegion;
        _cachedSummary = savedSummary;
        _lastFetchTime = savedTime;
        debugPrint("[WeatherService] Disk Cache Hit: $_cachedSummary");
        return _cachedSummary;
      }
    }

    // 3. APIからの取得（ジオコーディング ➔ 天気取得）
    try {
      // 3-1. ジオコーディング（地域名 ➔ 緯度・経度）
      final geoUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(cleanRegion)}&count=1&language=$lang',
      );
      final geoRes = await http.get(geoUrl).timeout(const Duration(seconds: 5));
      if (geoRes.statusCode != 200) return null;

      final geoData = jsonDecode(geoRes.body);
      final results = geoData['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        debugPrint("[WeatherService] No geocoding result for: $cleanRegion");
        return null;
      }

      final double lat = (results.first['latitude'] as num).toDouble();
      final double lon = (results.first['longitude'] as num).toDouble();

      // 3-2. 天気予報API（緯度・経度 ➔ 天気コード・気温）
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code',
      );
      final weatherRes = await http
          .get(weatherUrl)
          .timeout(const Duration(seconds: 5));
      if (weatherRes.statusCode != 200) return null;

      final weatherData = jsonDecode(weatherRes.body);
      final current = weatherData['current'];
      if (current == null) return null;

      final int weatherCode = (current['weather_code'] as num).toInt();
      final double temp = (current['temperature_2m'] as num).toDouble();

      // 3-3. 天気コードの要約と翻訳
      final String conditionKey = _mapWeatherCodeToKey(weatherCode);
      final String condition = T.get(conditionKey, lang);
      final String tempUnit = (lang == 'ja') ? "℃" : "°C";
      final String summary = "$condition (${temp.round()}$tempUnit)";

      // 3-4. キャッシュの保存
      _cachedRegion = cleanRegion;
      _cachedSummary = summary;
      _lastFetchTime = DateTime.now();

      await prefs.setString('weather_cached_region', cleanRegion);
      await prefs.setString('weather_cached_summary', summary);
      await prefs.setString(
        'weather_cached_time',
        _lastFetchTime!.toIso8601String(),
      );

      debugPrint("[WeatherService] Weather Fetched Successfully: $summary");
      return summary;
    } catch (e) {
      debugPrint("[WeatherService] Fetch Error (Silent Fallback): $e");
      return null;
    }
  }

  /// WMO天気コード（0〜99）を主要な天候キーに大まかに分類
  String _mapWeatherCodeToKey(int code) {
    if (code == 0) return 'weather_clear';
    if (code >= 1 && code <= 2) return 'weather_partly_cloudy';
    if (code == 3) return 'weather_cloudy';
    if (code == 45 || code == 48) return 'weather_fog';
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return 'weather_rain';
    }
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return 'weather_snow';
    }
    if (code >= 95 && code <= 99) return 'weather_thunder';
    return 'weather_partly_cloudy';
  }
}
