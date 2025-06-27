// models/color_analysis_result.dart
import 'package:flutter/material.dart';

class ColorAnalysisResult {
  final String skinTone;
  final String skinType;
  final String undertone;
  final List<Color> recommendedColors;
  final List<Color> avoidColors;
  final Map<String, int> averageRGB;
  final double confidence;
  final String? errorMessage;

  ColorAnalysisResult({
    required this.skinTone,
    required this.skinType,
    required this.undertone,
    required this.recommendedColors,
    required this.avoidColors,
    required this.averageRGB,
    required this.confidence,
    this.errorMessage,
  });

  // Helper method to get confidence description
  String get confidenceDescription {
    if (confidence >= 0.8) {
      return 'High Confidence';
    } else if (confidence >= 0.6) {
      return 'Good Confidence';
    } else if (confidence >= 0.4) {
      return 'Medium Confidence';
    } else {
      return 'Low Confidence';
    }
  }

  // Helper method to get skin tone color
  Color get skinToneColor {
    return Color.fromRGBO(
      averageRGB['r']!,
      averageRGB['g']!,
      averageRGB['b']!,
      1.0,
    );
  }

  // Helper method to format RGB as hex
  String get hexColor {
    final r = averageRGB['r']!.toRadixString(16).padLeft(2, '0');
    final g = averageRGB['g']!.toRadixString(16).padLeft(2, '0');
    final b = averageRGB['b']!.toRadixString(16).padLeft(2, '0');
    return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }

  // Method to get detailed description
  Map<String, String> get detailedDescription {
    return {
      'Skin Tone': skinTone,
      'Undertone': undertone,
      'Skin Type': skinType,
      'Average Color': hexColor,
      'Confidence': confidenceDescription,
    };
  }

  // Method to convert to JSON for storage/API calls
  Map<String, dynamic> toJson() {
    return {
      'skinTone': skinTone,
      'skinType': skinType,
      'undertone': undertone,
      'recommendedColors': recommendedColors.map((c) => c.value).toList(),
      'avoidColors': avoidColors.map((c) => c.value).toList(),
      'averageRGB': averageRGB,
      'confidence': confidence,
      'errorMessage': errorMessage,
    };
  }

  // Method to create from JSON
  factory ColorAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ColorAnalysisResult(
      skinTone: json['skinTone'] as String,
      skinType: json['skinType'] as String,
      undertone: json['undertone'] as String,
      recommendedColors: (json['recommendedColors'] as List)
          .map((c) => Color(c as int))
          .toList(),
      avoidColors: (json['avoidColors'] as List)
          .map((c) => Color(c as int))
          .toList(),
      averageRGB: Map<String, int>.from(json['averageRGB']),
      confidence: json['confidence'] as double,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}