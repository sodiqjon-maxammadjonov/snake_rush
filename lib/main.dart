import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:snake_rush/screens/main/main_screen.dart';
import 'package:snake_rush/utils/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Screen orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize all services ONCE
  await setupServiceLocator();

  runApp(const SnakeRushApp());
}

class SnakeRushApp extends StatelessWidget {
  const SnakeRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Snake Rush',
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}