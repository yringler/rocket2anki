import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:dart/dashboard.dart';
import 'package:dart/lesson.dart';
import 'package:dart/utils.dart';

class RocketFetcher {
  final int productId;
  final String auth;

  RocketFetcher({required this.auth, required this.productId});

  Future<DashboardRoot?> rocketFetchHome() {
    return rocketFetchProductResource(
        'dashboard?timezone=America%2FNew_York&api_version=2',
        DashboardRoot.fromJson);
  }

  Future<LessonRoot?> rocketFetchLesson(int id) {
    return rocketFetchProductResource('lesson/$id', LessonRoot.fromJson);
  }

  Future<T?> rocketFetchProductResource<T>(
      String path, T Function(Map<String, dynamic>) fromJson) async {
    return rocketFetchUrl(
        'https://app.rocketlanguages.com/api/v2/product/$productId/$path',
        auth,
        fromJson);
  }

  static Future<T?> rocketFetchUrl<T>(String url, String auth,
      T Function(Map<String, dynamic>) fromJson) async {
    final response = await retry('rocketFetch: $url', () async {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));

      request.headers.add('accept', 'application/json, text/plain, */*');
      request.headers.add('accept-language', 'en-US,en;q=0.9');
      request.headers.add('authorization', 'Bearer $auth');
      request.headers.add('cache-control', 'no-cache');
      request.headers.add('pragma', 'no-cache');

      final httpClientResponse = await request.close();
      final responseBody =
          await httpClientResponse.transform(utf8.decoder).join();
      return fromJson(json.decode(responseBody));
    });

    return response;
  }
}
