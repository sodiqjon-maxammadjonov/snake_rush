import 'package:get_it/get_it.dart';
import 'audio/audio_manager.dart';
import 'language/language_service.dart';
import 'storage/storage_service.dart';
import 'ad/ad_service.dart';
import 'iap/iap_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 1. Hot Restart paytida xato chiqmasligi uchun oldin hammasini tozalaymiz
  await getIt.reset();

  // 2. StorageService - eng birinchi bo'lishi kerak, chunki boshqalar unga bog'liq
  final storage = StorageService();
  getIt.registerSingleton<StorageService>(storage);
  await storage.init();

  // 3. AudioManager - musiqani yuklash va boshlash
  final audio = AudioManager();
  getIt.registerSingleton<AudioManager>(audio);
  await audio.init();
  // Musiqani darhol boshlab yuborish
  audio.playBackgroundMusic();

  // 4. LanguageService - til sozlamalari
  final language = LanguageService();
  getIt.registerSingleton<LanguageService>(language);
  await language.init();

  // 5. Reklama va To'lov tizimlari (bular odatda dispose-da tozalashni talab qiladi)
  final ads = AdService();
  getIt.registerSingleton<AdService>(ads);
  await ads.init();

  final iap = IAPService();
  getIt.registerSingleton<IAPService>(iap);
  await iap.initialize();

  print('✅ Hamma servislar muvaffaqiyatli ishga tushdi!');
}

Future<void> disposeServices() async {
  if (getIt.isRegistered<AudioManager>()) {
    await getIt<AudioManager>().dispose();
  }

  if (getIt.isRegistered<AdService>()) {
    getIt<AdService>().dispose();
  }

  if (getIt.isRegistered<IAPService>()) {
    getIt<IAPService>().dispose();
  }

  await getIt.reset();
}