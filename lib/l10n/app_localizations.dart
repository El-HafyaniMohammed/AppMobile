
import 'package:shared_preferences/shared_preferences.dart';

// Language Model
class LanguageModel {
  final String code;
  final String name;
  final String localName;
  
  LanguageModel({
    required this.code,
    required this.name,
    required this.localName,
  });
}

// Translation Service
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  static const String LANGUAGE_CODE = 'languageCode';
  
  // Available languages
  final List<LanguageModel> languages = [
    LanguageModel(code: 'fr', name: 'French', localName: 'Français'),
    LanguageModel(code: 'en', name: 'English', localName: 'English'),
    LanguageModel(code: 'ar', name: 'Arabic', localName: 'العربية')
  ];
  
  // Default language
  String currentLanguage = 'fr';
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentLanguage = prefs.getString(LANGUAGE_CODE) ?? 'fr';
  }
  
  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_CODE, languageCode);
    currentLanguage = languageCode;
  }
  
  String getText(String key) {
    return translations[currentLanguage]?[key] ?? translations['fr']?[key] ?? key;
  }
  
  // Translation map
  final Map<String, Map<String, String>> translations = {
    'fr': {
      'profile': 'Profil',
      'personalInfo': 'Informations personnelles',
      'fullName': 'Nom complet',
      'phoneNumber': 'Téléphone',
      'orders': 'Mes commandes',
      'ordersHistory': 'Voir l\'historique des commandes',
      'addresses': 'Adresses',
      'manageAddresses': 'Gérer les adresses de livraison',
      'payment': 'Paiement',
      'paymentMethods': 'Cartes et méthodes de paiement',
      'preferences': 'Préférences',
      'notifications': 'Notifications',
      'language': 'Langue',
      'darkTheme': 'Thème sombre',
      'logout': 'Déconnexion',
      'deleteAccount': 'Supprimer le compte',
      'confirmed': 'Vérifié',
      'inProgress': 'En cours',
      'favorites': 'Favoris',
      'confirmLogout': 'Confirmer la déconnexion',
      'logoutMsg': 'Voulez-vous vraiment vous déconnecter ?',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'confirmDelete': 'Confirmer la suppression',
      'deleteAccountMsg': 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et toutes vos données seront perdues.',
      'securityReason': 'Pour des raisons de sécurité, veuillez entrer votre mot de passe pour confirmer la suppression du compte.',
      'password': 'Mot de passe',
      'confirmDeleteAction': 'Confirmer la suppression',
      'accountDeleted': 'Votre compte a été supprimé avec succès.',
      'errorOccurred': 'Une erreur est survenue.',
      'wrongPassword': 'Mot de passe incorrect.',
      'tooManyRequests': 'Trop de tentatives. Veuillez réessayer plus tard.',
      'profileUpdated': 'Profil mis à jour avec succès',
      'updateError': 'Erreur lors de la mise à jour : ',
      'logoutError': 'Erreur lors de la déconnexion : ',
      'invalidPhoneFormat': 'Format de numéro marocain invalide. Utilisez le format 06XXXXXXXX ou 07XXXXXXXX',
      'enterYour': 'Entrez votre ',
      'selectLanguage': 'Sélectionner une langue',
      'imageUpdated': 'Image mise à jour avec succès.',
      'noImageSelected': 'Aucune image sélectionnée.',
      'uploadFailed': 'Upload failed, please try again.',
      'permissionsRequired': 'Permissions requises',
      'permissionsMessage': 'Pour utiliser cette fonctionnalité, vous devez autoriser l\'accès à la caméra ou au stockage dans les paramètres de l\'application.',
      'openSettings': 'Ouvrir les paramètres',
      'chooseSource': 'Choisir une source',
      'camera': 'Caméra',
      'gallery': 'Galerie',
    },
    'en': {
      'profile': 'Profile',
      'personalInfo': 'Personal Information',
      'fullName': 'Full Name',
      'phoneNumber': 'Phone Number',
      'orders': 'My Orders',
      'ordersHistory': 'View order history',
      'addresses': 'Addresses',
      'manageAddresses': 'Manage delivery addresses',
      'payment': 'Payment',
      'paymentMethods': 'Cards and payment methods',
      'preferences': 'Preferences',
      'notifications': 'Notifications',
      'language': 'Language',
      'darkTheme': 'Dark Theme',
      'logout': 'Logout',
      'deleteAccount': 'Delete Account',
      'confirmed': 'Verified',
      'inProgress': 'In Progress',
      'favorites': 'Favorites',
      'confirmLogout': 'Confirm Logout',
      'logoutMsg': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'confirmDelete': 'Delete Account',
      'deleteAccountMsg': 'Are you sure you want to delete your account? This action is irreversible and all your data will be lost.',
      'securityReason': 'For security reasons, please enter your password to confirm account deletion.',
      'password': 'Password',
      'confirmDeleteAction': 'Confirm Deletion',
      'accountDeleted': 'Your account has been successfully deleted.',
      'errorOccurred': 'An error occurred.',
      'wrongPassword': 'Incorrect password.',
      'tooManyRequests': 'Too many attempts. Please try again later.',
      'profileUpdated': 'Profile updated successfully',
      'updateError': 'Update error: ',
      'logoutError': 'Logout error: ',
      'invalidPhoneFormat': 'Invalid Moroccan phone format. Use format 06XXXXXXXX or 07XXXXXXXX',
      'enterYour': 'Enter your ',
      'selectLanguage': 'Select Language',
      'imageUpdated': 'Image updated successfully.',
      'noImageSelected': 'No image selected.',
      'uploadFailed': 'Upload failed, please try again.',
      'permissionsRequired': 'Permissions Required',
      'permissionsMessage': 'To use this feature, you must allow access to the camera or storage in the app settings.',
      'openSettings': 'Open Settings',
      'chooseSource': 'Choose Source',
      'camera': 'Camera',
      'gallery': 'Gallery',
    },
    'ar': {
      'profile': 'الملف الشخصي',
      'personalInfo': 'المعلومات الشخصية',
      'fullName': 'الاسم الكامل',
      'phoneNumber': 'رقم الهاتف',
      'orders': 'طلباتي',
      'ordersHistory': 'عرض تاريخ الطلبات',
      'addresses': 'العناوين',
      'manageAddresses': 'إدارة عناوين التسليم',
      'payment': 'الدفع',
      'paymentMethods': 'البطاقات وطرق الدفع',
      'preferences': 'التفضيلات',
      'notifications': 'الإشعارات',
      'language': 'اللغة',
      'darkTheme': 'الوضع الداكن',
      'logout': 'تسجيل الخروج',
      'deleteAccount': 'حذف الحساب',
      'confirmed': 'تم التحقق',
      'inProgress': 'قيد التنفيذ',
      'favorites': 'المفضلة',
      'confirmLogout': 'تأكيد تسجيل الخروج',
      'logoutMsg': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'confirmDelete': 'حذف الحساب',
      'deleteAccountMsg': 'هل أنت متأكد أنك تريد حذف حسابك؟ هذا الإجراء لا رجعة فيه وستفقد جميع بياناتك.',
      'securityReason': 'لأسباب أمنية، يرجى إدخال كلمة المرور الخاصة بك لتأكيد حذف الحساب.',
      'password': 'كلمة المرور',
      'confirmDeleteAction': 'تأكيد الحذف',
      'accountDeleted': 'تم حذف حسابك بنجاح.',
      'errorOccurred': 'حدث خطأ.',
      'wrongPassword': 'كلمة مرور غير صحيحة.',
      'tooManyRequests': 'محاولات كثيرة جدًا. يرجى المحاولة لاحقًا.',
      'profileUpdated': 'تم تحديث الملف الشخصي بنجاح',
      'updateError': 'خطأ في التحديث: ',
      'logoutError': 'خطأ في تسجيل الخروج: ',
      'invalidPhoneFormat': 'تنسيق رقم الهاتف المغربي غير صالح. استخدم التنسيق 06XXXXXXXX أو 07XXXXXXXX',
      'enterYour': 'أدخل ',
      'selectLanguage': 'اختر اللغة',
      'imageUpdated': 'تم تحديث الصورة بنجاح.',
      'noImageSelected': 'لم يتم اختيار صورة.',
      'uploadFailed': 'فشل التحميل، يرجى المحاولة مرة أخرى.',
      'permissionsRequired': 'الأذونات المطلوبة',
      'permissionsMessage': 'لاستخدام هذه الميزة، يجب عليك السماح بالوصول إلى الكاميرا أو التخزين في إعدادات التطبيق.',
      'openSettings': 'فتح الإعدادات',
      'chooseSource': 'اختر المصدر',
      'camera': 'الكاميرا',
      'gallery': 'المعرض',
    }
  };
}