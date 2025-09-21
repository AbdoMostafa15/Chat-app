import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/screens/chatpage.dart';
import 'package:chatapp/screens/homeview.dart';
import 'package:chatapp/screens/signUp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        Chatpage.id: (context) => Chatpage(),
        Signup.id: (context) => Signup(),
        Homeview.id: (context) => Homeview(),
      },
      debugShowCheckedModeBanner: false,
      home: Homeview(),
    );
  }
}
