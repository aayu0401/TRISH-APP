import '../config.dart';

String resolveMediaUrl(String? rawUrl) {
  if (rawUrl == null) return '';
  final url = rawUrl.trim();
  if (url.isEmpty) return '';

  final lower = url.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) return url;

  if (url.startsWith('/')) return '$API_URL$url';
  return '$API_URL/$url';
}

