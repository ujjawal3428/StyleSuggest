import '../models/clothing_item.dart';

class WardrobeService {
  static Future<List<ClothingItem>> getWardrobeItems() async {
    // Mock data for demonstration
    await Future.delayed(Duration(seconds: 1));
    return [
      ClothingItem(
        id: '1',
        name: 'Blue T-Shirt',
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Tops',
        isFavorite: true,
      ),
      ClothingItem(
        id: '2',
        name: 'Black Jeans',
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Bottoms',
      ),
      ClothingItem(
        id: '3',
        name: 'Red Dress',
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Dresses',
      ),
      ClothingItem(
        id: '4',
        name: 'Denim Jacket',
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Outerwear',
        isFavorite: true,
      ),
      ClothingItem(
        id: '5',
        name: 'Scarf',
        imageUrl: 'https://via.placeholder.com/150',
        category: 'Accessories',
      ),
    ];
  }
}