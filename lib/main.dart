import 'config/theme.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/basket_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/voucher_screen.dart';
import 'screens/new_user_screen.dart';
import 'screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/contact_us_screen.dart';
import 'screens/my_account_screen.dart';
import 'screens/order_confirm_screen.dart';
import 'screens/category_item_screen.dart';
import 'screens/terms_and_conditions_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jingola_client/screens/get_started.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jingola_client/widgets/notification_screen.dart';
// import "package:flutter_dotenv/flutter_dotenv.dart";

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.notification?.title}");
}

void main() async {
  // await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("f9c638bc-6e40-48ef-9fca-42314c287a79");
  OneSignal.Notifications.requestPermission(true);
  OneSignal.User.pushSubscription.addObserver((state) {
    print("OneSignal Device Token: ${state.current.token}");
  });
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('User declined notifications');
  }
  messaging.getToken().then((token) {
    print("Firebase Token: $token");
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jingola',
      debugShowCheckedModeBanner: false,
      theme: theme(),
      home: SplashScreen(),
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        AuthScreen.routeName: (context) => AuthScreen(),
        SplashScreen.routeName: (context) => const SplashScreen(),
        BasketScreen.routeName: (context) => BasketScreen(),
        CategoryItemScreen.routeName: (context) => const CategoryItemScreen(),
        CheckoutScreen.routeName: (context) => const CheckoutScreen(),
        OrdersScreen.routeName: (context) => const OrdersScreen(),
        NewUserScreen.routeName: (context) => const NewUserScreen(),
        VoucherScreen.routeName: (context) => const VoucherScreen(),
        MyAccountScreen.routeName: (context) => const MyAccountScreen(),
        ContactUsScreen.routeName: (context) => const ContactUsScreen(),
        OrderConfirmScreen.routeName: (context) => const OrderConfirmScreen(),
        NotificationForm.routeName: (context) => NotificationForm(),
        GetStarted.routeName: (context) => const GetStarted(),
        TermsScreen.routeName: (context) => const TermsScreen(),
      },
    );
  }
}
