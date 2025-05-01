import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';

Future<void> sendNotification(String title, String body,
    {String? userId}) async {
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('sendNotification');
  try {
    final response = await callable.call({
      'title': title,
      'body': body,
      'userId': userId ?? 'all', // Default to 'all' if no user is specified
    });
    response.data;
  } catch (e) {
    e;
  }
}

class NotificationForm extends StatefulWidget {
  static const routeName = "/notifications";
  const NotificationForm({super.key});

  @override
  _NotificationFormState createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationForm> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String body = '';
  String targetUser = '';

  @override
  void initState() {
    super.initState();
    setupNotifications();
  }

  Future<void> setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print("Received notification: ${message.notification?.title}");
    });

    // Subscribe to 'all' topic for global notifications
    await messaging.subscribeToTopic("all");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification System"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Body'),
                onChanged: (value) => body = value,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Target User (optional)'),
                onChanged: (value) => targetUser = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    sendNotification(title, body,
                        userId: targetUser.isNotEmpty ? targetUser : 'all');
                  }
                },
                child: Text('Send Notification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
