// screens/wardrobe_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import '../models/clothing_item.dart';
import '../services/wardrobe_service.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ClothingItem> _allItems = [];
  List<ClothingItem> _filteredItems = [];
  List<ClothingItem> _favoriteItems = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  // Enhanced color scheme
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFFFF6B9D);
  static const Color accentColor = Color(0xFF4ECDC4);
  static const Color backgroundColor = Color(0xFFF8F9FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  final List<String> _categories = [
    'All', 'Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Accessories'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWardrobe();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWardrobe() async {
    setState(() => _isLoading = true);
    
    try {
      final items = await WardrobeService.getWardrobeItems();
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _favoriteItems = items.where((item) => item.isFavorite).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // ignore: avoid_print
      print('Error loading wardrobe: $e');
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredItems = category == 'All' 
          ? _allItems 
          : _allItems.where((item) => item.category == category).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withValues(alpha : 0.1),
              accentColor.withValues(alpha : 0.05),
              backgroundColor,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyWardrobeTab(),
                    _buildOutfitsTab(),
                    _buildFavoritesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha : 0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddItemDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Wardrobe',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_allItems.length} items in your collection',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha : 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.search_rounded, color: textPrimary, size: 24),
              onPressed: () => _showSearchDialog(),
              padding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha : 0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withValues(alpha : 0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha : 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: textSecondary,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('My Items'),
            ),
          ),
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Outfits'),
            ),
          ),
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Favorites'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyWardrobeTab() {
    return Column(
      children: [
        _buildCategoryFilter(),
        SizedBox(height: 16),
        Expanded(
          child: _isLoading 
              ? _buildLoadingGrid()
              : _filteredItems.isEmpty
                  ? _buildEmptyState()
                  : _buildClothingGrid(_filteredItems),
        ),
      ],
    );
  }

  Widget _buildOutfitsTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Your Outfits',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha : 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '6 outfits',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => _buildOutfitCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return _favoriteItems.isEmpty
        ? _buildEmptyFavoritesState()
        : _buildClothingGrid(_favoriteItems);
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () => _filterByCategory(category),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 12, top: 8, bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [primaryColor, primaryColor.withValues(alpha : 0.8)],
                      )
                    : null,
                color: isSelected ? null : cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? primaryColor.withValues(alpha : 0.3)
                        : Colors.black.withValues(alpha : 0.05),
                    blurRadius: isSelected ? 8 : 6,
                    offset: Offset(0, isSelected ? 3 : 2),
                  ),
                ],
              ),
              child: Text(
                category,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClothingGrid(List<ClothingItem> items) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: MasonryGridView.count(
        physics: BouncingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildClothingCard(item, index);
        },
      ),
    );
  }

  Widget _buildClothingCard(ClothingItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha : 0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(item, index),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha : 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: item.isFavorite ? secondaryColor : textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withValues(alpha : 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.category,
                    style: GoogleFonts.inter(
                      color: _getCategoryColor(item.category),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tops': return primaryColor;
      case 'bottoms': return secondaryColor;
      case 'dresses': return accentColor;
      case 'outerwear': return Color(0xFFFF8A65);
      case 'accessories': return Color(0xFF9C27B0);
      default: return textSecondary;
    }
  }

  void _toggleFavorite(ClothingItem item, int index) {
    setState(() {
      final updatedItem = ClothingItem(
        id: item.id,
        name: item.name,
        imageUrl: item.imageUrl,
        category: item.category,
        isFavorite: !item.isFavorite,
      );
      
      // Update in all items
      final allIndex = _allItems.indexWhere((i) => i.id == item.id);
      if (allIndex != -1) {
        _allItems[allIndex] = updatedItem;
      }
      
      // Update in filtered items
      final filteredIndex = _filteredItems.indexWhere((i) => i.id == item.id);
      if (filteredIndex != -1) {
        _filteredItems[filteredIndex] = updatedItem;
      }
      
      // Update favorites list
      _favoriteItems = _allItems.where((i) => i.isFavorite).toList();
    });
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: 6,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 64,
            color: textSecondary.withValues(alpha : 0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try a different category or add some items',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavoritesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: secondaryColor.withValues(alpha : 0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the heart icon to add items to favorites',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard(int index) {
    final colors = [primaryColor, secondaryColor, accentColor, Color(0xFFFF8A65)];
    final color = colors[index % colors.length];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha : 0.8),
            color.withValues(alpha : 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha : 0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'Outfit ${index + 1}',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '3 items',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white.withValues(alpha : 0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add New Item',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Add item functionality coming soon!',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Search',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Search functionality coming soon!',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}