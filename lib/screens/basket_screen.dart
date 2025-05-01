import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../functions/other_functions.dart';
import '../widgets/basket_item_tile.dart';
import './checkout_screen.dart';

class BasketScreen extends StatefulWidget {
  static const routeName = "/basket";
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<void> load;

  @override
  void initState() {
    super.initState();
    load = OtherFunctions.loadBasket();
  }

  @override
  Widget build(BuildContext context) {
    // final bool button = ModalRoute.of(context)!.settings.arguments as bool;
    return FutureBuilder(
        future: load,
        builder: (context, loadingSnapshot) {
          if (loadingSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              iconTheme: IconThemeData(
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                "Basket",
                textScaler: TextScaler.linear(1.3),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                    ),
              ),
              leading: IconButton(
                onPressed: () {
                  // Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                icon: Icon(
                  Icons.arrow_back,
                ),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceBright,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Basket Items",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(user!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        return FutureBuilder(
                          future:
                              OtherFunctions.getItemsfromItemName(user!.uid),
                          builder: (context, itemsnapshot) {
                            if (itemsnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }
                            return itemsnapshot.data == null
                                ? Container()
                                : itemsnapshot.data!.isEmpty
                                    ? Center(
                                        child: Text(
                                          "No Items in basket",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return BasketItemTile(
                                              item: itemsnapshot.data![index]);
                                        },
                                        itemCount: itemsnapshot.data!.length,
                                      );
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Total",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(user!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 200,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Subtotal",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                      FutureBuilder(
                                        future: OtherFunctions.getSubtotal(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator
                                                .adaptive();
                                          }
                                          return Text(
                                            "₹${snapshot.data!.toStringAsFixed(2)}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Delivery fee",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                      StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("settings")
                                            .doc("App Settings")
                                            .snapshots(),
                                        builder: (context, feeSnapshot) {
                                          if (feeSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container();
                                          }
                                          return Text(
                                            "₹${feeSnapshot.data!.data()!["delivery fees"]}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                      ),
                                      FutureBuilder(
                                        future: OtherFunctions.getTotal(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator
                                                .adaptive();
                                          }
                                          return Text(
                                            "₹${snapshot.data!.toStringAsFixed(2)}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("settings")
                          .doc("App Settings")
                          .snapshots(),
                      builder: (context, feeSnapshot) {
                        if (feeSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator.adaptive();
                        }
                        return ElevatedButton(
                          onPressed: () async {
                            await OtherFunctions.getTotal().then(
                              (value) async {
                                if (value >= double.parse(feeSnapshot.data!.data()!["minimum amount"])) {
                                  // Ensure total is greater than ₹10
                                  bool? confirmCheckout = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Are you sure to proceed?",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                        content: Text(
                                            "You won't be able to come back to edit the cart once you proceed",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text("NO"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text("YES"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmCheckout == true) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      CheckoutScreen.routeName,
                                      (route) => false,
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Minimum total amount must be ₹${feeSnapshot.data!.data()!["minimum amount"]}",
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                            ),
                          ),
                          child: const Text(
                            "Go to Checkout",
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
