import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:dart/config.dart';
import 'package:dart/dashboard.dart';
import 'package:dart/lesson.dart';

Future<DashboardRoot?> rocketFetchHome() {
  return rocketFetchUrl('dashboard?timezone=America%2FNew_York&api_version=2');
}

Future<LessonRoot?> rocketFetchLesson(int id) {
  return rocketFetchUrl('lesson/$id');
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

Future<T?> rocketFetchUrl<T>(String path) async {
  final response = await retry('rocketFetch: $path', () async {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(
      Uri.https('app.rocketlanguages.com',
          '/api/v2/product/${config.productId}/$path'),
    );

    request.headers.add('accept', 'application/json, text/plain, */*');
    request.headers.add('accept-language', 'en-US,en;q=0.9');
    request.headers.add('authorization', 'Bearer ${config.bearer}');
    request.headers.add('cache-control', 'no-cache');
    request.headers.add('pragma', 'no-cache');
    request.headers.add('sec-ch-ua',
        '"Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"');
    request.headers.add('sec-ch-ua-mobile', '?0');
    request.headers.add('sec-ch-ua-platform', '"Windows"');
    request.headers.add('sec-fetch-dest', 'empty');
    request.headers.add('sec-fetch-mode', 'cors');
    request.headers.add('sec-fetch-site', 'same-origin');
    request.headers.add('x-xsrf-token', config.xsrf);
    request.headers.add('cookie', config.cookie);
    request.headers.add('Referer',
        'https://app.rocketlanguages.com/members/products/1/lesson/5454');
    request.headers.add('Referrer-Policy', 'strict-origin-when-cross-origin');

    final httpClientResponse = await request.close();
    final responseBody =
        await httpClientResponse.transform(utf8.decoder).join();
    return json.decode(responseBody) as T;
  });

  return response;
}
