// screens/skin_analysis_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../services/color_analysis_service.dart';
import 'clothing_suggestions_screen.dart';

class SkinAnalysisScreen extends StatefulWidget {
  final String imagePath;

  const SkinAnalysisScreen({super.key, required this.imagePath});

  @override
  _SkinAnalysisScreenState createState() => _SkinAnalysisScreenState();
}

class _SkinAnalysisScreenState extends State<SkinAnalysisScreen>
    with TickerProviderStateMixin {
  bool _isAnalyzing = true;
  String _skinTone = '';
  String _skinType = '';
  List<Color> _recommendedColors = [];
  List<Color> _avoidColors = [];
  late AnimationController _progressController;
  late AnimationController _resultController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _resultController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _analyzeImage();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    _progressController.forward();
    
    // Simulate AI analysis
    await Future.delayed(Duration(seconds: 3));
    
    // Mock analysis results (In real app, this would call actual AI service)
    final analysisResult = ColorAnalysisService.analyzeSkinTone(widget.imagePath);
    
    setState(() {
      _isAnalyzing = false;
      _skinTone = analysisResult['skinTone'];
      _skinType = analysisResult['skinType'];
      _recommendedColors = analysisResult['recommendedColors'];
      _avoidColors = analysisResult['avoidColors'];
    });
    
    _resultController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
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
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipOval(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 40),
        Text(
          'Analyzing your skin tone...',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressController.value,
                backgroundColor: Colors.white30,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return Text(
              '${(_progressController.value * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white70,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return FadeTransition(
      opacity: _resultController,
      child: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
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
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analysis Complete!',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Skin Tone: $_skinTone',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Type: $_skinType',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Colors',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recommendedColors.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: _recommendedColors[index],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Colors to Avoid',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _avoidColors.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: _avoidColors[index],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClothingSuggestionsScreen(
                                skinTone: _skinTone,
                                recommendedColors: _recommendedColors,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'View Clothing Suggestions',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}