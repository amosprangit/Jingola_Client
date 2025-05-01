import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';

class TermsScreen extends StatelessWidget {
  static const routeName = "/terms";
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
        title: Text(
          "Terms and Conditions",
          textScaler: TextScaler.linear(1),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("terms")
              .doc("tnc")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    snapshot.data!.data()!.values.toList()[index],
                    textScaler: TextScaler.linear(1),
                    softWrap: true,
                    style: TextStyle(fontSize: 20),
                  ),
                );
              },
              itemCount: snapshot.data!.data()!.length,
            );
          },
        ),
      ),
    );
  }
}
