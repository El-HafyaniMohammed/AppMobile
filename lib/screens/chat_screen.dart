import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart'; // Pour copier dans le presse-papiers

// Schéma de couleurs centralisé
class AppColors {
  static const primaryGreen = Color(0xFF4CAF50);
  static const darkGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFF1F8E9);
  static const accentGreen = Color(0xFF81C784);
  static const greyShade = Color(0xFF616161);
  static const errorRed = Color(0xFFE57373);
  static const codeBackground = Color(0xFFF5F5F5);

  static Color background(bool isDark) => isDark ? const Color(0xFF212121) : const Color(0xFFF5F7FA);
  static Color cardBackground(bool isDark) => isDark ? const Color(0xFF424242) : Colors.white;
  static Color textPrimary(bool isDark) => isDark ? Colors.white : greyShade;
  static Color textSecondary(bool isDark) => isDark ? Colors.white70 : greyShade.withOpacity(0.6);
  static Color shadow(bool isDark) => isDark ? Colors.black.withOpacity(0.3) : darkGreen.withOpacity(0.15);
  static Color codeBackgroundDark(bool isDark) => isDark ? const Color(0xFF2D2D2D) : codeBackground;
}

// Modèle pour les paramètres utilisateur
class UserSettings {
  bool isDarkMode;
  String username;
  double fontSize;

  UserSettings({
    this.isDarkMode = false,
    this.username = 'Utilisateur',
    this.fontSize = 16.0,
  });

  Map<String, dynamic> toJson() => {
        'isDarkMode': isDarkMode,
        'username': username,
        'fontSize': fontSize,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        isDarkMode: json['isDarkMode'] ?? false,
        username: json['username'] ?? 'Utilisateur',
        fontSize: json['fontSize'] ?? 16.0,
      );
}

// Modèle pour les messages du chat
class ChatMessage {
  final String sender;
  final String text;
  final Key key;
  final DateTime timestamp;
  bool isEdited;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.key,
    required this.timestamp,
    this.isEdited = false,
  });

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
        'key': key.toString(),
        'timestamp': timestamp.toIso8601String(),
        'isEdited': isEdited,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        sender: json['sender'],
        text: json['text'],
        key: Key(json['key']),
        timestamp: DateTime.parse(json['timestamp']),
        isEdited: json['isEdited'] ?? false,
      );
}

// Gestionnaire de chat pour gérer l'état des messages
class ChatManager {
  List<ChatMessage> messages = [];
  List<List<ChatMessage>> chatHistory = [];

  void addMessage(ChatMessage message) => messages.add(message);

  void startNewChat(String username) {
    if (messages.isNotEmpty) chatHistory.add(List.from(messages));
    messages = [
      ChatMessage(
        sender: 'bot',
        text: 'Nouveau chat démarré ! Comment puis-je vous aider, $username ?',
        key: UniqueKey(),
        timestamp: DateTime.now(),
      )
    ];
  }

  void deleteChat(int index) => chatHistory.removeAt(index);

  void updateMessage(ChatMessage oldMessage, String newText) {
    final index = messages.indexOf(oldMessage);
    if (index != -1) {
      messages[index] = ChatMessage(
        sender: oldMessage.sender,
        text: newText,
        key: oldMessage.key,
        timestamp: oldMessage.timestamp,
        isEdited: true,
      );
    }
  }

  void deleteMessage(ChatMessage message) => messages.remove(message);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ChatScreen(),
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.background(false),
        cardColor: AppColors.cardBackground(false),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto', color: AppColors.textPrimary(false)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: AppColors.darkGreen,
        scaffoldBackgroundColor: AppColors.background(true),
        cardColor: AppColors.cardBackground(true),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto', color: AppColors.textPrimary(true)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatManager chatManager = ChatManager();
  bool _isLoading = false;
  File? _selectedImage;
  late AnimationController _animationController;
  UserSettings _settings = UserSettings();
  bool _isSettingsOpen = false;
  ChatMessage? _editingMessage;
  double _sendButtonScale = 1.0;
  Timer? _scrollTimer;
  bool _isUserLoggedIn = true; // Variable pour vérifier si l'utilisateur est connecté

  // Liste des mots-clés liés à l'e-commerce (organisée par langue)
  final Map<String, List<String>> _ecommerceKeywords = {
    'fr': [
      'prix', 'combien', 'produit', 'commande', 'livraison', 'paiement', 'panier',
      'facture', 'remise', 'offre', 'achat', 'vente', 'boutique', 'stock',
    ],
    'en': [
      'price', 'how much', 'product', 'order', 'shipping', 'delivery', 'payment',
      'cart', 'invoice', 'discount', 'offer', 'buy', 'sell', 'shop', 'stock',
    ],
    'ar': [
      'سعر', 'كم ثمن', 'منتج', 'طلب', 'توصيل', 'دفع', 'سلة', 'فاتورة', 'تخفيض', 'عرض',
      'شراء', 'بيع', 'متجر', 'مخزون', 'كم', 'ثمن', 'هذا', 'هذه',
    ],
  };

  // Liste de mots-clés négatifs pour détecter les hors-sujets
  final List<String> _offTopicKeywords = [
    'météo', 'weather', 'politique', 'politics', 'jeu', 'game', 'film', 'movie',
    'musique', 'music', 'ta mère', 'your mom', 'blague', 'joke',
  ];

  // Réponses dynamiques pour hors-sujet
  final List<String> _offTopicResponses = [
    "Je suis ici pour vous aider avec vos achats, parlez-moi des produits ou commandes !",
    "Désolé, je suis un expert en e-commerce, pas en ça. Que puis-je faire pour vos achats ?",
    "On dirait un sujet intéressant, mais je suis là pour les produits et livraisons !",
    "Restons sur le shopping, voulez-vous parler de prix ou de commandes ?",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _loadSettings();
    _loadInitialMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  // Charger les paramètres utilisateur depuis les préférences partagées
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('userSettings');
    if (settingsJson != null) {
      setState(() {
        _settings = UserSettings.fromJson(jsonDecode(settingsJson));
      });
    }
  }

  // Sauvegarder les paramètres utilisateur dans les préférences partagées
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userSettings', jsonEncode(_settings.toJson()));
  }

  // Charger le message initial du bot
  void _loadInitialMessage() {
    chatManager.addMessage(ChatMessage(
      sender: 'bot',
      text: 'Bonjour ${_settings.username} ! Je suis ici pour vous aider avec vos achats. Parlez-moi des produits, prix ou commandes !',
      key: UniqueKey(),
      timestamp: DateTime.now(),
    ));
    _scrollToBottom();
  }

  // Détection de la langue (améliorée)
  String _detectLanguage(String message) {
    // Priorité aux caractères arabes
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(message)) return 'ar';
    // Vérification pour l'anglais
    if (RegExp(r'price|order|shipping|how much', caseSensitive: false).hasMatch(message)) return 'en';
    // Par défaut, français
    return 'fr';
  }

  // Vérifier si le message est lié à l'e-commerce (assoupli)
  bool _isEcommerceRelated(String message) {
    final String lang = _detectLanguage(message);
    final String lowerMessage = message.toLowerCase();

    // Vérifier les mots-clés positifs (e-commerce)
    bool hasEcommerceKeyword = _ecommerceKeywords[lang]!
        .any((keyword) => lowerMessage.contains(keyword.toLowerCase()));

    // Vérifier les mots-clés négatifs (hors-sujet)
    bool hasOffTopicKeyword = _offTopicKeywords
        .any((keyword) => lowerMessage.contains(keyword.toLowerCase()));

    // Retourner vrai si un mot-clé e-commerce est présent ET aucun mot-clé hors sujet
    return hasEcommerceKeyword && !hasOffTopicKeyword;
  }

  // Choisir une réponse hors-sujet aléatoire
  String _getRandomOffTopicResponse() {
    return _offTopicResponses[math.Random().nextInt(_offTopicResponses.length)];
  }

  // Envoyer un message et appliquer les filtres
  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Si modification d'un message existant
    if (_editingMessage != null) {
      chatManager.updateMessage(_editingMessage!, message);
      setState(() {
        _editingMessage = null;
        _controller.clear();
      });
      _scrollToBottom();
      return;
    }

    // Ajouter le message de l'utilisateur
    setState(() {
      chatManager.addMessage(ChatMessage(
        sender: 'user',
        text: message,
        key: UniqueKey(),
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();

    // Vérification de la connexion utilisateur
    if (!_isUserLoggedIn) {
      setState(() {
        chatManager.addMessage(ChatMessage(
          sender: 'bot',
          text: "Veuillez vous connecter pour que je puisse vous aider !",
          key: UniqueKey(),
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
      return;
    }

    // Vérification si le message est lié à l'e-commerce
    if (!_isEcommerceRelated(message)) {
      setState(() {
        chatManager.addMessage(ChatMessage(
          sender: 'bot',
          text: _getRandomOffTopicResponse(),
          key: UniqueKey(),
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
      return;
    }

    // Si le message est lié à l'e-commerce, appeler l'API Gemini
    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      String response = await _getBotResponse(message);
      setState(() {
        chatManager.addMessage(ChatMessage(
          sender: 'bot',
          text: response,
          key: UniqueKey(),
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        chatManager.addMessage(ChatMessage(
          sender: 'bot',
          text: 'Erreur : $e',
          key: UniqueKey(),
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
    _controller.clear();
  }

  // Appeler l'API Gemini avec un prompt personnalisé pour limiter les réponses à l'e-commerce
  Future<String> _getBotResponse(String message) async {
    const String apiKey = 'AIzaSyAaFlQmnSi5yUaOJv4xmFu-F9VY6vTUHVo';
    final url = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';
    const int maxRetries = 5;
    int retryCount = 0;
    int delaySeconds = 1;

    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('$url?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text': """
Vous êtes un chatbot pour une application e-commerce. Répondez uniquement aux questions liées aux produits, prix, livraisons et commandes.
Si la question est hors sujet, répondez : "Je suis ici pour vous aider avec vos achats, parlez-moi des produits ou commandes !"
Question : $message
"""
                  },
                ],
              },
            ],
            'generationConfig': {'maxOutputTokens': 250, 'temperature': 0.7},
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['candidates']?[0]['content']['parts'][0]['text'] ?? 'Aucune réponse disponible.';
        } else if (response.statusCode == 429) {
          final retryAfter = int.tryParse(response.headers['retry-after'] ?? '$delaySeconds') ?? delaySeconds;
          await Future.delayed(Duration(seconds: retryAfter));
          delaySeconds = math.min(delaySeconds * 2, 60);
          retryCount++;
          continue;
        } else {
          return 'Erreur API : ${response.statusCode} - ${response.reasonPhrase}';
        }
      } catch (e) {
        retryCount++;
        await Future.delayed(Duration(seconds: delaySeconds));
        delaySeconds = math.min(delaySeconds * 2, 60);
        if (retryCount == maxRetries) {
          return 'Échec après $maxRetries tentatives : $e';
        }
      }
    }
    return 'Impossible de se connecter. Veuillez réessayer.';
  }

  // Faire défiler la liste des messages jusqu'en bas
  void _scrollToBottom() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  // Télécharger une image depuis la galerie
  Future<void> _uploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        chatManager.addMessage(ChatMessage(
          sender: 'user',
          text: 'Image : ${pickedFile.path.split('/').last}',
          key: UniqueKey(),
          timestamp: DateTime.now(),
        ));
        _isLoading = true;
      });
      _scrollToBottom();

      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        chatManager.addMessage(ChatMessage(
          sender: 'bot',
          text: 'Analyse d\'image : Réponse placeholder.',
          key: UniqueKey(),
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        chatManager.addMessage(ChatMessage(
          sender: 'bot',
          text: 'Échec du téléchargement de l\'image : $e',
          key: UniqueKey(),
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  // Démarrer un nouveau chat
  void _startNewChat() {
    setState(() {
      chatManager.startNewChat(_settings.username);
    });
    _scrollToBottom();
  }

  // Afficher l'historique des chats
  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: AppColors.cardBackground(_settings.isDarkMode),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historique des chats',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(_settings.isDarkMode),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.textSecondary(_settings.isDarkMode)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: chatManager.chatHistory.isEmpty
                        ? Center(
                            child: Text(
                              'Aucun historique de chat pour le moment.',
                              style: TextStyle(
                                color: AppColors.textSecondary(_settings.isDarkMode),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: chatManager.chatHistory.length,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                key: Key(chatManager.chatHistory[index].first.key.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: AppColors.errorRed,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  setState(() => chatManager.deleteChat(index));
                                },
                                child: Card(
                                  color: AppColors.cardBackground(_settings.isDarkMode),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.accentGreen,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      chatManager.chatHistory[index].first.text.length > 30
                                          ? '${chatManager.chatHistory[index].first.text.substring(0, 30)}...'
                                          : chatManager.chatHistory[index].first.text,
                                      style: TextStyle(
                                        color: AppColors.textPrimary(_settings.isDarkMode),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _formatTimestamp(chatManager.chatHistory[index].first.timestamp),
                                      style: TextStyle(
                                        color: AppColors.textSecondary(_settings.isDarkMode),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.restore,
                                          color: AppColors.textSecondary(_settings.isDarkMode)),
                                      onPressed: () {
                                        setState(() {
                                          chatManager.messages = List.from(chatManager.chatHistory[index]);
                                        });
                                        Navigator.pop(context);
                                        _scrollToBottom();
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Formater la date et l'heure d'un message
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm - dd/MM/yyyy').format(timestamp);
  }

  // Afficher le panneau des paramètres
  void _showSettings() {
    setState(() => _isSettingsOpen = true);
  }

  // Fermer le panneau des paramètres
  void _closeSettings() {
    setState(() => _isSettingsOpen = false);
    _saveSettings();
  }

  // Modifier un message existant
  void _editMessage(ChatMessage message) {
    setState(() {
      _editingMessage = message;
      _controller.text = message.text;
    });
  }

  // Supprimer un message
  void _deleteMessage(ChatMessage message) {
    setState(() {
      chatManager.deleteMessage(message);
    });
  }

  // Vérifier si un message contient du code
  bool _isCodeMessage(String text) {
    return text.contains('```') ||
        text.contains('import') ||
        text.contains('class') ||
        text.contains('function') ||
        text.contains('def') ||
        text.contains('void');
  }

  // Copier le code dans le presse-papiers
  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copié dans le presse-papiers !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _settings.isDarkMode
                  ? [AppColors.darkGreen.withOpacity(0.95), AppColors.darkGreen.withOpacity(0.75)]
                  : [AppColors.primaryGreen.withOpacity(0.95), AppColors.darkGreen.withOpacity(0.75)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 1.0],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(_settings.isDarkMode),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: SafeArea(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow(_settings.isDarkMode),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'ChatSphere',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Roboto',
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: IconButton(
                    icon: const Icon(Icons.history, color: Colors.white, size: 28),
                    onPressed: _showChatHistory,
                    tooltip: 'Historique des chats',
                    splashRadius: 22,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                    onPressed: _startNewChat,
                    tooltip: 'Nouveau chat',
                    splashRadius: 22,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    onPressed: _showSettings,
                    tooltip: 'Paramètres',
                    splashRadius: 22,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background(_settings.isDarkMode),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow(_settings.isDarkMode),
                        spreadRadius: 2,
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: chatManager.messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == chatManager.messages.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _settings.isDarkMode ? const Color(0xFF424242) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadow(_settings.isDarkMode),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    _buildThinkingDots(),
                                    const SizedBox(width: 12),
                                    Text(
                                      '...',
                                      style: TextStyle(
                                        color: AppColors.textSecondary(_settings.isDarkMode),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final message = chatManager.messages[index];
                      final isCode = message.sender == 'bot' && _isCodeMessage(message.text);
                      return GestureDetector(
                        onLongPress: () => _showMessageOptions(message),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: message.sender == 'user'
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  constraints: const BoxConstraints(maxWidth: 300),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: message.sender == 'user'
                                          ? [AppColors.primaryGreen, AppColors.accentGreen]
                                          : _settings.isDarkMode
                                              ? [AppColors.cardBackground(true), const Color(0xFF616161)]
                                              : [AppColors.cardBackground(false), AppColors.lightGreen],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: message.sender == 'user'
                                          ? const Radius.circular(20)
                                          : const Radius.circular(5),
                                      bottomRight: message.sender == 'user'
                                          ? const Radius.circular(5)
                                          : const Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadow(_settings.isDarkMode),
                                        spreadRadius: 2,
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.sender == 'user' ? _settings.username : 'Bot',
                                        style: TextStyle(
                                          color: message.sender == 'user'
                                              ? Colors.white70
                                              : AppColors.textSecondary(_settings.isDarkMode),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      isCode
                                          ? Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppColors.codeBackgroundDark(_settings.isDarkMode),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _settings.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    message.text,
                                                    style: TextStyle(
                                                      fontFamily: 'monospace',
                                                      color: _settings.isDarkMode ? Colors.white : Colors.black87,
                                                      fontSize: _settings.fontSize,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.copy, size: 20),
                                                        color: AppColors.textSecondary(_settings.isDarkMode),
                                                        onPressed: () => _copyCode(message.text),
                                                        tooltip: 'Copier le code',
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.edit, size: 20),
                                                        color: AppColors.textSecondary(_settings.isDarkMode),
                                                        onPressed: () => _editMessage(message),
                                                        tooltip: 'Modifier le code',
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Text(
                                              message.text,
                                              style: TextStyle(
                                                color: message.sender == 'user'
                                                    ? Colors.white
                                                    : AppColors.textPrimary(_settings.isDarkMode),
                                                fontSize: _settings.fontSize,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.2,
                                                height: 1.3,
                                              ),
                                            ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatTimestamp(message.timestamp),
                                            style: TextStyle(
                                              color: AppColors.textSecondary(_settings.isDarkMode),
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (message.isEdited)
                                            Text(
                                              'Modifié',
                                              style: TextStyle(
                                                color: AppColors.textSecondary(_settings.isDarkMode),
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground(_settings.isDarkMode),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow(_settings.isDarkMode),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: _editingMessage != null ? 'Modifier le message...' : 'Posez-moi une question...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary(_settings.isDarkMode),
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground(_settings.isDarkMode),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.attach_file,
                                      color: AppColors.textSecondary(_settings.isDarkMode), size: 24),
                                  onPressed: _uploadImage,
                                  tooltip: 'Télécharger une image',
                                ),
                                if (_editingMessage != null)
                                  IconButton(
                                    icon: Icon(Icons.cancel,
                                        color: AppColors.textSecondary(_settings.isDarkMode), size: 24),
                                    onPressed: () {
                                      setState(() {
                                        _editingMessage = null;
                                        _controller.clear();
                                      });
                                    },
                                    tooltip: 'Annuler la modification',
                                  ),
                              ],
                            ),
                          ),
                          style: TextStyle(
                            fontSize: _settings.fontSize,
                            color: AppColors.textPrimary(_settings.isDarkMode),
                          ),
                          maxLines: 1,
                          onSubmitted: (value) => _sendMessage(value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTapDown: (_) => setState(() => _sendButtonScale = 0.95),
                      onTapUp: (_) => setState(() => _sendButtonScale = 1.0),
                      onTap: _isLoading ? null : () => _sendMessage(_controller.text),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: _sendButtonScale).animate(
                          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
                        ),
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryGreen, AppColors.darkGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _editingMessage != null ? Icons.check : Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isSettingsOpen) _buildSettingsOverlay(),
        ],
      ),
    );
  }

  // Afficher les options d'un message (modifier/supprimer)
  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.cardBackground(_settings.isDarkMode),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.sender == 'user')
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.primaryGreen),
                  title: const Text('Modifier le message'),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(message);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.errorRed),
                title: const Text('Supprimer le message'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
              ListTile(
                leading: Icon(Icons.close, color: AppColors.greyShade),
                title: const Text('Annuler'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // Construire le panneau des paramètres
  Widget _buildSettingsOverlay() {
    return AnimatedOpacity(
      opacity: _isSettingsOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(_settings.isDarkMode),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow(_settings.isDarkMode),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _settings.isDarkMode
                          ? [AppColors.darkGreen, AppColors.darkGreen.withOpacity(0.9)]
                          : [AppColors.primaryGreen, AppColors.darkGreen.withOpacity(0.9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paramètres',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.textSecondary(_settings.isDarkMode)),
                        onPressed: _closeSettings,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nom d\'utilisateur',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(_settings.isDarkMode),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Entrez votre nom d\'utilisateur',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary(_settings.isDarkMode),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: _settings.isDarkMode ? const Color(0xFF616161) : AppColors.lightGreen,
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary(_settings.isDarkMode),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _settings.username = value.isEmpty ? 'Utilisateur' : value;
                    });
                  },
                  controller: TextEditingController(text: _settings.username),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mode sombre',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary(_settings.isDarkMode),
                      ),
                    ),
                    Switch(
                      value: _settings.isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _settings.isDarkMode = value;
                        });
                      },
                      activeColor: AppColors.primaryGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Taille de la police',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(_settings.isDarkMode),
                  ),
                ),
                Slider(
                  value: _settings.fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  label: _settings.fontSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _settings.fontSize = value;
                    });
                  },
                  activeColor: AppColors.primaryGreen,
                  inactiveColor: AppColors.greyShade.withOpacity(0.3),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _closeSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Center(
                    child: Text(
                      'Enregistrer & Fermer',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construire les points animés pour indiquer que le bot "pense"
  Widget _buildThinkingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, math.sin(_animationController.value * 2 * math.pi + index * 1.2) * 6),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _settings.isDarkMode
                        ? [AppColors.accentGreen, AppColors.primaryGreen]
                        : [AppColors.primaryGreen, AppColors.accentGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}