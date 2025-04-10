import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin { // استخدام TickerProviderStateMixin لدعم الرسوم المتحركة إذا لزم الأمر
  final PageController _controller = PageController();
  bool isLastPage = false;
  String userType = '';
  int currentPage = 0;

  // Contrôleurs pour les animations principales
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Contrôleur pour l'animation des icônes dans la page de sélection
  late AnimationController _iconAnimationController;
  late Animation<double> _iconScaleAnimation;

  Map<String, String> userAnswers = {};
  double questionProgress = 0.0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Bienvenue sur notre marché',
      'description':
          'Découvrez un monde de produits incroyables et connectez-vous avec des vendeurs du monde entier.',
      'gif': 'assets/gifs/welcome.gif', // GIF للصفحة الأولى
      'bgColor': const Color(0xFFF0F8FF),
      'textColor': const Color(0xFF1E3A8A),
    },
    {
      'title': 'Choisissez votre chemin',
      'description':
          'Êtes-vous ici pour acheter des produits incroyables ou vendre vos propres créations ?',
      'gif': 'assets/gifs/page2.gif', // GIF لصفحة اختيار النوع
      'bgColor': const Color(0xFFF0FFF4),
      'textColor': const Color(0xFF166534),
    },
    {
      'title': 'Personnalisez votre expérience',
      'description': 'Répondez à quelques questions pour personnaliser votre parcours.',
      'gif': 'assets/gifs/page3.gif', // GIF لصفحة الأسئلة
      'bgColor': const Color(0xFFFFF0F5),
      'textColor': const Color(0xFF9D174D),
    },
    {
      'title': 'Prêt à commencer',
      'description': 'Votre marché personnalisé vous attend !',
      'gif': 'assets/gifs/page4.gif', // GIF لصفحة "Prêt à commencer"
      'bgColor': const Color(0xFFFFF7ED),
      'textColor': const Color(0xFF9A3412),
    },
  ];

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Quel est votre principal intérêt ?',
      'options': ['Mode', 'Électronique', 'Articles ménagers', 'Objets faits main'],
      'key': 'interest',
    },
    {
      'question': 'À quelle fréquence achetez-vous en ligne ?',
      'options': ['Quotidien', 'Hebdomadaire', 'Mensuel', 'Rarement'],
      'key': 'shopping_frequency',
    },
    {
      'question': 'Quelle est votre gamme de budget ?',
      'options': ['Moins de 50\$', '50\$ - 100\$', '100\$ - 200\$', 'Plus de 200\$'],
      'key': 'budget',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Animation principale pour les transitions de page
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Animation pour les icônes
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeInOut),
    );
    _iconAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  // Sauvegarder l'état de l'intégration
  Future<void> _saveOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingCompleted', true);
      await prefs.setString('userType', userType);
      await prefs.setString('interest', userAnswers['interest'] ?? '');
      await prefs.setString('shopping_frequency', userAnswers['shopping_frequency'] ?? '');
      await prefs.setString('budget', userAnswers['budget'] ?? '');
      await prefs.commit();
    } catch (e) {
      print("Erreur lors de la sauvegarde de l'état d'intégration : $e");
    }
  }

  // Mettre à jour la progression des questions
  void _updateQuestionProgress(int currentQuestionIndex) {
    setState(() {
      questionProgress = (currentQuestionIndex + 1) / _questions.length;
    });
  }

  // Récupérer l'utilisateur actuel depuis Firebase
  UserModel _getCurrentUser() {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? 'pas d\'email',
        isEmailVerified: firebaseUser.emailVerified,
      );
    } else {
      return UserModel(
        uid: 'pas d\'uid',
        email: 'pas d\'email',
        isEmailVerified: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          !isLastPage
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: TextButton(
                    onPressed: () {
                      _controller.jumpToPage(_onboardingData.length - 1);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueGrey[800],
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'PASSER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isLastPage
                  ? const Color(0xFFFFF7ED)
                  : _onboardingData[currentPage]['bgColor'],
              isLastPage ? const Color(0xFFFFEDD5) : Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Éléments décoratifs de fond avec animation
            Positioned(
              top: -60,
              right: -40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 2000),
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 2000),
                height: 280,
                width: 280,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),

            // Contenu de la vue des pages
            PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                  isLastPage = index == _onboardingData.length - 1;
                  _animationController.reset();
                  _animationController.forward();
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                if (index == 1) {
                  return buildUserTypeSelectionPage(
                    _onboardingData[index]['title'],
                    _onboardingData[index]['description'],
                    _onboardingData[index]['gif'],
                    _onboardingData[index]['bgColor'],
                    _onboardingData[index]['textColor'],
                    screenHeight,
                    screenWidth,
                  );
                }
                if (index == 2) {
                  return buildQuestionPage(
                    _onboardingData[index]['title'],
                    _onboardingData[index]['description'],
                    _onboardingData[index]['gif'],
                    _onboardingData[index]['bgColor'],
                    _onboardingData[index]['textColor'],
                    screenHeight,
                    screenWidth,
                  );
                }
                if (index == 3) {
                  String title = userType == 'buyer'
                      ? 'Explorez votre marché'
                      : userType == 'seller'
                          ? 'Commencez à vendre aujourd\'hui'
                          : _onboardingData[index]['title'];
                  String description = userType == 'buyer'
                      ? 'Trouvez des produits uniques adaptés à vos centres d’intérêt.'
                      : userType == 'seller'
                          ? 'Atteignez les clients et développez votre activité facilement.'
                          : _onboardingData[index]['description'];

                  return buildOnboardingPage(
                    title,
                    description,
                    _onboardingData[index]['gif'],
                    _onboardingData[index]['bgColor'],
                    _onboardingData[index]['textColor'],
                    screenHeight,
                    screenWidth,
                  );
                }
                // الصفحة الأولى (0) تعرض GIF
                return buildOnboardingPage(
                  _onboardingData[index]['title'],
                  _onboardingData[index]['description'],
                  _onboardingData[index]['gif'],
                  _onboardingData[index]['bgColor'],
                  _onboardingData[index]['textColor'],
                  screenHeight,
                  screenWidth,
                );
              },
            ),

            // Conteneur de navigation inférieur
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                height: 140,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SmoothPageIndicator(
                            controller: _controller,
                            count: _onboardingData.length,
                            effect: ExpandingDotsEffect(
                              spacing: 10,
                              dotWidth: 10,
                              dotHeight: 10,
                              dotColor: Colors.grey.shade300,
                              activeDotColor: Theme.of(context).primaryColor,
                              expansionFactor: 3,
                            ),
                            onDotClicked: (index) {
                              _controller.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          isLastPage
                              ? buildGetStartedButton()
                              : buildNextButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construire une page d'intégration avec GIF
  Widget buildOnboardingPage(
    String title,
    String description,
    String gifPath,
    Color bgColor,
    Color textColor,
    double screenHeight,
    double screenWidth,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 100, 30, 160),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                gifPath,
                height: screenHeight * 0.35,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: screenHeight * 0.35,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          Text(
                            'Erreur de chargement de l\'image',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      color: textColor.withOpacity(0.2),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: screenWidth * 0.85,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  description,
                  style: TextStyle(
                    color: textColor.withOpacity(0.85),
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construire la page de sélection du type d'utilisateur avec GIF
  Widget buildUserTypeSelectionPage(
    String title,
    String description,
    String gifPath,
    Color bgColor,
    Color textColor,
    double screenHeight,
    double screenWidth,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 100, 30, 160),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                gifPath,
                height: screenHeight * 0.25,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: screenWidth * 0.85,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  description,
                  style: TextStyle(
                    color: textColor.withOpacity(0.85),
                    fontSize: 16,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              buildUserTypeOption(
                'ACHETEUR',
                'Explorez et achetez des produits uniques.',
                'assets/svg/shopping_bag_icon.svg',
                userType == 'buyer',
                () {
                  setState(() {
                    userType = 'buyer';
                  });
                },
              ),
              const SizedBox(height: 20),
              buildUserTypeOption(
                'VENDEUR',
                'Vendez vos créations et développez votre entreprise.',
                'assets/svg/store_icon.svg',
                userType == 'seller',
                () {
                  setState(() {
                    userType = 'seller';
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construire la page des questions avec GIF
  Widget buildQuestionPage(
    String title,
    String description,
    String gifPath,
    Color bgColor,
    Color textColor,
    double screenHeight,
    double screenWidth,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 100, 30, 160),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                gifPath,
                height: screenHeight * 0.25,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: screenWidth * 0.85,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  description,
                  style: TextStyle(
                    color: textColor.withOpacity(0.85),
                    fontSize: 16,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: questionProgress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: buildQuestionCard(
                        _questions[index]['question'],
                        _questions[index]['options'],
                        _questions[index]['key'],
                        index,
                        screenWidth,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construire une carte de question
  Widget buildQuestionCard(
    String question,
    List<String> options,
    String key,
    int questionIndex,
    double screenWidth,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...options.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    userAnswers[key] = option;
                    _updateQuestionProgress(questionIndex);
                  });
                },
                child: Container(
                  width: screenWidth * 0.8,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: userAnswers[key] == option
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: userAnswers[key] == option
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: userAnswers[key] == option
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                      fontSize: 16,
                      fontWeight: userAnswers[key] == option
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Construire une option de type d'utilisateur avec SVG animé
  Widget buildUserTypeOption(
    String title,
    String subtitle,
    String svgPath,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _iconAnimationController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: isSelected ? 10 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: isSelected ? _iconScaleAnimation.value : 1.0,
                    child: SvgPicture.asset(
                      svgPath,
                      width: 28,
                      height: 28,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : const SizedBox(width: 18, height: 18),
            ),
          ],
        ),
      ),
    );
  }

  // Construire le bouton "Suivant"
  Widget buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          _controller.nextPage(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
        ),
        child: const Text(
          'Suivant',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // Construire le bouton "Commencer"
  Widget buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          if (userType.isEmpty) {
            _controller.previousPage(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Veuillez sélectionner si vous voulez acheter ou vendre.',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(12),
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (userAnswers.length < _questions.length) {
            _controller.animateToPage(
              2,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Veuillez répondre à toutes les questions pour continuer.',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.orangeAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(12),
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            await _saveOnboardingCompleted();
            await Future.delayed(const Duration(milliseconds: 300));

            if (mounted) {
              User? firebaseUser = FirebaseAuth.instance.currentUser;
              if (firebaseUser == null) {
                Navigator.of(context).pushReplacementNamed('/login');
              } else {
                Navigator.of(context).pushReplacementNamed('/main');
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
        ),
        child: const Text(
          'Commencer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}