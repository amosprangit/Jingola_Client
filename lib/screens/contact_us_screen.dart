import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';

class ContactUsScreen extends StatelessWidget {
  static const routeName = "/contact-us";
  const ContactUsScreen({super.key});

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
          "Contact Us",
          textScaler: TextScaler.linear(1),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "We are here to help you with any issues you face while using our app.",
                textScaler: TextScaler.linear(1),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                "Email your queries at:",
                textScaler: TextScaler.linear(1),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "jingolaofficial@gmail.com",
                textScaler: TextScaler.linear(1),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "OR",
                  textScaler: TextScaler.linear(1),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Call us at: 9982688901 (9 AM - 6 PM)",
                textScaler: TextScaler.linear(1),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Image.asset(
                  "assets/images/logo.png",
                ),
              ),
              Center(
                child: Image.asset(
                  "assets/images/name.png",
                  // width: 200,
                  // fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
