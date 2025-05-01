import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String description;
  final String quantity;
  final bool isVeg;
  final bool instock;

  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.quantity,
    required this.isVeg,
    required this.instock,
    this.imageUrl = "",
  });

  factory Item.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?; // Ensure safe access

    return Item(
      id: snapshot.id,
      name: data?["name"] ?? "Unknown",
      category: data?["category"] ?? "Uncategorized",
      price: double.tryParse(data?["price"].toString() ?? "0.0") ??
          0.0, // Handle price parsing
      imageUrl: data?["imageUrl"] ?? "", // Default to empty if missing
      description: data?["description"] ?? "No description available",
      isVeg: data?["isVeg"] ?? false, // Default to false
      instock: data?["in stock"] ?? false, // Default to false
      quantity: data?["quantity"]?.toString() ?? '0', // ✅ Safely fetch quantity
    );
  }
}
