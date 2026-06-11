// lib/services/claude_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:show_picker/data/Suggestion.dart';

class ClaudeService {
  final Dio _dio = Dio();

  /// Builds the prompt from user selections
  String _buildPrompt({
    required String mood,
    required String genre,
    required String language,
    required int maxDuration,
  }) {
    return '''
You are a movie and show recommendation expert.
Suggest exactly 20 titles based on:
- Mood: $mood
- Genre: $genre
- Language: $language
- Max duration: $maxDuration minutes

Rules:
- Only real, existing titles
- Match the language preference strictly
- Match duration — no title longer than $maxDuration mins

Reply ONLY with a valid JSON array. No explanation, no markdown, no extra text.
Format exactly: [{"title":"...","year":2023,"reason":"..."}]
The reason must be 1-2 sentences explaining why this matches the mood.
''';
  }

  /// Calls Claude API and returns list of suggestions
  Future<List<Suggestion>> getSuggestions({
    required String apiKey,
    required String mood,
    required String genre,
    required String language,
    required int maxDuration,
  }) async {
    final cleanKey = apiKey.trim();
    try {
      final requestData = {
        'model': 'claude-3-5-sonnet-latest',
        'max_tokens': 2000,
        'messages': [
          {
            'role': 'user',
            'content': _buildPrompt(
              mood: mood,
              genre: genre,
              language: language,
              maxDuration: maxDuration,
            ),
          }
        ],
      };

      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': cleanKey,
            'anthropic-version': '2023-06-01',
            'Accept': 'application/json',
          },
          contentType: 'application/json',
        ),
        data: requestData,
      );

      // Extract text from response
      final text = response.data['content'][0]['text'] as String;
      print("=====Claude Response=====\n$text");
      // Parse JSON array
      final List<dynamic> jsonList = jsonDecode(text);
      return jsonList.map((e) => Suggestion.fromJson(e)).toList();

    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMessage = e.message ?? 'Unknown error';
      
      if (errorData is Map && errorData.containsKey('error')) {
        final error = errorData['error'];
        if (error is Map && error.containsKey('message')) {
          errorMessage = error['message'];
        }
      }

      print("=====Claude API Error=====\nStatus: ${e.response?.statusCode}\nBody: ${e.response?.data}\nMessage: $errorMessage");

      if (e.response?.statusCode == 401) {
        throw Exception('Invalid Claude API key. Check Settings.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('No internet connection.');
      }
      throw Exception('Claude API error: $errorMessage');
    }
  }
}