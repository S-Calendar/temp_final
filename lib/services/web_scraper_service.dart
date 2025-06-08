// lib/services/web_scraper_service.dart
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class WebScraperService {
  Future<String?> fetchAndExtractText(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = parse(response.body);

        // 불필요한 태그 제거 (스크립트, 스타일, 헤더, 푸터, 내비게이션 등)
        document
            .querySelectorAll('script, style, header, footer, nav, aside')
            .forEach((element) {
              element.remove();
            });

        // 본문 텍스트 추출
        final text = document.body?.text ?? '';

        // 여러 공백을 단일 공백으로 치환하고 양 끝 공백 제거
        return text.replaceAll(RegExp(r'\s+'), ' ').trim();
      } else {
        print('Failed to load page: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching or parsing URL: $e');
      return null;
    }
  }
}
