import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../functions/other_functions.dart';
import '../widgets/item_box.dart';
import 'basket_screen.dart';

class CategoryItemScreen extends StatefulWidget {
  static const routeName = "/category-items";
  const CategoryItemScreen({super.key});

  @override
  State<CategoryItemScreen> createState() => _CategoryItemScreenState();
}

class _CategoryItemScreenState extends State<CategoryItemScreen> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    final Category category =
        ModalRoute.of(context)!.settings.arguments as Category;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      extendBody: false,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              label: const Text(
                "Basket",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  BasketScreen.routeName,
                  arguments: true,
                );
                if (result == true) {
                  setState(() {
                    visible = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 80),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            visible = false;
          });
          // Add logic to refresh data here.
        },
        displacement: 10,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: Column(
          children: [
            if (visible)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Some data might have changed since the last time you visited this page.\nPull to refresh!",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: StreamBuilder(
                stream: OtherFunctions.getItems(category.name),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "An error occurred: ${snapshot.error}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return Center(
                      child: Text(
                        "No Menu Items available yet!",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  // ✅ Sort the items alphabetically by name
                  List items = snapshot.data;
                  items.sort((a, b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                  return Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 250,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return ItemBox(
                          item: items[index],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
