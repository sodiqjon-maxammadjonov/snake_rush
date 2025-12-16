import 'package:flutter/cupertino.dart';
import '../service_locator.dart';
import '../storage/storage_service.dart';

class LanguageService extends ChangeNotifier {
  late final StorageService _storage;
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  Future<void> init() async {
    _storage = getIt<StorageService>();
    _currentLanguage = _storage.language;
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    _currentLanguage = languageCode;
    await _storage.setLanguage(languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  String get flag => _languageFlags[_currentLanguage] ?? '🇬🇧';
  String get name => _languageNames[_currentLanguage] ?? 'English';

  List<Language> get availableLanguages {
    return _languageNames.entries.map((entry) {
      return Language(
        code: entry.key,
        name: entry.value,
        flag: _languageFlags[entry.key] ?? '🌐',
      );
    }).toList();
  }

  static const Map<String, String> _languageFlags = {
    'en': '🇬🇧',
    'uz': '🇺🇿',
    'ru': '🇷🇺',
    'kk': '🇰🇿',
    'ky': '🇰🇬',
  };

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'uz': "O'zbekcha",
    'ru': 'Русский',
    'kk': 'Қазақша',
    'ky': 'Кыргызча',
  };

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'settings': 'Settings',
      'game_sound': 'Game Sound',
      'music': 'Music',
      'leaderboard': 'Leaderboard',
      'how_to_play': 'How to Play',
      'share_game': 'Share Game',
      'language': 'Language',
      'play': 'PLAY',
      'shop': 'SHOP',
      'top': 'TOP',
      'me': 'ME',
      'daily_reward': 'DAILY REWARD',
      'coming_soon': 'Coming soon...',
      'purchase_success': 'Purchase Successful!',
      'purchase_failed': 'Purchase Failed',
      'try_again': 'Please try again',
      'watch_ad': 'Watch Ad',
      'get_50_coins': 'Get 50 Free Coins',
      'watch': 'Watch',
      'coins': 'Coins',
      'bonus': 'BONUS',
      'popular': 'POPULAR',
      'best_value': 'BEST VALUE',
      'ad_reward_success': 'Reward Received!',
      'ad_not_ready': 'Ad not ready. Please try again later.',
    },
    'uz': {
      'settings': 'Sozlamalar',
      'game_sound': "O'yin ovozi",
      'music': 'Musiqa',
      'leaderboard': 'Reyting',
      'how_to_play': "Qanday o'ynash",
      'share_game': "O'yinni ulashish",
      'language': 'Til',
      'play': "O'YNASH",
      'shop': 'DOKON',
      'top': 'TOP',
      'me': 'MEN',
      'daily_reward': 'KUNLIK MUKOFOT',
      'coming_soon': 'Tez orada...',
      'purchase_success': "Sotib olish muvaffaqiyatli!",
      'purchase_failed': "Sotib olish amalga oshmadi",
      'try_again': 'Qaytadan urinib ko\'ring',
      'watch_ad': 'Reklama ko\'ring',
      'get_50_coins': '50 Coin bepul oling',
      'watch': 'Ko\'rish',
      'coins': 'Tangalar',
      'bonus': 'BONUS',
      'popular': 'MASHHUR',
      'best_value': 'ENG FOYDALI',
      'ad_reward_success': 'Mukofot olindi!',
      'ad_not_ready': 'Reklama tayyor emas. Keyinroq urinib ko\'ring.',
    },
    'ru': {
      'settings': 'Настройки',
      'game_sound': 'Звук игры',
      'music': 'Музыка',
      'leaderboard': 'Рейтинг',
      'how_to_play': 'Как играть',
      'share_game': 'Поделиться',
      'language': 'Язык',
      'play': 'ИГРАТЬ',
      'shop': 'МАГАЗИН',
      'top': 'ТОП',
      'me': 'Я',
      'daily_reward': 'ЕЖЕДНЕВНАЯ НАГРАДА',
      'coming_soon': 'Скоро...',
      'purchase_success': 'Покупка успешна!',
      'purchase_failed': 'Покупка не удалась',
      'try_again': 'Попробуйте снова',
      'watch_ad': 'Смотреть рекламу',
      'get_50_coins': 'Получить 50 монет бесплатно',
      'watch': 'Смотреть',
      'coins': 'Монеты',
      'bonus': 'БОНУС',
      'popular': 'ПОПУЛЯРНО',
      'best_value': 'ЛУЧШЕЕ',
      'ad_reward_success': 'Награда получена!',
      'ad_not_ready': 'Реклама не готова. Попробуйте позже.',
    },
    'kk': {
      'settings': 'Баптаулар',
      'game_sound': 'Ойын дыбысы',
      'music': 'Музыка',
      'leaderboard': 'Рейтинг',
      'how_to_play': 'Қалай ойнау',
      'share_game': 'Бөлісу',
      'language': 'Тіл',
      'play': 'ОЙНАУ',
      'shop': 'ДҮКЕН',
      'top': 'ТОП',
      'me': 'МЕН',
      'daily_reward': 'КҮНДЕЛІКТІ СЫЙЛЫҚ',
      'coming_soon': 'Жақында...',
      'purchase_success': 'Сатып алу сәтті!',
      'purchase_failed': 'Сатып алу сәтсіз',
      'try_again': 'Қайталап көріңіз',
      'watch_ad': 'Жарнаманы көру',
      'get_50_coins': '50 тиын тегін алыңыз',
      'watch': 'Көру',
      'coins': 'Тиындар',
      'bonus': 'БОНУС',
      'popular': 'ТАНЫМАЛ',
      'best_value': 'ЕҢ ТИІМДІ',
      'ad_reward_success': 'Сыйлық алынды!',
      'ad_not_ready': 'Жарнама дайын емес. Кейінірек көріңіз.',
    },
    'ky': {
      'settings': 'Орнотуулар',
      'game_sound': 'Оюн үнү',
      'music': 'Музыка',
      'leaderboard': 'Рейтинг',
      'how_to_play': 'Кантип ойноо',
      'share_game': 'Бөлүшүү',
      'language': 'Тил',
      'play': 'ОЙНОО',
      'shop': 'ДҮКӨН',
      'top': 'ТОП',
      'me': 'МЕН',
      'daily_reward': 'КҮНДҮК СЫЙЛЫК',
      'coming_soon': 'Жакында...',
      'purchase_success': 'Сатып алуу ийгиликтүү!',
      'purchase_failed': 'Сатып алуу ийгиликсиз',
      'try_again': 'Кайра аракет кылыңыз',
      'watch_ad': 'Жарнаманы көрүү',
      'get_50_coins': '50 тыйын бекер алыңыз',
      'watch': 'Көрүү',
      'coins': 'Тыйындар',
      'bonus': 'БОНУС',
      'popular': 'ПОПУЛЯРДУУ',
      'best_value': 'ЭҢ ПАЙДАЛУУ',
      'ad_reward_success': 'Сыйлык алынды!',
      'ad_not_ready': 'Жарнама даяр эмес. Кийинчерээк аракет кылыңыз.',
    },
  };
}

class Language {
  final String code;
  final String name;
  final String flag;

  Language({
    required this.code,
    required this.name,
    required this.flag,
  });
}