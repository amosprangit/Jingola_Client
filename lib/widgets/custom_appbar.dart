import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jingola_client/screens/auth_screen.dart';
import 'package:jingola_client/screens/home_screen.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  // const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  final VoidCallback? onNotificationPressed;

  const CustomAppBar({
    super.key,
    this.onNotificationPressed,
  });
  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<String> name;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  Future<String> getName() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    if (FirebaseAuth.instance.currentUser != null) {
      HomeScreen();
    } else {
      // Redirect to login
      AuthScreen();
    }
    return "Welcome, ${doc["name"]}";
  }

  @override
  void initState() {
    super.initState();
    name = getName();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: name,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            elevation: 4,
            title: Text(
              "Welcome",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                  ),
            ),
          );
        }
        return AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              snapshot.data!,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontSize: 18, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
