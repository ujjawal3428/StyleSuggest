// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'camera_screen.dart';
import 'color_palette_screen.dart';
import 'admin_panel_screen.dart';
import 'wardrobe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _screens = [
    HomeTab(),
    ColorPaletteScreen(),
    WardrobeScreen(),
    AdminPanelScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea).withValues(alpha : 0.9),
              Color(0xFF764ba2).withValues(alpha : 0.9),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha : 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SizedBox(
              height: 70,
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withValues(alpha : 0.6),
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: [
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.home_rounded, 0),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.palette_rounded, 1),
                    label: 'Colors',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.checkroom_rounded, 2),
                    label: 'Wardrobe',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.admin_panel_settings_rounded, 3),
                    label: 'Admin',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(_selectedIndex == index ? 8 : 4),
      decoration: BoxDecoration(
        color: _selectedIndex == index 
            ? Colors.white.withValues(alpha : 0.2) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 24),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          0.8 + index * 0.05,
          curve: Curves.elasticOut,
        ),
      ));
    });

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF8B5FBF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha : 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha : 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Welcome back! ✨',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha : 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'StyleSuggest',
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Discover your perfect colors with AI-powered styling',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha : 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      SlideTransition(
                        position: _slideAnimations[0],
                        child: _buildGlassFeatureCard(
                          context,
                          'AI Camera',
                          Icons.camera_alt_rounded,
                          [Color(0xFF4CAF50), Color(0xFF45A049)],
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CameraScreen()),
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: _slideAnimations[1],
                        child: _buildGlassFeatureCard(
                          context,
                          'Color Magic',
                          Icons.auto_awesome_rounded,
                          [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ColorPaletteScreen()),
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: _slideAnimations[2],
                        child: _buildGlassFeatureCard(
                          context,
                          'Smart Wardrobe',
                          Icons.checkroom_rounded,
                          [Color(0xFF9C27B0), Color(0xFF8E24AA)],
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WardrobeScreen()),
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: _slideAnimations[3],
                        child: _buildGlassFeatureCard(
                          context,
                          'Style Insights',
                          Icons.insights_rounded,
                          [Color(0xFF2196F3), Color(0xFF1976D2)],
                          () => _showAdvancedStyleTips(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha : 0.15),
              Colors.white.withValues(alpha : 0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha : 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAdvancedStyleTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF8F9FA),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Style Insights',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildAdvancedTipCard(
                            'Skin Tone Science',
                            'Understanding warm, cool, and neutral undertones for perfect color matching',
                            Icons.face_rounded,
                            [Color(0xFFFF6B6B), Color(0xFFFF8E85)],
                          ),
                          _buildAdvancedTipCard(
                            'Color Psychology',
                            'How different colors influence mood and perception in fashion',
                            Icons.psychology_rounded,
                            [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                          ),
                          _buildAdvancedTipCard(
                            'Seasonal Styling',
                            'Adapt your color palette to complement seasonal trends',
                            Icons.wb_sunny_rounded,
                            [Color(0xFFFFB347), Color(0xFFFF8C00)],
                          ),
                          _buildAdvancedTipCard(
                            'Advanced Combinations',
                            'Master triadic, tetradic, and analogous color schemes',
                            Icons.tune_rounded,
                            [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                          ),
                        ],
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

  Widget _buildAdvancedTipCard(
    String title,
    String description,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFE8EAF6).withValues(alpha : 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}