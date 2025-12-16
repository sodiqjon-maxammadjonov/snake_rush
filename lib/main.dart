import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:snake_rush/screens/main/main_screen.dart';
import 'package:snake_rush/utils/services/ad/ad_service.dart';
import 'package:snake_rush/utils/services/audio/audio_manager.dart';
import 'package:snake_rush/utils/services/storage/storage_service.dart';
import 'package:snake_rush/utils/services/language/language_service.dart';
import 'package:snake_rush/utils/services/iap/iap_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await _initServices();

  runApp(const SnakeRushApp());
}

Future<void> _initServices() async {
  await StorageService().init();
  await AudioManager().init();
  await LanguageService().init();
  await IAPService().initialize();
  await AudioManager().playBackgroundMusic();
  await AdService().init();

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