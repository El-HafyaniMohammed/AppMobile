import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String translate(String key) {
    // Implement translation logic based on locale
    final translations = {
      'fr': {
        'personal_info': 'Informations personnelles',
        'full_name': 'Nom complet',
        'email': 'Email',
        'phone': 'Téléphone',
        'name_required': 'Nom requis',
        'invalid_phone': 'Numéro de téléphone invalide',
      },
      'en': {
        'personal_info': 'Personal Information',
        'full_name': 'Full Name',
        'email': 'Email',
        'phone': 'Phone',
        'name_required': 'Name is required',
        'invalid_phone': 'Invalid phone number',
      },
      // Add other language translations
    };

    return translations[locale.languageCode]?[key] ?? key;
  }
}
