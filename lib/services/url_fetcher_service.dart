import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchedUrlResult {
  final String title;
  final String content;
  final String finalUrl;
  final String sourceName;
  final int charCount;

  FetchedUrlResult({
    required this.title,
    required this.content,
    required this.finalUrl,
    required this.sourceName,
    required this.charCount,
  });
}

class UrlFetcherService {
  /// Transforms common URLs (GitHub, Gist, Pastebin) into raw text URLs if needed.
  static String normalizeUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    // GitHub blob -> raw
    // https://github.com/user/repo/blob/main/poem.txt -> https://raw.githubusercontent.com/user/repo/main/poem.txt
    final githubBlobRegex = RegExp(
      r'^https?:\/\/github\.com\/([^\/]+)\/([^\/]+)\/blob\/([^\/]+)\/(.+)$',
      caseSensitive: false,
    );
    final ghMatch = githubBlobRegex.firstMatch(url);
    if (ghMatch != null) {
      final user = ghMatch.group(1);
      final repo = ghMatch.group(2);
      final branch = ghMatch.group(3);
      final path = ghMatch.group(4);
      return 'https://raw.githubusercontent.com/$user/$repo/$branch/$path';
    }

    // Pastebin -> raw
    final pastebinRegex =
        RegExp(r'^https?:\/\/pastebin\.com\/([a-zA-Z0-9]+)$', caseSensitive: false);
    final pbMatch = pastebinRegex.firstMatch(url);
    if (pbMatch != null) {
      final id = pbMatch.group(1);
      return 'https://pastebin.com/raw/$id';
    }

    // GitHub Gist standard -> raw
    final gistRegex =
        RegExp(r'^https?:\/\/gist\.github\.com\/([^\/]+)\/([a-zA-Z0-9]+)$', caseSensitive: false);
    final gistMatch = gistRegex.firstMatch(url);
    if (gistMatch != null) {
      final user = gistMatch.group(1);
      final id = gistMatch.group(2);
      return 'https://gist.githubusercontent.com/$user/$id/raw';
    }

    return url;
  }

  /// Fetches the text content from the URL.
  static Future<FetchedUrlResult> fetchTextFromUrl(String url) async {
    final cleanUrl = normalizeUrl(url);
    final uri = Uri.parse(cleanUrl);

    final response = await http.get(uri).timeout(
          const Duration(seconds: 18),
          onTimeout: () => throw Exception('Tiempo de espera agotado al conectar con el URL.'),
        );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al descargar el archivo: Código HTTP ${response.statusCode}');
    }

    // Decode body with UTF-8 fallback
    String body;
    try {
      body = utf8.decode(response.bodyBytes);
    } catch (_) {
      body = response.body;
    }

    // If HTML page was returned, extract text
    final isHtml = body.contains('<html') || body.contains('<!DOCTYPE html');
    String processedContent = body;
    String suggestedTitle = _deriveTitleFromUrl(cleanUrl);

    if (isHtml) {
      // Extract title from <title> tag
      final titleMatch =
          RegExp(r'<title>(.*?)<\/title>', caseSensitive: false).firstMatch(body);
      if (titleMatch != null) {
        final t = titleMatch.group(1)?.trim();
        if (t != null && t.isNotEmpty) {
          suggestedTitle = t.replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&');
        }
      }

      // Strip scripts, styles, and HTML tags for a clean text extraction
      processedContent = body
          .replaceAll(RegExp(r'<script[\s\S]*?<\/script>', caseSensitive: false), '')
          .replaceAll(RegExp(r'<style[\s\S]*?<\/style>', caseSensitive: false), '')
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    } else {
      // Plain text or markdown: check if first line is a title (# Titulo or short line)
      final lines = processedContent.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) {
          if (trimmed.startsWith('#')) {
            suggestedTitle = trimmed.replaceAll(RegExp(r'^#+\s*'), '');
          } else if (trimmed.length < 60 && !trimmed.contains('http')) {
            suggestedTitle = trimmed;
          }
          break;
        }
      }
    }

    // Determine readable source name
    String sourceName = 'Web URL';
    if (cleanUrl.contains('githubusercontent.com') || cleanUrl.contains('github.com')) {
      sourceName = 'GitHub';
    } else if (cleanUrl.contains('pastebin.com')) {
      sourceName = 'Pastebin';
    } else if (cleanUrl.contains('google.com')) {
      sourceName = 'Google Drive/Docs';
    }

    return FetchedUrlResult(
      title: suggestedTitle,
      content: processedContent,
      finalUrl: cleanUrl,
      sourceName: sourceName,
      charCount: processedContent.length,
    );
  }

  static String _deriveTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        var last = segments.last;
        // remove extension
        if (last.contains('.')) {
          last = last.substring(0, last.lastIndexOf('.'));
        }
        // replace hyphens/underscores
        last = last.replaceAll(RegExp(r'[-_]'), ' ').trim();
        if (last.isNotEmpty) {
          // Capitalize words
          return last
              .split(' ')
              .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
              .join(' ');
        }
      }
    } catch (_) {}
    return 'Archivo Importado';
  }
}
