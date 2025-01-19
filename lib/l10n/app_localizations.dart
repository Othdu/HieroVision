import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = {
    'en': {
      'appTitle': 'Hieroglyphic Translator',
      'settings': 'Settings',
      'language': 'Language',
      'selectImage': 'Select Hieroglyphic Image',
      'translation': 'Translation:',
      'selectToTranslate': 'Select an image to translate',
      'error': 'Error',
    },
    'es': {
      'appTitle': 'Traductor de Jeroglíficos',
      'settings': 'Configuración',
      'language': 'Idioma',
      'selectImage': 'Seleccionar Imagen Jeroglífica',
      'translation': 'Traducción:',
      'selectToTranslate': 'Selecciona una imagen para traducir',
      'error': 'Error',
    },
    'ar': {
      'appTitle': 'مترجم الهيروغليفية',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'selectImage': 'اختر صورة هيروغليفية',
      'translation': 'الترجمة:',
      'selectToTranslate': 'اختر صورة للترجمة',
      'error': 'خطأ',
    },
    'fr': {
      'appTitle': 'Traducteur Hiéroglyphique',
      'settings': 'Paramètres',
      'language': 'Langue',
      'selectImage': 'Sélectionner une Image Hiéroglyphique',
      'translation': 'Traduction:',
      'selectToTranslate': 'Sélectionnez une image à traduire',
      'error': 'Erreur',
    },
    'nl': {
      'appTitle': 'Hiërogliefen Vertaler',
      'settings': 'Instellingen',
      'language': 'Taal',
      'selectImage': 'Selecteer Hiërogliefen Afbeelding',
      'translation': 'Vertaling:',
      'selectToTranslate': 'Selecteer een afbeelding om te vertalen',
      'error': 'Fout',
    },
  };

  String _getFromMap(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }

  String get appTitle => _getFromMap('appTitle');
  String get settings => _getFromMap('settings');
  String get language => _getFromMap('language');
  String get selectImage => _getFromMap('selectImage');
  String get translation => _getFromMap('translation');
  String get selectToTranslate => _getFromMap('selectToTranslate');
  String get error => _getFromMap('error');

  bool get isRTL => locale.languageCode == 'ar';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'ar', 'fr', 'nl'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
} 