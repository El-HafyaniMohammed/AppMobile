// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../screens/user_page.dart';  // Assurez-vous que cela pointe vers votre page de profil
// // ignore: unused_import
// import '../screens/main_screen.dart';  // Assurez-vous d'importer MainScreen pour la navigation

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;
//   bool _passwordVisible = false;
//   // ignore: unused_field, prefer_final_fields
//   bool _confirmPasswordVisible = false;
//   String? _error;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   // Méthode de gestion d'inscription
//  void _handleSignup() async {
//   // Vérifie si le formulaire est valide
//   if (!(_formKey.currentState?.validate() ?? false)) {
//     return;
//   }

//   // Activation de l'état de chargement
//   setState(() {
//     _isLoading = true;
//     _error = null;
//   });

//   try {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final displayName = _nameController.text.trim();

//     // Création du compte utilisateur avec Firebase Authentication
//     UserCredential userCredential = await FirebaseAuth.instance
//         .createUserWithEmailAndPassword(email: email, password: password);

//     // Mise à jour du profil utilisateur avec le nom affiché
//     await userCredential.user?.updateDisplayName(displayName);

//     // Redirige l'utilisateur vers la page de profil
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const ProfilePage(),
//         ),
//       );
      
//       // Message de succès
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Account created successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }

//   } on FirebaseAuthException catch (e) {
//     // Gestion des erreurs spécifiques à Firebase
//     String errorMessage;
//     switch (e.code) {
//       case 'email-already-in-use':
//         errorMessage = 'An account already exists with this email.';
//         break;
//       case 'weak-password':
//         errorMessage = 'The password is too weak.';
//         break;
//       case 'invalid-email':
//         errorMessage = 'The email address is invalid.';
//         break;
//       default:
//         errorMessage = e.message ?? 'An unknown error occurred.';
//     }
    
//     if (mounted) {
//       setState(() => _error = errorMessage);
//     }
    
//   } catch (e) {
//     // Gestion des erreurs imprévues
//     if (mounted) {
//       setState(() => _error = 'An unexpected error occurred. Please try again.');
//     }
//   } finally {
//     // Désactivation de l'état de chargement
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 // Logo et titre
//                 Center(
//                   child: Image.asset("assets/img/9game_logo.png", height: 120),
//                 ),
//                 Center(
//                   child: RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       style: const TextStyle(fontSize: 20, color: Colors.black),
//                       children: [
//                         const TextSpan(text: 'Welcome to '),
//                         TextSpan(
//                           text: '9Game',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF4CAF50),
//                           ),
//                         ),
//                         const TextSpan(text: ' Store '),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const Center(
//                   child: Text(
//                     'Create an account to start managing your\nproject, task, and productivity',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey, height: 1.5),
//                   ),
//                 ),
//                 // Boutons de navigation vers Login / Sign Up
//                 Row(
//                   children: [
//                     Column(
//                       children: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: const Text(
//                             'Login',
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           width: 40,
//                           height: 3,
//                           color: Colors.transparent,
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     Column(
//                       children: [
//                         const Text(
//                           'Sign Up',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           width: 40,
//                           height: 3,
//                           decoration: const BoxDecoration(
//                             color: Color(0xFF4CAF50),
//                             borderRadius: BorderRadius.all(Radius.circular(10)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 // Formulaire d'inscription
//                 const SizedBox(height: 12),
//                 if (_error != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Text(
//                       _error!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 // Champs de formulaire
//                 _buildInputField(
//                   controller: _nameController,
//                   hint: 'Enter your full name',
//                   icon: Icons.person_outline,
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) return 'Name is required';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 _buildInputField(
//                   controller: _emailController,
//                   hint: 'Enter your email',
//                   icon: Icons.email_outlined,
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) return 'Email is required';
//                     if (!value!.contains('@')) return 'Invalid email format';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 _buildInputField(
//                   controller: _passwordController,
//                   hint: 'Create password',
//                   icon: Icons.lock_outline,
//                   isPassword: true,
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) return 'Password is required';
//                     if (value!.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 _buildInputField(
//                   controller: _confirmPasswordController,
//                   hint: 'Confirm password',
//                   icon: Icons.lock_outline,
//                   isPassword: true,
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) {
//                       return 'Please confirm your password';
//                     }
//                     if (value != _passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 40,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _handleSignup,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF98DC7C),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 24,
//                             width: 24,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text(
//                             'Sign Up',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       style: const TextStyle(color: Colors.grey),
//                       children: [
//                         const TextSpan(
//                             text: 'By signing up, you agree to our '),
//                         TextSpan(
//                           text: 'Terms of service',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).primaryColor,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                         const TextSpan(text: ' and '),
//                         TextSpan(
//                           text: 'Privacy policy',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).primaryColor,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavBar(),
//     );
//   }

//   // Constructeur de bouton social
//   // ignore: unused_element
//   Widget _buildSocialButton({
//     required VoidCallback onPressed,
//     required String icon,
//     required String label,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       height: 40,
//       child: OutlinedButton.icon(
//         onPressed: onPressed,
//         icon: Image.asset(icon, height: 24),
//         label: Text(
//           label,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//           ),
//         ),
//         style: OutlinedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           side: BorderSide(color: Colors.grey.shade300),
//         ),
//       ),
//     );
//   }

//   // Champ de texte personnalisé
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     bool isPassword = false,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword && !_passwordVisible,
//       validator: validator,
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixIcon: Icon(icon, color: Colors.grey),
//         suffixIcon: isPassword
//             ? IconButton(
//                 icon: Icon(
//                   _passwordVisible
//                       ? Icons.visibility_off_outlined
//                       : Icons.visibility_outlined,
//                   color: Colors.grey,
//                 ),
//                 onPressed: () =>
//                     setState(() => _passwordVisible = !_passwordVisible),
//               )
//             : null,
//         filled: true,
//         fillColor: Colors.grey[100],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF4CAF50)),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//       ),
//     );
//   }

//   // Barre de navigation inférieure
//   Widget _buildBottomNavBar() {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: const Color(0xFF4CAF50),
//       unselectedItemColor: Colors.grey,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home_outlined),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.favorite_outline),
//           label: 'Favorites',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.shopping_cart_outlined),
//           label: 'Cart',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person_outline),
//           label: 'Profile',
//         ),
//       ],
//     );
//   }
// }
