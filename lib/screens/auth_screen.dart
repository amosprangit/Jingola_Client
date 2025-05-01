import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'enter_otp_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = "/auth";
  AuthScreen({super.key});

  final User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return user != null
        ? const HomeScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surfaceBright,
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("./assets/images/auth_img.png"),
                      alignment: Alignment.topRight,
                      fit: BoxFit.contain
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Get your groceries with Jingola", style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24
                              // letterSpacing: 26
                            ),),
                              const SizedBox(
                                height: 25,
                              ),
                            TextFormField(
                              key: const ValueKey("mobile"),
                              autocorrect: true,
                              controller: phoneController,
                              enableSuggestions: true,
                              keyboardType: TextInputType.number,
                              textCapitalization: TextCapitalization.none,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    width: 0.5,
                                    color: Colors.black54,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixText: "+91",
                                prefixIcon: Image.asset("assets/images/flag.png"),
                                labelText: "Phone number",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter phone number";
                                } else if (value.trim().length != 10) {
                                  return "Phone number must be exactly 10 digits";
                                }
                                return null;
                              },
                              maxLength: 10,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return EnterOTPScreen(
                                        phoneNumber:
                                            "+91${phoneController.text.trim()}",
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Theme.of(context).colorScheme.primary
                                ),
                                minimumSize: WidgetStatePropertyAll(
                                  const Size(200, 50),
                                )
                              ),
                              child: const Text(
                                "Continue",
                                textScaler: TextScaler.linear(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}