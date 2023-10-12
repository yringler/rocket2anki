import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:dart/config.dart';
import 'package:dart/dashboard.dart';
import 'package:dart/lesson.dart';

Future<DashboardRoot?> rocketFetchHome() {
  return rocketFetchUrl('dashboard?timezone=America%2FNew_York&api_version=2',
      DashboardRoot.fromJson);
}

Future<LessonRoot?> rocketFetchLesson(int id) {
  return rocketFetchUrl('lesson/$id', LessonRoot.fromJson);
}

Future<T?> retry<T>(String message, Future<T> Function() action) async {
  dynamic errorMessage;
  int i = 0;
  for (; i < 10; i++) {
    await Future.delayed(Duration(seconds: 5));

    try {
      return await action();
    } catch (err) {
      errorMessage = err;
    }
  }

  print('$i$message$errorMessage');
  return null;
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
    request.headers.add('authorization', 'Bearer ${config.bearer}');
    request.headers.add('cache-control', 'no-cache');
    request.headers.add('pragma', 'no-cache');
    // request.headers.add('x-xsrf-token', config.xsrf);

    final httpClientResponse = await request.close();
    final responseBody =
        await httpClientResponse.transform(utf8.decoder).join();
    return fromJson(json.decode(responseBody));
  });

  return response;
}
