import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:dart/config.dart';
import 'package:dart/dashboard.dart';
import 'package:dart/lesson.dart';
import 'package:dart/utils.dart';

class RocketFetcher {
  final String auth;

  RocketFetcher({required this.auth});

  Future<DashboardRoot?> rocketFetchHome() {
    return rocketFetchUrl('dashboard?timezone=America%2FNew_York&api_version=2',
        DashboardRoot.fromJson);
  }

  Future<LessonRoot?> rocketFetchLesson(int id) {
    return rocketFetchUrl('lesson/$id', LessonRoot.fromJson);
  }

  Future<T?> rocketFetchUrl<T>(
      String path, T Function(Map<String, dynamic>) fromJson) async {
    final response = await retry('rocketFetch: $path', () async {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(
        Uri.parse(
            'https://app.rocketlanguages.com/api/v2/product/${config.productId}/$path'),
      );

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
