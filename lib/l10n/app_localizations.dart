// ignore_for_file: unused_import

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'personalInfo': 'Informations personnelles',
      'fullName': 'Nom complet',
      'phone': 'Téléphone',
      'preferences': 'Préférences',
      'notifications': 'Notifications',
      'language': 'Langue',
      'darkTheme': 'Thème sombre',
      'logout': 'Déconnexion',
      'deleteAccount': 'Supprimer le compte',
      // Ajoutez d'autres traductions ici
    },
    'en': {
      'personalInfo': 'Personal Information',
      'fullName': 'Full Name',
      'phone': 'Phone',
      'preferences': 'Preferences',
      'notifications': 'Notifications',
      'language': 'Language',
      'darkTheme': 'Dark Theme',
      'logout': 'Logout',
      'deleteAccount': 'Delete Account',
      // Add more translations here
    },
    'ar': {
      'personalInfo': 'المعلومات الشخصية',
      'fullName': 'الاسم الكامل',
      'phone': 'الهاتف',
      'preferences': 'التفضيلات',
      'notifications': 'الإشعارات',
      'language': 'اللغة',
      'darkTheme': 'المظهر الداكن',
      'logout': 'تسجيل الخروج',
      'deleteAccount': 'حذف الحساب',
      // أضف المزيد من الترجمات هنا
    },
    'es': {
      'personalInfo': 'Información Personal',
      'fullName': 'Nombre Completo',
      'phone': 'Teléfono',
      'preferences': 'Preferencias',
      'notifications': 'Notificaciones',
      'language': 'Idioma',
      'darkTheme': 'Tema Oscuro',
      'logout': 'Cerrar Sesión',
      'deleteAccount': 'Eliminar Cuenta',
      // Agregar más traducciones aquí
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'ar', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}