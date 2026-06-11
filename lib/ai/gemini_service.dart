// lib/ai/gemini_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:show_picker/data/Suggestion.dart';

class GeminiService {
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

  /// Calls Gemini API and returns list of suggestions
  Future<List<Suggestion>> getSuggestions({
    required String apiKey,
    required String mood,
    required String genre,
    required String language,
    required int maxDuration,
  }) async {
    final cleanKey = apiKey.trim();
    // Use gemini-2.0-flash on v1beta
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$cleanKey';

    try {
      final requestData = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text': _buildPrompt(
                  mood: mood,
                  genre: genre,
                  language: language,
                  maxDuration: maxDuration,
                ),
              }
            ]
          }
        ],
      };

      final response = await _dio.post(
        url,
        data: requestData,
      );

      // Extract text from response
      // Gemini structure: candidates[0].content.parts[0].text
      final String text = response.data['candidates'][0]['content']['parts'][0]['text'];

      print("=====Gemini Response=====\n$text");

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

      print("=====Gemini API Error=====\nStatus: ${e.response?.statusCode}\nBody: ${e.response?.data}\nMessage: $errorMessage");

      if (e.response?.statusCode == 400) {
        throw Exception('Invalid Gemini Request or Key. Details: $errorMessage');
      }
      throw Exception('Gemini API error: $errorMessage');
    } catch (e) {
      throw Exception('Failed to parse Gemini response: $e');
    }
  }
  Future<List<Suggestion>> getSuggestionsDummy({
    required String apiKey,
    required String mood,
    required String genre,
    required String language,
    required int maxDuration,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final List<Map<String, dynamic>> starWarsList = [
      {"title": "Star Wars", "year": 1977, "type": "movie"},
      {"title": "Doraemon the Movie: Nobita's Little Star Wars 2021", "year": 2022, "type": "movie"},
      {"title": "Star Wars: Andor", "year": 2022, "type": "series"},
      {"title": "Star Wars: Visions", "year": 2021, "type": "series"},
      {"title": "Star Wars: The Clone Wars", "year": 2008, "type": "series"},
      {"title": "Star Wars: The Bad Batch", "year": 2021, "type": "series"},
      {"title": "Star Wars Rebels", "year": 2014, "type": "series"},
      {"title": "Star Wars: The Force Awakens", "year": 2015, "type": "movie"},
      {"title": "Star Wars: The Rise of Skywalker", "year": 2019, "type": "movie"},
      {"title": "Star Wars: The Last Jedi", "year": 2017, "type": "movie"},
    ];

    // Generate 10 Star Wars suggestions
    return List.generate(10, (index) {
      if (index < starWarsList.length) {
        final item = starWarsList[index];
        return Suggestion(
          title: item['title'],
          year: item['year'],
          reason: "This Star Wars entry is a great match for your $mood mood. It fits your $genre preference perfectly.",
          type: item['type'],
        );
      } else {
        final id = index + 1;
        return Suggestion(
          title: "Mock Movie $id ($mood)",
          year: 2020 + (index % 5),
          reason: "This is a dummy recommendation for $mood mood in $language. It fits your $genre preference and is under $maxDuration minutes.",
          type: index % 3 == 0 ? "series" : "movie",
        );
      }
    });
  }
}
