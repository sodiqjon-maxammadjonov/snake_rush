import 'package:flutter/cupertino.dart';
import '../storage/storage_service.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final _storage = StorageService();
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  Future<void> init() async {
    _currentLanguage = _storage.language;
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _storage.setLanguage(languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  String get flag {
    return _languageFlags[_currentLanguage] ?? '🇬🇧';
  }

  String get name {
    return _languageNames[_currentLanguage] ?? 'English';
  }

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