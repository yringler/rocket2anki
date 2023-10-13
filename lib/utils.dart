String slugify(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'[^\w\-.]+'), '')
      .replaceAll(RegExp(r'\-\-+'), '-')
      .replaceAll(RegExp(r'^-+'), '')
      .replaceAll(RegExp(r'-+$'), '');
}

String join(List<String> path) {
  return path.join('/');
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

  print('$i - $message - $errorMessage');
  return null;
}
