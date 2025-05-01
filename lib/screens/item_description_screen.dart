import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/item_model.dart';
import 'basket_screen.dart';
import '../functions/other_functions.dart';

class ItemDescriptionScreen extends StatefulWidget {
  final Item item;
  static const routeName = "/item-description";
  const ItemDescriptionScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemDescriptionScreen> createState() => _ItemDescriptionScreenState();
}

class _ItemDescriptionScreenState extends State<ItemDescriptionScreen> {
  bool isAdding = false;
  bool isRemoving = false;
  int itemQuantity = 0;
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> setItemQuantity() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    final String? val = doc["basket"]["basketItems"][widget.item.name];
    if (val != null) {
      setState(() {
        itemQuantity = int.parse(val);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setItemQuantity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      extendBody: false,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  BasketScreen.routeName,
                  arguments: true,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: Size(350, 80)
              ),
              child: const Text(
                "Basket",
                textScaler: TextScaler.linear(1),
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        onPressed: () {
          Navigator.of(context).pop(itemQuantity);
        },
        tooltip: "Back to all items",
        child: const Icon(
          Icons.arrow_back,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(40)),
                image: DecorationImage(
                  image: NetworkImage(
                    widget.item.imageUrl,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.item.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        widget.item.isVeg ? "Veg" : "Non-veg",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color:
                                widget.item.isVeg ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w800),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (isAdding || isRemoving)
                    const CircularProgressIndicator.adaptive(),
                  if (!isAdding && !isRemoving)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: widget.item.instock
                              ? () async {
                                  if (itemQuantity > 0) {
                                    setState(() {
                                      isRemoving = true;
                                      itemQuantity--;
                                    });
                                    await OtherFunctions.removeFromBasket(
                                      itemName: widget.item.name,
                                      itemQuantity: itemQuantity,
                                      price: widget.item.price,
                                    ).then(
                                      (_) {
                                        setState(() {
                                          isRemoving = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Item removed from basket",
                                              textScaler: TextScaler.linear(1),
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Cannot remove items which are not in basket",
                                          textScaler: TextScaler.linear(1),
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: Icon(
                            Icons.do_not_disturb_on,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          itemQuantity.toString(),
                          textScaler: TextScaler.linear(1),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        IconButton(
                          onPressed: widget.item.instock
                              ? () async {
                                  setState(() {
                                    isAdding = true;
                                    itemQuantity++;
                                  });
                                  await OtherFunctions.addToBasket(
                                    itemName: widget.item.name,
                                    itemQuantity: itemQuantity,
                                    price: widget.item.price,
                                  ).then(
                                    (_) {
                                      setState(() {
                                        isAdding = false;
                                      });
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Item added to basket",
                                            textScaler: TextScaler.linear(1),
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  );
                                }
                              : null,
                          icon: Icon(
                            Icons.add_circle,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "Rs ${widget.item.price}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Product Details",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        widget.item.description,
                        textScaler: TextScaler.linear(1),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 30,
                right: 30,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Availability",
                    textScaler: TextScaler.linear(1),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    widget.item.instock ? "Available" : "Not Available",
                    textScaler: TextScaler.linear(1),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color:
                              widget.item.instock ? Colors.green : Colors.red,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}