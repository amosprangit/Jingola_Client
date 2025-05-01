import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';
import '../widgets/order_tile.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
        title: Text(
          "Orders",
          textScaler: TextScaler.linear(1),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Your Today's Orders",
                textScaler: TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .where(
                      "userId",
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .where(
                      "date",
                      isEqualTo:
                          "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  return snapshot.data!.docs.isEmpty
                      ? Center(
                          child: Text(
                            "No orders done today yet!",
                            textScaler: TextScaler.linear(1),
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return OrderTile(
                              order: snapshot.data!.docs[index].data(),
                            );
                          },
                          itemCount: snapshot.data!.docs.length,
                        );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Your All Orders",
                textScaler: TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .where(
                      "userId",
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  return snapshot.data!.docs.isEmpty
                      ? Center(
                          child: Text(
                            "No past orders yet!",
                            textScaler: TextScaler.linear(1),
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return OrderTile(
                              order: snapshot.data!.docs[index].data(),
                            );
                          },
                          itemCount: snapshot.data!.docs.length,
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
