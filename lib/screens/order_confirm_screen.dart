import 'package:flutter/material.dart';

class OrderConfirmScreen extends StatelessWidget {
  static const routeName = "/order-confirm";
  const OrderConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
          ),
          Image.asset("./assets/images/Ordered.png",),
          SizedBox(
            height: 30,
          ),
          Text(
            "Your Order has been accepted",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Your items has been placed and will be delivered soon",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Payment will cash or UPI on delivery",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  elevation: WidgetStatePropertyAll(4),
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primary),
                  minimumSize: WidgetStatePropertyAll(Size(350, 50))),
              onPressed: () {
                Navigator.pushNamed(context, "/home");
              },
              child: Text(
                "Back To home",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
    ));
  }
}
