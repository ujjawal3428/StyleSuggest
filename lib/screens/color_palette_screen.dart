// screens/color_palette_screen.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPaletteScreen extends StatefulWidget {
  const ColorPaletteScreen({super.key});

  @override
  _ColorPaletteScreenState createState() => _ColorPaletteScreenState();
}

class _ColorPaletteScreenState extends State<ColorPaletteScreen> {
  Color _selectedColor = Colors.blue;
  List<List<Color>> _colorPalettes = [];

  @override
  void initState() {
    super.initState();
    _generatePalettes();
  }

  void _generatePalettes() {
    _colorPalettes = [
      [Color(0xFF2E3440), Color(0xFF3B4252), Color(0xFF434C5E), Color(0xFF4C566A)], // Dark
      [Color(0xFFD08770), Color(0xFFEBCB8B), Color(0xFFA3BE8C), Color(0xFFB48EAD)], // Warm
      [Color(0xFF88C0D0), Color(0xFF81A1C1), Color(0xFF5E81AC), Color(0xFF8FBCBB)], // Cool
      [Color(0xFFBF616A), Color(0xFFD08770), Color(0xFFEBCB8B), Color(0xFFA3BE8C)], // Vibrant
      [Color(0xFFECEFF4), Color(0xFFE5E9F0), Color(0xFFD8DEE9), Color(0xFF4C566A)], // Light
      [Color(0xFF5D4E75), Color(0xFF7B68EE), Color(0xFF9370DB), Color(0xFFBA55D3)], // Purple
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      _buildColorPicker(),
                      Expanded(child: _buildPaletteGrid()),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Palettes',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Discover perfect color combinations',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Generator',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showColorPicker(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Color',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    Text(
                      '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _generateFromColor,
                child: Text('Generate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildPaletteGrid() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _colorPalettes.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getPaletteName(index),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: _colorPalettes[index].map((color) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _showColorDetails(color),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: _getContrastColor(color),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPaletteName(int index) {
    const names = ['Dark Elegance', 'Warm Earth', 'Cool Ocean', 'Vibrant Sunset', 'Minimal Light', 'Royal Purple'];
    return names[index];
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _generateFromColor() {
    // Generate complementary colors
    List<Color> newPalette = [];
    HSVColor hsv = HSVColor.fromColor(_selectedColor);
    
    newPalette.add(_selectedColor);
    newPalette.add(hsv.withHue((hsv.hue + 30) % 360).toColor());
    newPalette.add(hsv.withHue((hsv.hue + 180) % 360).toColor());
    newPalette.add(hsv.withHue((hsv.hue + 210) % 360).toColor());
    
    setState(() {
      _colorPalettes.insert(0, newPalette);
    });
  }

  void _showColorDetails(Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Color Details',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              _buildColorInfo('HEX', '#${color.value.toRadixString(16).substring(2).toUpperCase()}'),
              _buildColorInfo('RGB', '${color.red}, ${color.green}, ${color.blue}'),
              _buildColorInfo('HSV', '${HSVColor.fromColor(color).hue.round()}°, ${(HSVColor.fromColor(color).saturation * 100).round()}%, ${(HSVColor.fromColor(color).value * 100).round()}%'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}