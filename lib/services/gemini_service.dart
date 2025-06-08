// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception("GEMINI_API_KEY not found in .env file");
    }
    // 모델 초기화: 'gemini-1.5-flash' 또는 'gemini-1.5-pro' 등 사용
    // 'gemini-1.5-flash'는 더 빠르고 비용 효율적입니다.
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<Map<String, String>?> summarizeUrlContent(String content) async {
    if (content.isEmpty) {
      return null;
    }

    // 특정 항목을 추출하도록 상세한 프롬프트 작성
    final prompt = """
    다음 웹 페이지 내용을 분석하여 '참가대상', '신청방법', '내용(프로그램 개요)', '신청기간' 네 가지 항목을 간결하게 요약해 주세요. 각 항목별로 콜론(:) 뒤에 내용을 작성하고, 항목 사이에 줄바꿈을 해주세요. 만약 특정 항목의 정보가 없다면 '정보 없음'으로 표시해주세요.

    예시 형식:
    참가대상: [내용]
    신청방법: [내용]
    내용: [내용]
    신청기간: [내용]

    웹 페이지 내용:
    $content
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final rawSummary = response.text;

      if (rawSummary == null || rawSummary.isEmpty) {
        return null;
      }

      // 요약된 텍스트에서 각 항목 파싱
      final Map<String, String> parsedSummary = {};
      final lines = rawSummary.split('\n');

      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim(); // 콜론 포함될 수 있으므로 join
          parsedSummary[key] = value;
        }
      }
      return parsedSummary;
    } on GenerativeAIException catch (e) {
      print('Gemini API Error: ${e.message}');
      // API 오류 메시지 포함하여 null 반환 또는 특정 오류 객체 반환
      return null;
    } catch (e) {
      print('An unexpected error occurred: $e');
      return null;
    }
  }
}
