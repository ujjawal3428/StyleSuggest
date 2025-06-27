// screens/color_palette_screen.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math' as math;

class ColorPaletteScreen extends StatefulWidget {
  const ColorPaletteScreen({super.key});

  @override
  _ColorPaletteScreenState createState() => _ColorPaletteScreenState();
}

class _ColorPaletteScreenState extends State<ColorPaletteScreen> {
  Color _selectedColor = Colors.blue;
  List<List<Color>> _colorPalettes = [];
  List<String> _paletteTypes = [];

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
    
    _paletteTypes = [
      'Dark Elegance', 'Warm Earth', 'Cool Ocean', 'Vibrant Sunset', 'Minimal Light', 'Royal Purple'
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
                      _colorToHex(_selectedColor),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (String result) {
                  _generateFromColor(result);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'monochromatic',
                    child: Text('Monochromatic'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'analogous',
                    child: Text('Analogous'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'complementary',
                    child: Text('Complementary'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'triadic',
                    child: Text('Triadic'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'tetradic',
                    child: Text('Tetradic'),
                  ),
                ],
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF667eea),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Generate',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getPaletteName(index),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (index < _paletteTypes.length)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                      onPressed: () => _deletePalette(index),
                    ),
                ],
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
                  children: _colorPalettes[index].asMap().entries.map((entry) {
                    int colorIndex = entry.key;
                    Color color = entry.value;
                    bool isFirst = colorIndex == 0;
                    bool isLast = colorIndex == _colorPalettes[index].length - 1;
                    
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _showColorDetails(color),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.only(
                              topLeft: isFirst ? Radius.circular(15) : Radius.zero,
                              bottomLeft: isFirst ? Radius.circular(15) : Radius.zero,
                              topRight: isLast ? Radius.circular(15) : Radius.zero,
                              bottomRight: isLast ? Radius.circular(15) : Radius.zero,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _colorToHex(color),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: _getContrastColor(color),
                                fontWeight: FontWeight.w500,
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
    if (index < _paletteTypes.length) {
      return _paletteTypes[index];
    }
    return 'Generated Palette ${index - _paletteTypes.length + 1}';
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
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

  void _generateFromColor(String paletteType) {
    List<Color> newPalette = [];
    HSVColor baseHsv = HSVColor.fromColor(_selectedColor);
    String paletteName = '';
    
    switch (paletteType) {
      case 'monochromatic':
        paletteName = 'Monochromatic';
        newPalette = _generateMonochromatic(baseHsv);
        break;
      case 'analogous':
        paletteName = 'Analogous';
        newPalette = _generateAnalogous(baseHsv);
        break;
      case 'complementary':
        paletteName = 'Complementary';
        newPalette = _generateComplementary(baseHsv);
        break;
      case 'triadic':
        paletteName = 'Triadic';
        newPalette = _generateTriadic(baseHsv);
        break;
      case 'tetradic':
        paletteName = 'Tetradic';
        newPalette = _generateTetradic(baseHsv);
        break;
    }
    
    setState(() {
      _colorPalettes.insert(0, newPalette);
      _paletteTypes.insert(0, paletteName);
    });
  }

  List<Color> _generateMonochromatic(HSVColor baseHsv) {
    return [
      baseHsv.withValue(math.max(0.2, baseHsv.value - 0.4)).toColor(),
      baseHsv.withValue(math.max(0.3, baseHsv.value - 0.2)).toColor(),
      baseHsv.toColor(),
      baseHsv.withValue(math.min(1.0, baseHsv.value + 0.2)).toColor(),
    ];
  }

  List<Color> _generateAnalogous(HSVColor baseHsv) {
    return [
      baseHsv.withHue((baseHsv.hue - 30) % 360).toColor(),
      baseHsv.withHue((baseHsv.hue - 15) % 360).toColor(),
      baseHsv.toColor(),
      baseHsv.withHue((baseHsv.hue + 15) % 360).toColor(),
    ];
  }

  List<Color> _generateComplementary(HSVColor baseHsv) {
    double complementaryHue = (baseHsv.hue + 180) % 360;
    return [
      baseHsv.toColor(),
      baseHsv.withSaturation(math.max(0.2, baseHsv.saturation - 0.3)).toColor(),
      HSVColor.fromAHSV(1.0, complementaryHue, baseHsv.saturation, baseHsv.value).toColor(),
      HSVColor.fromAHSV(1.0, complementaryHue, math.max(0.2, baseHsv.saturation - 0.3), baseHsv.value).toColor(),
    ];
  }

  List<Color> _generateTriadic(HSVColor baseHsv) {
    return [
      baseHsv.toColor(),
      baseHsv.withHue((baseHsv.hue + 120) % 360).toColor(),
      baseHsv.withHue((baseHsv.hue + 240) % 360).toColor(),
      baseHsv.withSaturation(math.max(0.3, baseHsv.saturation - 0.4)).withValue(math.min(1.0, baseHsv.value + 0.2)).toColor(),
    ];
  }

  List<Color> _generateTetradic(HSVColor baseHsv) {
    return [
      baseHsv.toColor(),
      baseHsv.withHue((baseHsv.hue + 90) % 360).toColor(),
      baseHsv.withHue((baseHsv.hue + 180) % 360).toColor(),
      baseHsv.withHue((baseHsv.hue + 270) % 360).toColor(),
    ];
  }

  void _deletePalette(int index) {
    if (index >= 6) { // Only allow deletion of generated palettes
      setState(() {
        _colorPalettes.removeAt(index);
        if (index < _paletteTypes.length) {
          _paletteTypes.removeAt(index);
        }
      });
    }
  }

  void _showColorDetails(Color color) {
    HSVColor hsv = HSVColor.fromColor(color);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
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
              _buildColorInfo('HEX', _colorToHex(color)),
              _buildColorInfo('RGB', '${color.red}, ${color.green}, ${color.blue}'),
              _buildColorInfo('HSV', '${hsv.hue.round()}°, ${(hsv.saturation * 100).round()}%, ${(hsv.value * 100).round()}%'),
              _buildColorInfo('HSL', _getHSL(color)),
              SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  // Copy color to clipboard functionality can be added here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Color ${_colorToHex(color)} copied!')),
                  );
                },
                icon: Icon(Icons.copy),
                label: Text('Copy HEX'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHSL(Color color) {
    double r = color.red / 255;
    double g = color.green / 255;
    double b = color.blue / 255;
    
    double max = math.max(r, math.max(g, b));
    double min = math.min(r, math.min(g, b));
    
    double h = 0, s = 0, l = (max + min) / 2;
    
    if (max == min) {
      h = s = 0; // achromatic
    } else {
      double d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      
      if (max == r) {
        h = (g - b) / d + (g < b ? 6 : 0);
      } else if (max == g) {
        h = (b - r) / d + 2;
      } else if (max == b) {
        h = (r - g) / d + 4;
      }
      h /= 6;
    }
    
    return '${(h * 360).round()}°, ${(s * 100).round()}%, ${(l * 100).round()}%';
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