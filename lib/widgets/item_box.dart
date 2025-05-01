import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../functions/other_functions.dart';
import '../screens/item_description_screen.dart';
import '../models/item_model.dart';

class ItemBox extends StatefulWidget {
  final Item item;
  final VoidCallback? onAddItem;
  final VoidCallback? onRemoveItem;

  const ItemBox({
    super.key,
    required this.item,
    this.onAddItem,
    this.onRemoveItem,
  });

  @override
  State<ItemBox> createState() => _ItemBoxState();
}

class _ItemBoxState extends State<ItemBox> {
  int itemQuantity = 0;
  bool isAdding = false;
  bool isRemoving = false;
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> setItemQuantity() async {
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final basket = doc.data()?["basket"] as Map<String, dynamic>?;
        final basketItems = basket?["basketItems"] as Map<String, dynamic>?;
        final quantity = basketItems?[widget.item.name] as String?;

        if (quantity != null) {
          setState(() {
            itemQuantity = int.parse(quantity);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch item quantity: $e")),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setItemQuantity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDescriptionScreen(item: widget.item),
          ),
        );
      },
      child: Container(
        width: 160, // Adjust width to match Figma design
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image with fixed size
            SizedBox(
              height: 80,
              child: Image.network(
                widget.item.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Product Name
            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),

            // Quantity and Price Row
            Text(
              widget.item.quantity,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 5),

            // Price & Veg Indicator Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "₹${widget.item.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 22, // Adjust width as per your Figma
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Colors.green, // Change this color based on Figma
                      width: 2, // Border thickness
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: widget.item.isVeg ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            // Out of Stock or Quantity Selector
            widget.item.instock
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Remove Button
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.red),
                        onPressed: itemQuantity > 0 ? removeItem : null,
                      ),

                      // Item Count
                      Text(
                        itemQuantity.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Add Button
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: addItem,
                      ),
                    ],
                  )
                : const Text(
                    "Out of Stock",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBasket(Function updateFunction) async {
    try {
      await updateFunction();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item Updated in Basket.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update basket: $e")),
      );
    } finally {
      setState(() {
        isAdding = false;
        isRemoving = false;
      });
    }
  }

  void addItem() async {
    if (widget.item.instock) {
      setState(() => isAdding = true);
      await _updateBasket(() async {
        itemQuantity++;
        await OtherFunctions.addToBasket(
          itemName: widget.item.name,
          itemQuantity: itemQuantity,
          price: widget.item.price,
        );
        widget.onAddItem?.call();
      });
    }
  }

  void removeItem() async {
    if (itemQuantity > 0) {
      setState(() => isRemoving = true);
      await _updateBasket(() async {
        itemQuantity--;
        await OtherFunctions.removeFromBasket(
          itemName: widget.item.name,
          itemQuantity: itemQuantity,
          price: widget.item.price,
        );
        widget.onRemoveItem?.call();
      });
    }
  }
}
