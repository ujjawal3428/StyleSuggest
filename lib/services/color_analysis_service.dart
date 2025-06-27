// services/color_analysis_service.dart
import 'package:flutter/material.dart';
import 'package:virtual_closet/screens/color_analysis_result.dart';
import 'skin_tone_detector.dart';

class ColorAnalysisService {
  final SkinToneDetector _skinToneDetector = SkinToneDetector();

  Future<ColorAnalysisResult> analyzeSkinTone(String imagePath) async {
    try {
      // Use the actual skin tone detector
      final analysisResult = await _skinToneDetector.analyzeSkinTone(imagePath);
      
      return ColorAnalysisResult(
        skinTone: analysisResult['skinTone'] as String,
        skinType: analysisResult['skinType'] as String,
        undertone: analysisResult['undertone'] as String,
        recommendedColors: List<Color>.from(analysisResult['recommendedColors']),
        avoidColors: List<Color>.from(analysisResult['avoidColors']),
        averageRGB: Map<String, int>.from(analysisResult['averageRGB']),
        confidence: analysisResult['confidence'] as double,
      );
    } catch (e) {
      // Fallback to basic analysis if face detection fails
      return _getFallbackAnalysis(e.toString());
    }
  }

  ColorAnalysisResult _getFallbackAnalysis(String error) {
    return ColorAnalysisResult(
      skinTone: 'Medium',
      skinType: 'Combination',
      undertone: 'Neutral',
      recommendedColors: [
        const Color(0xFF32CD32), // Lime Green
        const Color(0xFFFF69B4), // Hot Pink
        const Color(0xFF9370DB), // Medium Purple
        const Color(0xFF20B2AA), // Light Sea Green
      ],
      avoidColors: [
        const Color(0xFFFFFF00), // Bright Yellow
        const Color(0xFF808080), // Gray
      ],
      averageRGB: {'r': 150, 'g': 120, 'b': 100},
      confidence: 0.3, // Low confidence for fallback
      errorMessage: 'Face detection failed: $error',
    );
  }

  String getSkinToneDescription(String skinTone, String undertone) {
    final base = _getSkinToneBase(skinTone);
    final undertoneDesc = _getUndertoneDescription(undertone);
    return '$base with $undertoneDesc';
  }

  String _getSkinToneBase(String skinTone) {
    switch (skinTone) {
      case 'Light':
        return 'Light skin tone';
      case 'Light-Medium':
        return 'Light to medium skin tone';
      case 'Medium':
        return 'Medium skin tone';
      case 'Medium-Deep':
        return 'Medium to deep skin tone';
      case 'Deep':
        return 'Deep skin tone';
      default:
        return 'Medium skin tone';
    }
  }

  String _getUndertoneDescription(String undertone) {
    switch (undertone) {
      case 'Warm':
        return 'warm undertones (yellow/golden base)';
      case 'Cool':
        return 'cool undertones (pink/blue base)';
      case 'Neutral':
        return 'neutral undertones (balanced base)';
      default:
        return 'neutral undertones';
    }
  }

  List<String> getColorPaletteAdvice(String undertone) {
    switch (undertone) {
      case 'Warm':
        return [
          'Earth tones like terracotta, rust, and warm browns',
          'Golden yellows and warm oranges',
          'Warm greens like olive and forest green',
          'Rich corals and warm reds',
          'Cream and warm whites instead of stark white',
        ];
      case 'Cool':
        return [
          'Jewel tones like sapphire, emerald, and amethyst',
          'Cool blues and purples',
          'True reds and berry tones',
          'Cool greens like teal and mint',
          'Pure whites and cool grays',
        ];
      case 'Neutral':
        return [
          'Most colors work well with neutral undertones',
          'Soft pastels and muted tones',
          'Both warm and cool colors in moderation',
          'Dusty roses and sage greens',
          'Off-whites and light grays',
        ];
      default:
        return ['Neutral colors work well for most skin tones'];
    }
  }

  void dispose() {
    _skinToneDetector.dispose();
  }
}