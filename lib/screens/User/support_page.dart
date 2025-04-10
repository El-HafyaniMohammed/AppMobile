// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Modèle pour une demande de support
class SupportRequest {
  final String? userId;
  final String subject;
  final String message;
  final String? category;
  final String contactMethod;
  final DateTime? timestamp;

  SupportRequest({
    this.userId,
    required this.subject,
    required this.message,
    this.category,
    required this.contactMethod,
    this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'subject': subject,
        'message': message,
        'category': category,
        'contactMethod': contactMethod,
        'timestamp': timestamp ?? FieldValue.serverTimestamp(),
        'isResolved': false,
      };
}

// Modèle pour une entrée FAQ
class FAQEntry {
  final String question;
  final String answer;

  FAQEntry({required this.question, required this.answer});
}

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // Contrôleurs
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  // État
  bool _isSubmitting = false;
  String? _selectedCategory;
  String _selectedContactMethod = 'Email';
  bool _isDarkMode = false; // Ajout du toggle pour le mode sombre

  // Données
  final List<String> _supportCategories = [
    'Problème technique',
    'Question sur le paiement',
    'Demande de fonctionnalité',
    'Autre',
  ];

  final List<String> _contactMethods = ['Email', 'Facebook', 'Instagram'];

  final List<FAQEntry> _faqEntries = [
    FAQEntry(question: 'Comment changer mon mot de passe ?', answer: 'Allez dans votre profil, sélectionnez "Modifier le mot de passe".'),
    FAQEntry(question: 'Où voir mes commandes ?', answer: 'Dans la section "Mes commandes" de votre profil.'),
    FAQEntry(question: 'Comment annuler une commande ?', answer: 'Contactez le support dans les 24h.'),
    FAQEntry(question: 'Pourquoi mon paiement est refusé ?', answer: 'Vérifiez vos informations ou contactez votre banque.'),
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitSupportRequest() async {
    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs.', accentColor);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final request = SupportRequest(
        userId: FirebaseAuth.instance.currentUser?.uid,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        category: _selectedCategory,
        contactMethod: _selectedContactMethod,
      );
      await FirebaseFirestore.instance.collection('support_requests').add(request.toMap());
      _showSnackBar('Demande envoyée avec succès !', primaryColor);
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedContactMethod = 'Email';
      });
    } catch (e) {
      _showSnackBar('Erreur : $e', accentColor);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: _isDarkMode ? Colors.black : Colors.white, fontSize: 14)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  // Couleurs définies pour les deux modes
  Color get primaryColor => const Color(0xFF2ECC71); // Vert
  Color get accentColor => const Color(0xFFE74C3C); // Rouge
  Color get backgroundColor => _isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FD);
  Color get cardColor => _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 400),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    const SizedBox(height: 20),
                    _buildSupportFormSection(),
                    const SizedBox(height: 30),
                    _buildFAQSection(),
                    const SizedBox(height: 30),
                    _buildContactSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Support',
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, primaryColor.withOpacity(0.85)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(_isDarkMode ? 0.05 : 0.15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
          onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
        ),
      ],
    );
  }

  Widget _buildSupportFormSection() {
    return _buildSection(
      'Envoyer une Demande',
      Column(
        children: [
          _buildTextField(_subjectController, 'Sujet', Icons.subject),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: Text('Choisir une catégorie', style: TextStyle(color: textColor.withOpacity(0.6))),
            items: _supportCategories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: textColor)))).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            decoration: _inputDecoration('Catégorie', Icons.category),
            dropdownColor: cardColor,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedContactMethod,
            items: _contactMethods.map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(color: textColor)))).toList(),
            onChanged: (value) => setState(() => _selectedContactMethod = value!),
            decoration: _inputDecoration('Méthode de contact', Icons.contact_support),
            dropdownColor: cardColor,
          ),
          const SizedBox(height: 16),
          _buildTextField(_messageController, 'Message', Icons.message, maxLines: 4),
          const SizedBox(height: 24),
          _buildButton('Envoyer', _submitSupportRequest, _isSubmitting),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return _buildSection(
      'Questions Fréquentes',
      Column(
        children: _faqEntries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              e.question,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 16,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  e.answer,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            collapsedBackgroundColor: cardColor,
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      'Nous Contacter',
      Column(
        children: [
          _buildContactItem('Email', 'support@votreapp.com', Icons.email, primaryColor),
          const SizedBox(height: 16),
          _buildContactItem('Téléphone', '+212 123 456 789', Icons.phone, primaryColor),
          const SizedBox(height: 12),
          Text(
            'Disponible 24/7',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
      style: TextStyle(color: textColor, fontSize: 16),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 16),
      prefixIcon: Icon(icon, color: primaryColor, size: 24),
      filled: true,
      fillColor: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: primaryColor.withOpacity(0.3),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
    );
  }

  Widget _buildContactItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(_isDarkMode ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}