
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
      "fr": {
      "discover": "Découvrir",
      "new": "Nouveau",
      "exploreProducts": "Explorez nos produits",
      "search_products": "Rechercher des produits...",
      "selectLanguage": "Sélectionner une langue",
      "cancel": "Annuler",
      "addToCart": "Ajouter au panier",
      "chooseOptions": "Choisissez vos options",
      "size": "Taille",
      "color": "Couleur",
      "shopNow": "Acheter maintenant",
      "limitedTimeOffer": "Offre à durée limitée",
      "upTo50Off": "Jusqu'à 50% DE RÉDUCTION",
      "onSelectedItems": "sur les articles sélectionnés",
      "reviews": "avis",
      "categories": "Catégories",
      "seeAll": "Voir tout",
      "noProductsFound": "Aucun produit trouvé",
      "sellerDashboard": "Tableau de bord vendeur",
      "addNewProduct": "Ajouter un nouveau produit",
      "myProducts": "Mes produits",
      "salesAnalytics": "Analyses des ventes",
      "ordersManagement": "Gestion des commandes",
      "shopSettings": "Paramètres de la boutique",
      "paymentSettings": "Paramètres de paiement",
      "switchToBuyerMode": "Passer en mode acheteur"
    },
    "en": {
      "discover": "Discover",
      "new": "New",
      "exploreProducts": "Explore our products",
      "search_products": "Search products...",
      "selectLanguage": "Select Language",
      "cancel": "Cancel",
      "addToCart": "Add to Cart",
      "chooseOptions": "Choose your options",
      "size": "Size",
      "color": "Color",
      "shopNow": "Shop Now",
      "limitedTimeOffer": "Limited time offer",
      "upTo50Off": "Up to 50% OFF",
      "onSelectedItems": "on selected items",
      "reviews": "reviews",
      "categories": "Categories",
      "seeAll": "See all",
      "noProductsFound": "No products found",
      "sellerDashboard": "Seller Dashboard",
      "addNewProduct": "Add New Product",
      "myProducts": "My Products",
      "salesAnalytics": "Sales Analytics",
      "ordersManagement": "Orders Management",
      "shopSettings": "Shop Settings",
      "paymentSettings": "Payment Settings",
      "switchToBuyerMode": "Switch to Buyer Mode"
    },
    "ar": {
      "discover": "اكتشف",
      "new": "جديد",
      "exploreProducts": "استكشف منتجاتنا",
      "search_products": "البحث عن المنتجات...",
      "selectLanguage": "اختر اللغة",
      "cancel": "إلغاء",
      "addToCart": "أضف إلى السلة",
      "chooseOptions": "اختر خياراتك",
      "size": "الحجم",
      "color": "اللون",
      "shopNow": "تسوق الآن",
      "limitedTimeOffer": "عرض لفترة محدودة",
      "upTo50Off": "خصم يصل إلى 50٪",
      "onSelectedItems": "على العناصر المختارة",
      "reviews": "المراجعات",
      "categories": "الفئات",
      "seeAll": "عرض الكل",
      "noProductsFound": "لم يتم العثور على منتجات",
      "sellerDashboard": "لوحة تحكم البائع",
      "addNewProduct": "إضافة منتج جديد",
      "myProducts": "منتجاتي",
      "salesAnalytics": "تحليلات المبيعات",
      "ordersManagement": "إدارة الطلبات",
      "shopSettings": "إعدادات المتجر",
      "paymentSettings": "إعدادات الدفع",
      "switchToBuyerMode": "التبديل إلى وضع المشتري"
    }
  };
}