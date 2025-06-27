// services/skin_tone_detector.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class SkinToneDetector {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );

  Future<Map<String, dynamic>> analyzeSkinTone(String imagePath) async {
    try {
      // Load and decode the image
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Detect faces using ML Kit
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        throw Exception('No face detected in the image');
      }

      // Get the first detected face
      final face = faces.first;

      // Extract skin tone from face region
      final skinToneData = await _extractSkinToneFromFace(image, face);

      // Analyze the skin tone
      final analysis = _analyzeSkinToneData(skinToneData);

      return analysis;
    } catch (e) {
      throw Exception('Skin tone analysis failed: $e');
    }
  }

  Future<Map<String, dynamic>> _extractSkinToneFromFace(
      img.Image image, Face face) async {
    final boundingBox = face.boundingBox;

    // Convert bounding box to image coordinates
    final left = math.max(0, boundingBox.left.toInt());
    final top = math.max(0, boundingBox.top.toInt());
    final right = math.min(image.width, boundingBox.right.toInt());
    final bottom = math.min(image.height, boundingBox.bottom.toInt());

    // Extract face region
    final faceRegion = img.copyCrop(image,
        x: left, y: top, width: right - left, height: bottom - top);

    // Sample skin pixels from key facial areas
    final skinPixels = _sampleSkinPixels(faceRegion);

    // Calculate average skin color
    final avgColor = _calculateAverageColor(skinPixels);

    return {
      'averageColor': avgColor,
      'skinPixels': skinPixels,
      'faceRegion': faceRegion,
    };
  }

  List<Map<String, int>> _sampleSkinPixels(img.Image faceRegion) {
    final pixels = <Map<String, int>>[];
    final width = faceRegion.width;
    final height = faceRegion.height;

    // Sample from forehead, cheeks, and chin areas
    final sampleAreas = [
      {'x': 0.3, 'y': 0.2, 'w': 0.4, 'h': 0.2}, // Forehead
      {'x': 0.1, 'y': 0.4, 'w': 0.25, 'h': 0.3}, // Left cheek
      {'x': 0.65, 'y': 0.4, 'w': 0.25, 'h': 0.3}, // Right cheek
      {'x': 0.35, 'y': 0.7, 'w': 0.3, 'h': 0.2}, // Chin
    ];

    for (final area in sampleAreas) {
      final startX = (width * area['x']!).toInt();
      final startY = (height * area['y']!).toInt();
      final endX = (startX + width * area['w']!).toInt();
      final endY = (startY + height * area['h']!).toInt();

      // Sample every 3rd pixel to avoid over-sampling
      for (int y = startY; y < endY; y += 3) {
        for (int x = startX; x < endX; x += 3) {
          if (x < width && y < height) {
            final pixel = faceRegion.getPixel(x, y);
            final r = pixel.r.toInt();
            final g = pixel.g.toInt();
            final b = pixel.b.toInt();
            // Filter out non-skin colors (too bright/dark/saturated)
            if (_isSkinColor(r, g, b)) {
              pixels.add({'r': r, 'g': g, 'b': b});
            }
          }
        }
      }
    }

    return pixels;
  }

  bool _isSkinColor(int r, int g, int b) {
    // Basic skin color filtering based on RGB values
    // This removes extreme values that are likely not skin
    final brightness = (r + g + b) / 3;

    // Remove very dark or very bright pixels
    if (brightness < 50 || brightness > 250) return false;

    // Remove pixels with very low red component (unlikely to be skin)
    if (r < 60) return false;

    // Remove pixels where green is much higher than red (likely background)
    if (g > r + 30) return false;

    // Remove pixels where blue is much higher than red (likely background)
    if (b > r + 30) return false;

    return true;
  }

  Map<String, int> _calculateAverageColor(List<Map<String, int>> pixels) {
    if (pixels.isEmpty) {
      return {'r': 150, 'g': 120, 'b': 100}; // Default fallback
    }

    int totalR = 0, totalG = 0, totalB = 0;

    for (final pixel in pixels) {
      totalR += pixel['r']!;
      totalG += pixel['g']!;
      totalB += pixel['b']!;
    }

    return {
      'r': totalR ~/ pixels.length,
      'g': totalG ~/ pixels.length,
      'b': totalB ~/ pixels.length,
    };
  }

  Map<String, dynamic> _analyzeSkinToneData(Map<String, dynamic> skinToneData) {
    final avgColor = skinToneData['averageColor'] as Map<String, int>;
    final r = avgColor['r']!;
    final g = avgColor['g']!;
    final b = avgColor['b']!;

    // Convert to HSV for better analysis
    final hsv = _rgbToHsv(r, g, b);
    final hue = hsv['h']!;
    final saturation = hsv['s']!;
    final value = hsv['v']!;

    // Determine undertone based on color analysis
    final undertone = _determineUndertone(r, g, b, hue);

    // Determine skin tone category
    final skinTone = _determineSkinTone(value, saturation);

    // Determine skin type based on color properties
    final skinType = _determineSkinType(r, g, b, saturation);

    // Get color recommendations
    final colorRecommendations = _getColorRecommendations(undertone, skinTone);

    return {
      'skinTone': skinTone,
      'skinType': skinType,
      'undertone': undertone,
      'averageRGB': {'r': r, 'g': g, 'b': b},
      'averageHSV': hsv,
      'recommendedColors': colorRecommendations['recommended'],
      'avoidColors': colorRecommendations['avoid'],
      'confidence': _calculateConfidence(skinToneData['skinPixels']),
    };
  }

  Map<String, double> _rgbToHsv(int r, int g, int b) {
    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;

    final max = math.max(rNorm, math.max(gNorm, bNorm));
    final min = math.min(rNorm, math.min(gNorm, bNorm));
    final delta = max - min;

    double hue = 0;
    if (delta != 0) {
      if (max == rNorm) {
        hue = 60 * (((gNorm - bNorm) / delta) % 6);
      } else if (max == gNorm) {
        hue = 60 * (((bNorm - rNorm) / delta) + 2);
      } else {
        hue = 60 * (((rNorm - gNorm) / delta) + 4);
      }
    }

    final saturation = max == 0 ? 0 : delta / max;
    final value = max;

    return {
      'h': hue.toDouble(),
      's': saturation.toDouble(),
      'v': value.toDouble(),
    };
  }

  String _determineUndertone(int r, int g, int b, double hue) {
    // Analyze color relationships to determine undertone
    final yellowness = (r + g) - b;
    final pinkness = (r + b) - g;

    // Hue-based analysis
    if (hue >= 20 && hue <= 40) {
      return 'Warm'; // Yellow-orange range
    } else if (hue >= 300 || hue <= 20) {
      return 'Cool'; // Pink-red range
    } else if (yellowness > pinkness + 20) {
      return 'Warm';
    } else if (pinkness > yellowness + 20) {
      return 'Cool';
    } else {
      return 'Neutral';
    }
  }

  String _determineSkinTone(double value, double saturation) {
    // Categorize based on brightness and saturation
    if (value < 0.3) {
      return 'Deep';
    } else if (value < 0.5) {
      return 'Medium-Deep';
    } else if (value < 0.7) {
      return 'Medium';
    } else if (value < 0.85) {
      return 'Light-Medium';
    } else {
      return 'Light';
    }
  }

  String _determineSkinType(int r, int g, int b, double saturation) {
    // Analyze skin type based on color properties
    final brightness = (r + g + b) / 3;

    if (saturation > 0.4 && brightness > 180) {
      return 'Oily'; // Higher saturation, brighter
    } else if (saturation < 0.2 && brightness < 140) {
      return 'Dry'; // Lower saturation, duller
    } else {
      return 'Combination';
    }
  }

  Map<String, List<Color>> _getColorRecommendations(
      String undertone, String skinTone) {
    final recommendations = <String, List<Color>>{};

    // Base recommendations on undertone
    switch (undertone) {
      case 'Warm':
        recommendations['recommended'] = [
          const Color(0xFFFF6B47), // Coral
          const Color(0xFFFFA500), // Orange
          const Color(0xFFFFD700), // Gold
          const Color(0xFF8B4513), // Saddle Brown
          const Color(0xFFDC143C), // Crimson
          const Color(0xFF228B22), // Forest Green
        ];
        recommendations['avoid'] = [
          const Color(0xFF800080), // Purple
          const Color(0xFF4169E1), // Royal Blue
          const Color(0xFF708090), // Slate Gray
          const Color(0xFFC0C0C0), // Silver
        ];
        break;

      case 'Cool':
        recommendations['recommended'] = [
          const Color(0xFF4169E1), // Royal Blue
          const Color(0xFF800080), // Purple
          const Color(0xFFFF1493), // Deep Pink
          const Color(0xFF00CED1), // Dark Turquoise
          const Color(0xFF9370DB), // Medium Purple
          const Color(0xFF008B8B), // Dark Cyan
        ];
        recommendations['avoid'] = [
          const Color(0xFFFFA500), // Orange
          const Color(0xFFFFD700), // Gold
          const Color(0xFF8B4513), // Saddle Brown
          const Color(0xFFDC143C), // Crimson
        ];
        break;

      case 'Neutral':
        recommendations['recommended'] = [
          const Color(0xFF32CD32), // Lime Green
          const Color(0xFFFF69B4), // Hot Pink
          const Color(0xFF9370DB), // Medium Purple
          const Color(0xFF20B2AA), // Light Sea Green
          const Color(0xFFDDA0DD), // Plum
          const Color(0xFF40E0D0), // Turquoise
        ];
        recommendations['avoid'] = [
          const Color(0xFFFFFF00), // Bright Yellow
          const Color(0xFF00FF00), // Neon Green
          const Color(0xFF808080), // Gray
        ];
        break;

      default:
        recommendations['recommended'] = [
          const Color(0xFF4169E1), // Royal Blue
          const Color(0xFF800080), // Purple
        ];
        recommendations['avoid'] = [
          const Color(0xFF808080), // Gray
        ];
    }

    // Adjust recommendations based on skin tone depth
    if (skinTone == 'Deep' || skinTone == 'Medium-Deep') {
      // Add richer, more vibrant colors
      recommendations['recommended']!.addAll([
        const Color(0xFFFFD700), // Gold
        const Color(0xFF800020), // Burgundy
        const Color(0xFF4B0082), // Indigo
      ]);
    } else if (skinTone == 'Light' || skinTone == 'Light-Medium') {
      // Add softer, more muted colors
      recommendations['recommended']!.addAll([
        const Color(0xFFFFB6C1), // Light Pink
        const Color(0xFF98FB98), // Pale Green
        const Color(0xFFE6E6FA), // Lavender
      ]);
    }

    return recommendations;
  }

  double _calculateConfidence(List<Map<String, int>> skinPixels) {
    if (skinPixels.isEmpty) return 0.0;

    // Calculate confidence based on number of skin pixels detected
    // and their color consistency
    final pixelCount = skinPixels.length;
    final baseConfidence = math.min(1.0, pixelCount / 100.0);

    // Calculate color variance to assess consistency
    if (pixelCount < 10) return baseConfidence;

    final avgColor = _calculateAverageColor(skinPixels);
    double variance = 0.0;

    for (final pixel in skinPixels) {
      final rDiff = (pixel['r']! - avgColor['r']!).abs();
      final gDiff = (pixel['g']! - avgColor['g']!).abs();
      final bDiff = (pixel['b']! - avgColor['b']!).abs();
      variance += (rDiff + gDiff + bDiff) / 3;
    }

    variance /= pixelCount;
    final consistencyScore = math.max(0.0, 1.0 - (variance / 100.0));

    return (baseConfidence + consistencyScore) / 2;
  }

  void dispose() {
    _faceDetector.close();
  }
}
