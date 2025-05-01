import 'package:flutter/material.dart';

class GetStarted extends StatelessWidget {
  static const routeName = "/getStarted";
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                "./assets/images/logo.png",
                width: 228,
                height: 242,
              ),
              SizedBox(
                height: 15,
              ),
              Image.asset(
                "./assets/images/name.png",
                width: 100,
                height: 80,
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Welcome to our store",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Get your groceries in as fast as one hour",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/auth');
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.primary
                          ),
                          elevation: WidgetStatePropertyAll(4),
                          minimumSize: WidgetStatePropertyAll(
                            Size(350, 60)
                          )
                        ),
                        child: Text("Get Started",style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600
                        ),))
                  ],
                ),
              )
            ]),
      ),
    ));
  }
}
