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
