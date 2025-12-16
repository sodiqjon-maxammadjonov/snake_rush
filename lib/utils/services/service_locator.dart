import 'package:get_it/get_it.dart';
import 'audio/audio_manager.dart';
import 'language/language_service.dart';
import 'storage/storage_service.dart';
import 'ad/ad_service.dart';
import 'iap/iap_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<StorageService>(StorageService());
  await getIt<StorageService>().init();

  getIt.registerSingleton<AudioManager>(AudioManager());
  await getIt<AudioManager>().init();
  await getIt<AudioManager>().playBackgroundMusic();

  getIt.registerSingleton<LanguageService>(LanguageService());
  await getIt<LanguageService>().init();

  getIt.registerSingleton<AdService>(AdService());
  await getIt<AdService>().init();

  getIt.registerSingleton<IAPService>(IAPService());
  await getIt<IAPService>().initialize();
}

Future<void> disposeServices() async {
  await getIt<AudioManager>().dispose();

  getIt<AdService>().dispose();
  getIt<IAPService>().dispose();

  await getIt.reset();
}

