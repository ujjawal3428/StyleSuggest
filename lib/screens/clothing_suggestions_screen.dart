// screens/clothing_suggestions_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_closet/screens/color_analysis_result.dart';
import '../services/color_analysis_service.dart';

class ClothingSuggestionsScreen extends StatefulWidget {
  final ColorAnalysisResult analysisResult;

  const ClothingSuggestionsScreen({
    super.key,
    required this.analysisResult,
  });

  @override
  State<ClothingSuggestionsScreen> createState() =>
      _ClothingSuggestionsScreenState();
}

class _ClothingSuggestionsScreenState extends State<ClothingSuggestionsScreen>
    with TickerProviderStateMixin {
  List<Map<String, String>> suggestions = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  late TabController _tabController;
  late ColorAnalysisService _colorService;

  // Replace with your actual Gemini API key
  final String apiKey = 'YOUR_GEMINI_API_KEY';
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  final List<String> categories = [
    'All',
    'Casual',
    'Business',
    'Evening',
    'Seasonal'
  ];

  @override
  void initState() {
    super.initState();
    _colorService = ColorAnalysisService();
    _tabController = TabController(length: categories.length, vsync: this);
    fetchSuggestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _colorService.dispose();
    super.dispose();
  }

  String _colorListToHex(List<Color> colors) {
    return colors
        .map((c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}')
        .join(', ');
  }

  Future<void> fetchSuggestions() async {
    try {
      final colorHex = _colorListToHex(widget.analysisResult.recommendedColors);
      final avoidColorHex = _colorListToHex(widget.analysisResult.avoidColors);
      final skinToneDescription = _colorService.getSkinToneDescription(
        widget.analysisResult.skinTone,
        widget.analysisResult.undertone,
      );

      final prompt = '''
You are a professional fashion stylist. Based on the following skin tone analysis, provide 12 specific outfit suggestions organized by category:

Skin Analysis:
- Skin Tone: ${widget.analysisResult.skinTone}
- Undertone: ${widget.analysisResult.undertone} 
- Skin Type: ${widget.analysisResult.skinType}
- Description: $skinToneDescription
- Recommended Colors: $colorHex
- Colors to Avoid: $avoidColorHex

Please provide 3 outfit suggestions for each category:
1. CASUAL (everyday, weekend, comfortable)
2. BUSINESS (work, professional, meetings)
3. EVENING (dinner, parties, special occasions)
4. SEASONAL (current season appropriate)

For each outfit, provide:
- Category: [CASUAL/BUSINESS/EVENING/SEASONAL]
- Title: Brief descriptive name (e.g., "Navy Blazer & Coral Blouse")
- Description: Detailed outfit description with specific pieces and colors
- Link: A realistic shopping link (use major retailers like Amazon, Nordstrom, Zara, H&M)

Format each suggestion exactly like this:
Category: CASUAL
Title: [Outfit Name]
Description: [Detailed description]
Link: https://[shopping-link]

Make sure to use the recommended colors and avoid the colors that don't suit this skin tone.
''';

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text =
            data['candidates'][0]['content']['parts'][0]['text'] ?? '';

        final List<Map<String, String>> parsed = _parseGeminiResponse(text);

        setState(() {
          suggestions = parsed;
          isLoading = false;
        });
      } else {
        print('Error: ${response.body}');
        setState(() {
          suggestions = _getFallbackSuggestions();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {
        suggestions = _getFallbackSuggestions();
        isLoading = false;
      });
    }
  }

  List<Map<String, String>> _parseGeminiResponse(String text) {
    final List<Map<String, String>> parsed = [];
    final lines = text.split('\n');
    
    String? currentCategory;
    String? currentTitle;
    String? currentDescription;
    String? currentLink;

    for (String line in lines) {
      line = line.trim();
      
      if (line.startsWith('Category:')) {
        // Save previous outfit if complete
        if (currentCategory != null && currentTitle != null) {
          parsed.add({
            'category': currentCategory,
            'title': currentTitle,
            'description': currentDescription ?? '',
            'link': currentLink ?? 'https://www.google.com/search?q=clothing+${currentTitle.replaceAll(' ', '+')}',
          });
        }
        
        currentCategory = line.substring(9).trim();
        currentTitle = null;
        currentDescription = null;
        currentLink = null;
      } else if (line.startsWith('Title:')) {
        currentTitle = line.substring(6).trim();
      } else if (line.startsWith('Description:')) {
        currentDescription = line.substring(12).trim();
      } else if (line.startsWith('Link:')) {
        currentLink = line.substring(5).trim();
      }
    }
    
    // Add the last outfit
    if (currentCategory != null && currentTitle != null) {
      parsed.add({
        'category': currentCategory,
        'title': currentTitle,
        'description': currentDescription ?? '',
        'link': currentLink ?? 'https://www.google.com/search?q=clothing+${currentTitle.replaceAll(' ', '+')}',
      });
    }

    return parsed;
  }

  List<Map<String, String>> _getFallbackSuggestions() {
    final colorHex = _colorListToHex(widget.analysisResult.recommendedColors);
    
    return [
      {
        'category': 'CASUAL',
        'title': 'Denim & Soft Tee Combo',
        'description': 'Classic blue jeans with a soft cotton tee in one of your recommended colors ($colorHex)',
        'link': 'https://www.amazon.com/s?k=casual+outfit+women',
      },
      {
        'category': 'BUSINESS',
        'title': 'Professional Blazer Set',
        'description': 'Tailored blazer with coordinating trousers in colors that complement your ${widget.analysisResult.undertone} undertone',
        'link': 'https://www.nordstrom.com/browse/women/clothing/suits-separates',
      },
      {
        'category': 'EVENING',
        'title': 'Elegant Dress',
        'description': 'Sophisticated dress in a color that enhances your ${widget.analysisResult.skinTone} skin tone',
        'link': 'https://www.zara.com/us/en/woman/dresses-l1066.html',
      },
    ];
  }

  List<Map<String, String>> getFilteredSuggestions() {
    if (selectedCategory == 'All') {
      return suggestions;
    }
    return suggestions
        .where((suggestion) =>
            suggestion['category']?.toUpperCase() == selectedCategory.toUpperCase())
        .toList();
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to Google search
        final searchQuery = url.contains('q=') ? url : 'https://www.google.com/search?q=clothing+shopping';
        final fallbackUri = Uri.parse(searchQuery);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Style Recommendations',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading ? _buildLoadingView() : _buildContentView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
          const SizedBox(height: 20),
          Text(
            'Generating personalized style recommendations...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return Column(
      children: [
        _buildSkinToneHeader(),
        _buildCategoryTabs(),
        Expanded(child: _buildSuggestionsList()),
      ],
    );
  }

  Widget _buildSkinToneHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Color Palette',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _colorService.getSkinToneDescription(
              widget.analysisResult.skinTone,
              widget.analysisResult.undertone,
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildColorSection('Best Colors', widget.analysisResult.recommendedColors, true),
              const SizedBox(width: 20),
              _buildColorSection('Avoid', widget.analysisResult.avoidColors, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(String title, List<Color> colors, bool isRecommended) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: colors.take(4).map((color) => Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: !isRecommended
                ? const Icon(Icons.close, size: 12, color: Colors.white)
                : null,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF667eea),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF667eea),
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal),
        onTap: (index) {
          setState(() {
            selectedCategory = categories[index];
          });
        },
        tabs: categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    final filteredSuggestions = getFilteredSuggestions();
    
    if (filteredSuggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No suggestions available for this category',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = filteredSuggestions[index];
        return _buildSuggestionCard(suggestion);
      },
    );
  }

  Widget _buildSuggestionCard(Map<String, String> suggestion) {
    final category = suggestion['category'] ?? 'GENERAL';
    final title = suggestion['title'] ?? 'Outfit Suggestion';
    final description = suggestion['description'] ?? 'No description available';
    final link = suggestion['link'] ?? '';

    Color categoryColor;
    IconData categoryIcon;

    switch (category.toUpperCase()) {
      case 'CASUAL':
        categoryColor = Colors.blue;
        categoryIcon = Icons.weekend;
        break;
      case 'BUSINESS':
        categoryColor = Colors.purple;
        categoryIcon = Icons.business_center;
        break;
      case 'EVENING':
        categoryColor = Colors.pink;
        categoryIcon = Icons.nightlife;
        break;
            case 'SEASONAL':
        categoryColor = Colors.orange;
        categoryIcon = Icons.wb_sunny;
        break;
      default:
        categoryColor = Colors.grey;
        categoryIcon = Icons.style;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () => _launchURL(link),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: categoryColor.withOpacity(0.1),
                child: Icon(categoryIcon, color: categoryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shop Now',
                      style: GoogleFonts.poppins(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
