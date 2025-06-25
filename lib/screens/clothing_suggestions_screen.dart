import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClothingSuggestionsScreen extends StatelessWidget {
  final String skinTone;
  final List<Color> recommendedColors;

  const ClothingSuggestionsScreen({super.key, 
    required this.skinTone,
    required this.recommendedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Clothing Suggestions',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Color(0xFF667eea),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Best colors for $skinTone skin tone:',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: recommendedColors
                  .map((color) => Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 32),
            Text(
              'Try to pick clothes in these colors for the best look!',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}