// screens/skin_analysis_screen.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_closet/screens/color_analysis_result.dart';
import '../services/color_analysis_service.dart';
import 'clothing_suggestions_screen.dart';

class SkinAnalysisScreen extends StatefulWidget {
  final String imagePath;
  const SkinAnalysisScreen({super.key, required this.imagePath});

  @override
  State<SkinAnalysisScreen> createState() => _SkinAnalysisScreenState();
}

class _SkinAnalysisScreenState extends State<SkinAnalysisScreen>
    with TickerProviderStateMixin {
  bool _isAnalyzing = true;
  ColorAnalysisResult? _analysisResult;
  String _currentStep = 'Loading image...';

  late AnimationController _progressController;
  late AnimationController _resultController;
  late ColorAnalysisService _colorService;

  @override
  void initState() {
    super.initState();
    _colorService = ColorAnalysisService();
    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      // Start progress animation
      _progressController.forward();

      // Update progress steps
      setState(() => _currentStep = 'Detecting face...');
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 'Analyzing skin tone...');
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 'Processing colors...');
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 'Generating recommendations...');

      // Perform actual analysis
      final result = await _colorService.analyzeSkinTone(widget.imagePath);

      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _isAnalyzing = false;
        _analysisResult = result;
        _currentStep = 'Analysis complete!';
      });

      _resultController.forward();
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _currentStep = 'Analysis failed: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _resultController.dispose();
    _colorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isAnalyzing ? _buildAnalyzingView() : _buildResultView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Skin Analysis',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          _currentStep,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 250,
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) => LinearProgressIndicator(
              value: _progressController.value,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) => Text(
            '${(_progressController.value * 100).toInt()}%',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    if (_analysisResult == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 60),
            const SizedBox(height: 20),
            Text(
              _currentStep,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _resultController,
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildResultHeader(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkinToneInfo(),
                    const SizedBox(height: 24),
                    _buildColorRecommendations(),
                    const SizedBox(height: 24),
                    _buildColorsToAvoid(),
                    const SizedBox(height: 24),
                    _buildConfidenceIndicator(),
                  ],
                ),
              ),
            ),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: ClipOval(
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Analysis Complete!",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _colorService.getSkinToneDescription(
                    _analysisResult!.skinTone,
                    _analysisResult!.undertone,
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinToneInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Skin Analysis",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _analysisResult!.skinToneColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Average Skin Color',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _analysisResult!.hexColor,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip('Tone', _analysisResult!.skinTone),
                  const SizedBox(width: 8),
                  _buildInfoChip('Undertone', _analysisResult!.undertone),
                  const SizedBox(width: 8),
                  _buildInfoChip('Type', _analysisResult!.skinType),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.palette, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              "Recommended Colors",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _analysisResult!.recommendedColors
              .map((color) => _buildColorCircle(color, true))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildColorsToAvoid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.block, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              "Colors to Avoid",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _analysisResult!.avoidColors
              .map((color) => _buildColorCircle(color, false))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildColorCircle(Color color, bool isRecommended) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isRecommended ? Colors.green : Colors.red,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: !isRecommended
          ? const Icon(
              Icons.close,
              size: 20,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildConfidenceIndicator() {
    final confidence = _analysisResult!.confidence;
    Color confidenceColor;
    
    if (confidence >= 0.8) {
      confidenceColor = Colors.green;
    } else if (confidence >= 0.6) {
      confidenceColor = Colors.orange;
    } else {
      confidenceColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: confidenceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: confidenceColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: confidenceColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Confidence',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(confidence * 100).toInt()}% - ${_analysisResult!.confidenceDescription}',
                  style: GoogleFonts.poppins(
                    color: confidenceColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClothingSuggestionsScreen(
                      analysisResult: _analysisResult!,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.checkroom, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Get Clothing Suggestions",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_analysisResult!.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Note: ${_analysisResult!.errorMessage}',
                style: GoogleFonts.poppins(
                  color: Colors.orange[700],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}