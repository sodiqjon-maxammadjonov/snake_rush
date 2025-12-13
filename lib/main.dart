import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SnakeRushApp());
}

class SnakeRushApp extends StatelessWidget {
  const SnakeRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Rush',
      debugShowCheckedModeBanner: false,
      home: Center(child: Text('data'),),
    );
  }
}

