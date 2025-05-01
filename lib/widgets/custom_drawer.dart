import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/my_account_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/basket_screen.dart';
import '../screens/terms_and_conditions_screen.dart';
import '../screens/contact_us_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const SizedBox(
            height: 56,
          ),
          Image.asset(
            "./assets/images/logo.png",
            fit: BoxFit.contain,
            height: 60,
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child: Text(
              "JINGOLA INDIA",
              textScaler: TextScaler.linear(1),
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 22.0),
            child: ListTile(
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(HomeScreen.routeName);
              },
              leading: const Icon(
                Icons.home,
                color: Colors.grey,
              ),
              title: Text(
                "Home",
                textScaler: TextScaler.linear(1),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary, fontSize: 18),
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(MyAccountScreen.routeName);
            },
            leading: const Icon(
              Icons.account_circle,
              color: Colors.grey,
            ),
            title: Text(
              "My Account",
              textScaler: TextScaler.linear(1),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary, fontSize: 18),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
            leading: const Icon(
              Icons.shopping_bag,
              color: Colors.grey,
            ),
            title: Text(
              "My Orders",
              textScaler: TextScaler.linear(1),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary, fontSize: 18),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                BasketScreen.routeName,
                arguments: false,
              );
            },
            leading: const Icon(
              Icons.shopping_cart,
              color: Colors.grey,
            ),
            title: Text(
              "My Basket",
              textScaler: TextScaler.linear(1),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary, fontSize: 18),
            ),
          ),
          const Divider(
            thickness: 0,
            color: Colors.grey,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ContactUsScreen.routeName);
            },
            leading: const Icon(
              Icons.contact_support,
              color: Colors.grey,
            ),
            title: Text(
              "Contact Us",
              textScaler: TextScaler.linear(1),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary, fontSize: 18),
            ),
          ),
          const Divider(
            thickness: 0,
            color: Colors.grey,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(TermsScreen.routeName);
            },
            leading: const Icon(
              Icons.rule,
              color: Colors.grey,
            ),
            title: Text(
              "Terms and Conditions",
              textScaler: TextScaler.linear(1),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary, fontSize: 18),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0,
          ),
          const Spacer(),
          const Divider(
            color: Colors.grey,
          ),
          ListTile(
            onTap: () async {
              await FirebaseAuth.instance.signOut().then(
                (_) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AuthScreen.routeName,
                    (route) => false,
                  );
                },
              );
            },
            leading: const Icon(
              Icons.logout,
              color: Colors.grey,
            ),
            title: Text(
              "Logout",
              textScaler: TextScaler.linear(1),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
