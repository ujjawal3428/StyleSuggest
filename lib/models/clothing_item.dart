class ClothingItem {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final bool isFavorite;

  ClothingItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    this.isFavorite = false,
  });
}