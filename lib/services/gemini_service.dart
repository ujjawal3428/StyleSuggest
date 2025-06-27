// TODO Implement this library.
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  static final _model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: _apiKey,
  );

  /// Generates clothing outfit suggestions using Gemini AI based on skin tone
  static Future<List<Map<String, dynamic>>> generateOutfits(String skinTone) async {
    final prompt = '''
You are a personal fashion stylist. Suggest 5 stylish outfit combinations for a person with "$skinTone" skin tone. 
For each outfit, give:
- a catchy title
- a short description of the outfit
- an image URL (you can use a placeholder or Unsplash-like image)

Return response in the following JSON format:
[
  {
    "title": "Outfit Name",
    "description": "Short stylish description",
    "imageUrl": "https://example.com/image.jpg"
  },
  ...
]
''';

    final content = [Content.text(prompt)];

    try {
      final response = await _model.generateContent(content);
      final text = response.text ?? '';

      // Extract JSON array from the AI's response
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(text);
      if (jsonMatch == null) throw Exception("No JSON found in Gemini response");

      final jsonString = jsonMatch.group(0)!;
      final List<dynamic> parsed = List<Map<String, dynamic>>.from(jsonDecode(jsonString));
      return parsed.cast<Map<String, dynamic>>();
    } catch (e) {
      print("GeminiService error: $e");
      return [];
    }
  }
}
