import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../functions/other_functions.dart';
import 'package:flutter/material.dart';
import 'order_confirm_screen.dart';
import 'package:intl/intl.dart';
import 'voucher_screen.dart';
import 'home_screen.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = "/checkout";
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<List<dynamic>> myData;
  final locationController = TextEditingController();
  final deliveryDateController = TextEditingController();
  final deliveryTimeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isAddressSet = false;
  bool isConfirm = false;
  User? user = FirebaseAuth.instance.currentUser;
  bool loading = false;
  bool isPlaced = false;
  bool isApplying = false;

  late Future<bool> checkVouchers;
  String? voucher;

  List<String> get deliveryDates {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM');
    return [
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 2)),
    ].map((date) => dateFormat.format(date)).toList();
  }

  late Future<List<String>> _timeSlotsFuture;
  List<String> _timeSlots = [];

  Future<bool> vouchers() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    final result = doc.get("voucherApplied");
    final thisVoucher = doc.get("inThisOrder");

    voucher = thisVoucher;
    final v = await FirebaseFirestore.instance
        .collection("vouchers")
        .doc(voucher)
        .get();
    final vouchers = v.data();
    myData = OtherFunctions.getCheckOutDetails(result, vouchers!, false);
    return result;
  }

  Future<List<String>> _fetchTimeSlots() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('delivery_settings')
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('time_slots')) {
          return List<String>.from(data['time_slots']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching time slots: $e');
      return [];
    }
  }

  void _setupTimeSlotsListener() {
    FirebaseFirestore.instance
        .collection('settings')
        .doc('delivery_settings')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('time_slots')) {
          setState(() {
            _timeSlots = List<String>.from(data['time_slots']);
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _timeSlotsFuture = _fetchTimeSlots();
    _setupTimeSlotsListener();
    myData = OtherFunctions.getCheckOutDetails(false, {}, false);
    if (user != null) {
      checkVouchers = vouchers();
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    deliveryDateController.dispose();
    deliveryTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
        title: Text(
          "Checkout",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.routeName,
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder(
        future: checkVouchers,
        builder: (context, vouchersnapshot) {
          if (vouchersnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder(
                future: myData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order Items",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    snapshot.data![1][index],
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    snapshot.data![2][index],
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: snapshot.data![4],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal:",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              "₹${snapshot.data![3]}",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Delivery Fee:",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              "₹${snapshot.data![5]}",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              "₹${snapshot.data![0]}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (vouchersnapshot.data ?? false)
                        Center(
                          child: Text(
                            "Total price decreased by voucher value",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Delivery Address",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                            const SizedBox(height: 20),
                            if (!isConfirm)
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: locationController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.location_on),
                                        labelText: "Delivery Address",
                                      ),
                                      autocorrect: true,
                                      enableSuggestions: true,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      keyboardType: TextInputType.multiline,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Please enter delivery address.";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    DropdownButtonFormField<String>(
                                      value: deliveryDateController.text.isEmpty
                                          ? null
                                          : deliveryDateController.text,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.calendar_today),
                                        labelText: "Delivery Date",
                                      ),
                                      items: deliveryDates.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          deliveryDateController.text = value!;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please select a delivery date.";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    FutureBuilder<List<String>>(
                                      future: _timeSlotsFuture,
                                      builder: (context, timeSlotSnapshot) {
                                        if (timeSlotSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        final slots =
                                            timeSlotSnapshot.hasData &&
                                                    timeSlotSnapshot
                                                        .data!.isNotEmpty
                                                ? timeSlotSnapshot.data!
                                                : _timeSlots.isNotEmpty
                                                    ? _timeSlots
                                                    : [];

                                        if (slots.isEmpty) {
                                          return const Text(
                                            'No delivery slots available',
                                            style: TextStyle(color: Colors.red),
                                          );
                                        }

                                        return DropdownButtonFormField<String>(
                                          value: deliveryTimeController
                                                  .text.isEmpty
                                              ? null
                                              : deliveryTimeController.text,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            prefixIcon:
                                                const Icon(Icons.access_time),
                                            labelText: "Delivery Time",
                                          ),
                                          items: (slots as List<String>)
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              deliveryTimeController.text =
                                                  value!;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please select a delivery time.";
                                            }
                                            return null;
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            if (isConfirm)
                              Column(
                                children: [
                                  Text(
                                    locationController.text,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Delivery Date: ${deliveryDateController.text}",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Delivery Time: ${deliveryTimeController.text}",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 20),
                            if (loading)
                              const CircularProgressIndicator.adaptive(),
                            if (!isAddressSet && !loading)
                              ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  bool valid =
                                      _formKey.currentState!.validate();
                                  if (!valid) {
                                    return;
                                  }
                                  _formKey.currentState!.save();
                                  setState(() {
                                    isAddressSet = true;
                                    isConfirm = true;
                                  });
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                    elevation: const WidgetStatePropertyAll(4)),
                                child: const Text(
                                  "Confirm Address",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (isAddressSet && !isConfirm && !loading)
                              ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  bool valid =
                                      _formKey.currentState!.validate();
                                  if (!valid) {
                                    return;
                                  }
                                  _formKey.currentState!.save();
                                  setState(() {
                                    isConfirm = true;
                                  });
                                },
                                child: const Text("Confirm Address"),
                              ),
                            if (isAddressSet &&
                                isConfirm &&
                                !loading &&
                                !isPlaced)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isConfirm = false;
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      Theme.of(context).colorScheme.primary),
                                ),
                                child: const Text(
                                  "Edit Address",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 125,
                        width: double.infinity,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            isApplying
                                ? const CircularProgressIndicator.adaptive()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        vouchersnapshot.data ?? false
                                            ? "Voucher Applied"
                                            : "Do you have any voucher?",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                      ),
                                      StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("settings")
                                            .doc("App Settings")
                                            .snapshots(),
                                        builder: (context, feeSnapshot) {
                                          if (feeSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator
                                                .adaptive();
                                          }
                                          return TextButton(
                                            onPressed: vouchersnapshot.data ??
                                                    false
                                                ? () async {
                                                    setState(() {
                                                      isApplying = true;
                                                    });
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("vouchers")
                                                        .doc(voucher)
                                                        .get()
                                                        .then((value) async {
                                                      await OtherFunctions
                                                          .removeVoucher(
                                                        value.data()!,
                                                      );
                                                    }).then((value) {
                                                      checkVouchers =
                                                          vouchers().then(
                                                        (value) async {
                                                          if (!value) {
                                                            final voucherValue =
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "vouchers")
                                                                    .doc(
                                                                        voucher)
                                                                    .get();
                                                            final myVoucher =
                                                                voucherValue
                                                                    .data();
                                                            setState(() {
                                                              isApplying =
                                                                  false;
                                                              myData =
                                                                  OtherFunctions
                                                                      .getCheckOutDetails(
                                                                true,
                                                                myVoucher!,
                                                                true,
                                                              );
                                                              checkVouchers =
                                                                  vouchers();
                                                            });
                                                            await OtherFunctions
                                                                .removeId();
                                                            return true;
                                                          }
                                                          return false;
                                                        },
                                                      );
                                                    });
                                                  }
                                                : () async {
                                                    await OtherFunctions
                                                            .getTotal()
                                                        .then((value) {
                                                      if (value >=
                                                          double.parse(feeSnapshot
                                                                  .data!
                                                                  .data()![
                                                              "minimum amount"])) {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                          VoucherScreen
                                                              .routeName,
                                                          arguments: true,
                                                        )
                                                            .then((_) {
                                                          checkVouchers =
                                                              vouchers().then(
                                                            (value) async {
                                                              if (value) {
                                                                final voucherValue = await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "vouchers")
                                                                    .doc(
                                                                        voucher)
                                                                    .get();
                                                                final vouchers =
                                                                    voucherValue
                                                                        .data();
                                                                setState(() {
                                                                  isApplying =
                                                                      false;
                                                                  myData =
                                                                      OtherFunctions
                                                                          .getCheckOutDetails(
                                                                    true,
                                                                    vouchers!,
                                                                    false,
                                                                  );
                                                                });
                                                                return true;
                                                              }
                                                              return false;
                                                            },
                                                          );
                                                        });
                                                      } else {
                                                        setState(() {
                                                          isApplying = false;
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              "Minimum total amount must be ₹${feeSnapshot.data!.data()!["minimum amount"]} to be able to apply voucher",
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    });
                                                  },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 30,
                                              ),
                                            ),
                                            child: Text(
                                              vouchersnapshot.data ?? false
                                                  ? "Remove Voucher"
                                                  : "Apply Voucher",
                                              style: const TextStyle(
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.orange,
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/images/coupon.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isPlaced)
                        const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      if (!isPlaced)
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              if (!isConfirm) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Please confirm your delivery address"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                isPlaced = true;
                              });

                              await OtherFunctions.placeOrder(
                                location: locationController.text.trim(),
                                deliveryDate:
                                    deliveryDateController.text.trim(),
                                deliveryTime:
                                    deliveryTimeController.text.trim(),
                                context: context,
                                total: snapshot.data![0],
                                userId: FirebaseAuth.instance.currentUser!.uid,
                                items: snapshot.data![6],
                              ).then((value) {
                                setState(() {
                                  isPlaced = false;
                                });
                                if (value) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    OrderConfirmScreen.routeName,
                                    (route) => false,
                                  );
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                minimumSize: const Size(350, 40),
                                elevation: 4),
                            child: const Text(
                              "Place Order",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                HomeScreen.routeName,
                                (route) => true,
                              );
                            },
                            child: const Text("CANCEL MY ORDER"),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
