// ignore_for_file: unused_field
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
// ignore: unused_import
import 'user_page.dart';
import '../main_screen.dart';
import 'ForgotPasswordPage.dart';
import 'package:flutter/gestures.dart';
import 'privacy_and_terms.dart';

// For mobile image picker
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _AuthScreensState();
}

class _AuthScreensState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void switchToSignup() {
    _tabController.animateTo(1,
        duration: _animationDuration, curve: _animationCurve);
  }

  void switchToLogin() {
    _tabController.animateTo(0,
        duration: _animationDuration, curve: _animationCurve);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Image.asset("assets/img/9game_logo.png", height: 120),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        children: [
                          TextSpan(text: 'Welcome to '),
                          TextSpan(
                            text: '9Game',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          TextSpan(text: ' Store '),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tabController.index == 0
                        ? 'Sign up or login below to manage your\nproject, task, and productivity'
                        : 'Create an account to start managing your\nproject, task, and productivity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTabButton('Login', 0),
                      _buildTabButton('Sign Up', 1),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  LoginContent(onSignupTap: switchToSignup),
                  SignupContent(onLoginTap: switchToLogin),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return Column(
      children: [
        TextButton(
          onPressed: () => _tabController.animateTo(index,
              duration: _animationDuration, curve: _animationCurve),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ],
    );
  }
}

class LoginContent extends StatefulWidget {
  final VoidCallback onSignupTap;

  const LoginContent({super.key, required this.onSignupTap});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _error;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Ajoutez cette méthode pour gérer la connexion Google
  // ignore: unused_element
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Démarrer le processus de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        setState(() => _isLoading = false);
        return;
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer les credentials Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Connecter avec Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);
      // ignore: unused_local_variable
      final user =
          UserModel.fromFirebaseUser(FirebaseAuth.instance.currentUser!);
      if (mounted) {
        // Naviguer vers l'écran principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen(user: user)),
        );

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged in with Google'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage = 'An account already exists with this email.';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid credentials.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Google sign-in is not enabled.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found for this email.';
            break;
          default:
            errorMessage = 'An error occurred during Google sign-in.';
        }
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }

      if (mounted) {
        setState(() => _error = errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Connexion avec Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Vérifier si l'utilisateur a un panier
      final userId = userCredential.user!.uid;
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      // Si l'utilisateur n'a pas de panier, en créer un vide
      if (cartSnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc('initial')
            .set({
          'createdAt': DateTime.now(), // Optionnel : date de création du panier
        });
      }

      // Créer une collection `favorites` vide pour l'utilisateur
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      if (favoritesSnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc('initial')
            .set({
          'createdAt':
              DateTime.now(), // Optionnel : date de création des favoris
        });
      }
      // cree une collection pour les adresses
      final addressesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();
      if (addressesSnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc('initial')
            .set({
          'createdAt':
              DateTime.now(), // Optionnel : date de création des favoris
        });
      }
      // cree une collection pour les cartes de payement
      // ignore: non_constant_identifier_names
      final PayementCardSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('payementCard')
          .get();
      if (PayementCardSnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('payementCard')
            .doc('initial')
            .set({
          'createdAt':
              DateTime.now(), // Optionnel : date de création des favoris
        });
      }
      // Récupérer les informations de l'utilisateur depuis Firestore
      final user = await UserModel.getUserFromFirestore(userId);
      if (user == null) {
        // Si l'utilisateur n'existe pas dans Firestore, créer un nouvel utilisateur
        final newUser = UserModel.fromFirebaseUser(userCredential.user!);
        await newUser.saveToFirestore();
        await newUser.updateLastLogin();
      } else {
        // Mettre à jour la dernière connexion
        await user.updateLastLogin();
      }

      // Rediriger vers l'écran principal
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
                user: user ?? UserModel.fromFirebaseUser(userCredential.user!)),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage = 'An error occurred during login. Please try again.';
      }

      if (mounted) {
        setState(() => _error = errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _error = 'An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildSocialButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      await _handleGoogleSignIn();
                    },
              icon: 'assets/img/google_icon.png',
              label: 'Login with Google',
            ),
            const SizedBox(height: 10),
            const Text(
              'or continue with email',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            _buildInputField(
              controller: _emailController,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!value!.contains('@')) return 'Invalid email format';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _passwordController,
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password is required';
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98DC7C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_passwordVisible,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

class SignupContent extends StatefulWidget {
  final VoidCallback onLoginTap;

  const SignupContent({super.key, required this.onLoginTap});

  @override
  State<SignupContent> createState() => _SignupContentState();
}

class _SignupContentState extends State<SignupContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  final bool _confirmPasswordVisible = false;
  String? _error;
  Timer? _timer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail(User user) async {
    await user.sendEmailVerification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Verification email has been sent. Please check your inbox.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _startEmailVerificationCheck(User user) {
    // Annuler le timer existant s'il y en a un
    _timer?.cancel();

    // Créer un nouveau timer qui vérifie toutes les 3 secondes
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Recharger l'utilisateur pour obtenir le dernier état
      await user.reload();

      // Obtenir l'utilisateur mis à jour
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser?.emailVerified ?? false) {
        // Annuler le timer
        timer.cancel();

        if (mounted) {
          // Fermer la boîte de dialogue
          final user = UserModel.fromFirebaseUser(updatedUser!);
          Navigator.of(context).pop();

          // Rediriger vers la page principale
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainScreen(user: user),
            ),
          );

          // Afficher le message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account verified successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }

  void _handleSignup() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final displayName = _nameController.text.trim();

      // Créer l'utilisateur dans Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Mettre à jour le nom d'affichage de l'utilisateur
      await userCredential.user?.updateDisplayName(displayName);

      // Créer un panier vide pour l'utilisateur dans Firestore
      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc('initial')
            .set({
          'createdAt': DateTime.now(), // Optionnel : date de création du panier
        });

        // Créer une collection `favorites` vide pour l'utilisateur
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc('initial')
            .set({
          'createdAt':
              DateTime.now(), // Optionnel : date de création des favoris
        });
        // cree une collection pour les adresses
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc('initial')
            .set({
          'createdAt':
              DateTime.now(), // Optionnel : date de création des favoris
        });
        // cree une collection pour les cartes de payement
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('payementCard')
            .doc('initial')
            .set({
          'createdAt':
              DateTime.now(), // Optionnel : date de création des favoris
        });
        // Créer un nouvel utilisateur dans Firestore
        final newUser = UserModel.fromFirebaseUser(userCredential.user!);
        await newUser.saveToFirestore();

        // Envoyer un e-mail de vérification
        await _sendVerificationEmail(userCredential.user!);

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async =>
                    false, // Empêche de fermer avec le bouton retour
                child: AlertDialog(
                  title: const Text('Email Verification Required'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Please check your email and click the verification link. '
                        'The app will automatically detect when you verify your email.',
                      ),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (userCredential.user != null) {
                          _sendVerificationEmail(userCredential.user!);
                        }
                      },
                      child: const Text('Resend Email'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Se déconnecter et retourner à l'écran de connexion
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context)
                              .pop(); // Fermer la boîte de dialogue
                          // ignore: use_build_context_synchronously
                          Navigator.of(context)
                              .pop(); // Retourner à l'écran précédent
                        }
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          );
          // Démarrer la vérification automatique
          _startEmailVerificationCheck(userCredential.user!);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred.';
      }

      if (mounted) {
        setState(() => _error = errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _error = 'An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 15),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            _buildInputField(
              controller: _nameController,
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _emailController,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!value!.contains('@')) return 'Invalid email format';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _passwordController,
              hint: 'Create password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password is required';
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _confirmPasswordController,
              hint: 'Confirm password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98DC7C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_passwordVisible,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// Shared widgets for both Login and Signup
Widget _buildSocialButton({
  required void Function()? onPressed,
  required String icon,
  required String label,
}) {
  return SizedBox(
    width: double.infinity,
    height: 40,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(icon, height: 24),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  );
}

Widget _buildTermsText() {
  return Builder(
    builder: (context) => RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(color: Colors.grey),
        children: [
          const TextSpan(text: 'By signing up, you agree to our '),
          TextSpan(
            text: 'Terms of service',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TermsOfServicePage()),
                );
              },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy policy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage()),
                );
              },
          ),
        ],
      ),
    ),
  );
}
