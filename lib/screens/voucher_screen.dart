import 'package:flutter/material.dart';
import '../functions/other_functions.dart';

class VoucherScreen extends StatefulWidget {
  static const routeName = "/vouchers";
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  @override
  Widget build(BuildContext context) {
    final bool applying = (ModalRoute.of(context)?.settings.arguments as bool?) ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
         color:  Theme.of(context).iconTheme.color,
        ),
        title: Text(
          "Vouchers",
          textScaler: TextScaler.linear(1.2),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: FutureBuilder(
        future: OtherFunctions.getVouchers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No Vouchers Available",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(
                    snapshot.data![index]["code"],
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  
                  subtitle: Text(
                    snapshot.data![index]["description"],
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  trailing: applying
                      ? SizedBox(
                          width: 80,
                          child: TextButton(
                            onPressed: () async {
                              try {
                                await OtherFunctions.applyVoucher(
                                  snapshot.data![index]["id"],
                                  snapshot.data![index],
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Voucher Applied Successfully"),
                                  ),
                                );
                                Navigator.of(context).pop();
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed to apply voucher: $error")),
                                );
                              }
                            },
                            child: const Text(
                              "APPLY",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
