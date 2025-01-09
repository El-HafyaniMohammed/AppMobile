import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_page.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
  // 1. Validate form first
  if (!(_formKey.currentState?.validate() ?? false)) {
    return;
  }

  // 2. Update loading state
  setState(() {
    _isLoading = true;
    _error = null;  // Reset any previous errors
  });

  try {
    // 3. Attempt Firebase login
    // ignore: unused_local_variable
    final UserCredential userCredential = 
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // 4. Handle successful login
    if (mounted) {
      // Navigate to home page or call success callback
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
      
      // Optional: Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged in'),
          backgroundColor: Colors.green,
        ),
      );
    }

  } on FirebaseAuthException catch (e) {
    // 5. Handle specific Firebase Auth errors
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
    // 6. Handle any other unexpected errors
    if (mounted) {
      setState(() => _error = 'An unexpected error occurred. Please try again.');
    }
  } finally {
    // 7. Always reset loading state if widget is still mounted
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
              onPressed: () {},
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
                onPressed: () {},
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
  // ignore: unused_field
  bool _confirmPasswordVisible = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Home Screen')),
            ),
          ),
        );
      } catch (e) {
        setState(() => _error = e.toString());
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
              onPressed: () {},
              icon: 'assets/img/google_icon.png',
              label: 'Sign up with Google',
            ),
            const SizedBox(height: 10),
            const Text(
              'or sign up with email',
              style: TextStyle(color: Colors.grey),
            ),
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
  required VoidCallback onPressed,
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
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy policy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    ),
  );
}
