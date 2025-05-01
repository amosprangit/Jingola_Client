import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';
import 'new_user_screen.dart';

class EnterOTPScreen extends StatefulWidget {
  static const routeName = "enter-otp";
  final String phoneNumber;

  const EnterOTPScreen({super.key, required this.phoneNumber});

  @override
  State<EnterOTPScreen> createState() => _EnterOTPScreenState();
}

class _EnterOTPScreenState extends State<EnterOTPScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController codeController = TextEditingController();
  String verificationId = "";
  bool isLoading = false;
  bool canResendOTP = false;
  int _resendTimeout = 59; 
  late Timer _resendTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _verifyPhone();
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    super.dispose();
  }

  void _startTimer() {
    canResendOTP = false;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimeout <= 0) {
        setState(() {
          canResendOTP = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _resendTimeout--;
        });
      }
    });
  }

  /// **Check if user exists in Firestore**
  Future<void> _checkNewUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final name = doc.get("name");
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeScreen.routeName,
        arguments: name,
        (route) => false,
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        NewUserScreen.routeName,
        (route) => false,
      );
    }
  }

  /// **Verify Phone Number using Firebase**
  Future<void> _verifyPhone() async {
    try {
      setState(() => isLoading = true);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            if (userCredential.user != null) {
              await _checkNewUser();
            }
          } catch (e) {
            _showError("Auto verification failed: $e");
          } finally {
            if (mounted) {
              setState(() => isLoading = false);
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError("Verification failed: ${e.message}");
          if (mounted) {
            setState(() => isLoading = false);
          }
        },
        codeSent: (String vId, int? resendToken) {
          if (mounted) {
            setState(() {
              verificationId = vId;
              isLoading = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (String vId) {
          if (mounted) {
            setState(() {
              verificationId = vId;
              isLoading = false;
            });
          }
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showError("Exception in OTP verification: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// **Resend OTP Functionality**
  Future<void> _resendOTP() async {
    if (!canResendOTP) return;

    setState(() {
      canResendOTP = false;
      _resendTimeout = 59; // Reset timeout to 60 seconds
      isLoading = true;
    });

    _startTimer();
    await _verifyPhone();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Enter your 6-digit code",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sent to ${widget.phoneNumber}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Code",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const ValueKey("otp"),
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      decoration: const InputDecoration(hintText: "------"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter OTP";
                        } else if (value.length != 6) {
                          return "Please enter a valid OTP";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Timer and Resend OTP Button
                    canResendOTP
                        ? TextButton(
                            onPressed: _resendOTP,
                            child: const Text(
                              "Resend OTP",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : Text(
                            "Resend OTP in $_resendTimeout seconds",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                    const SizedBox(height: 20),
                    Center(
                      child: isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    Theme.of(context).colorScheme.primary),
                                minimumSize:
                                    WidgetStatePropertyAll(const Size(200, 50)),
                              ),
                              onPressed: _verifyOTP,
                              child: const Text(
                                "Verify OTP",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
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
    );
  }

  /// **Verify OTP and Sign In**
  Future<void> _verifyOTP() async {
    setState(() => isLoading = true);
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() => isLoading = false);
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: codeController.text.trim(),
        ),
      );
      await _checkNewUser();
    } catch (e) {
      _showError("Invalid OTP! Please try again.");
    }
    setState(() => isLoading = false);
  }
}
