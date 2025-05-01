import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../functions/other_functions.dart';
import 'package:flutter/material.dart';
import '../widgets/category_box.dart';
import '../models/voucher_model.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/promo_box.dart';
import 'checkout_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late Future<bool> checkVouchers;
  List<String> imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkVouchers = user != null ? vouchers() : Future.value(false);
    _fetchBannerImages();
  }

  Future<bool> vouchers() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();
      return doc.get("voucherApplied") ?? false;
    } catch (e) {
      print("Error fetching vouchers: $e");
      return false;
    }
  }

  Future<void> _fetchBannerImages() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('banners').get();

      if (snapshot.docs.isEmpty) {
        print("No banner images found in Firestore!");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      List<String> fetchedUrls = [];
      for (var doc in snapshot.docs) {
        final url = doc['imgURL'] as String?; // Use 'img_carousel' here
        if (url != null && url.isNotEmpty) {
          fetchedUrls.add(url);
        } else {
          print("Invalid or empty img_carousel in document: ${doc.id}");
        }
      }

      print("Fetched Image URLs: $fetchedUrls");

      if (mounted) {
        setState(() {
          imageUrls = fetchedUrls;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching banners: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkVouchers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return Scaffold(
            appBar: CustomAppBar(),
            drawer: const CustomDrawer(),
            backgroundColor: Theme.of(context).colorScheme.surfaceBright,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive())
                        : imageUrls.isEmpty
                            ? const Center(child: Text("No banners available."))
                            : CarouselSlider.builder(
                                options: CarouselOptions(
                                  height: 200.0,
                                  autoPlay: true,
                                  enlargeCenterPage: true,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 1,
                                ),
                                itemCount: imageUrls.length,
                                itemBuilder: (context, index, realIndex) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrls[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child: CircularProgressIndicator
                                                  .adaptive()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error,
                                              size: 50, color: Colors.red),
                                    ),
                                  );
                                },
                              ),
                    const SizedBox(height: 25),

                    // Discount Vouchers
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("vouchers")
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator.adaptive());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text("No vouchers available."));
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return PromoBox(
                                voucher: Voucher.fromSnapshot(
                                    snapshot.data!.docs[index]),
                              );
                            },
                            itemCount: snapshot.data!.docs.length,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "What would you like to have?",
                      textScaler: TextScaler.linear(1),
                      softWrap: true,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),

                    const SizedBox(height: 20),

                    StreamBuilder(
                      stream: OtherFunctions.getCategories(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive());
                        }
                        if (!snapshot.hasData || snapshot.data.isEmpty) {
                          return const Center(
                            child: Text("No Categories available yet!"),
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            return CategoryBox(category: snapshot.data[index]);
                          },
                          itemCount: snapshot.data.length,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const CheckoutScreen();
        }
      },
    );
  }
}
