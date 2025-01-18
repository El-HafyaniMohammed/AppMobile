import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'phone_verification_dialog.dart';
import 'dart:io';
class ProfilePage extends StatefulWidget {
  final UserModel user;
  
  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage>{
  late final UserModel user = widget.user;
  // ignore: unused_field
  late TextEditingController _nameController;
  // ignore: unused_field
  late TextEditingController _phoneController;
  // ignore: unused_field, prefer_final_fields
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Récupérer les données depuis Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          _nameController = TextEditingController(
            text: userData?['displayName'] ?? _formatName(widget.user.email.split('@').first)
          );
          // Utiliser le numéro de téléphone de Firestore en priorité, puis celui de Firebase Auth
          _phoneController = TextEditingController(
            text: userData?['phoneNumber'] ?? currentUser.phoneNumber ?? ''
          );
        });
      } else {
        _nameController = TextEditingController(text: _formatName(widget.user.email.split('@').first));
        _phoneController = TextEditingController(text: currentUser.phoneNumber ?? '');
      }
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String formatMoroccanPhoneNumber(String phone) {
  // Supprimer tous les espaces et caractères spéciaux
  phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  
  // Si le numéro commence par +212, c'est déjà au bon format
  if (phone.startsWith('+212')) {
    return phone;
  }
  
  // Si le numéro commence par 212
  if (phone.startsWith('212')) {
    return '+$phone';
  }
  
  // Si le numéro commence par 0
  if (phone.startsWith('0')) {
    return '+212${phone.substring(1)}';
  }
  
  // Si le numéro ne commence ni par 0 ni par 212
  // On suppose que c'est un numéro sans préfixe
  if (phone.length >= 9) {
    return '+212$phone';
  }
  
  // Si le format ne correspond à aucun cas
  throw Exception('Format de numéro invalide');
}
   Future<void> _handleEditProfile() async {
  if (_isEditing) {
    // ... (validation du nom inchangée)

    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isNotEmpty) {
      // Formatage du numéro de téléphone
      String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isNotEmpty) {
      try {
        // Formater le numéro marocain
        phoneNumber = formatMoroccanPhoneNumber(phoneNumber);
        
        // Vérifier si le format est correct pour un numéro marocain
        if (!RegExp(r'^\+212[5-7][0-9]{8}$').hasMatch(phoneNumber)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format de numéro marocain invalide. Utilisez le format 06XXXXXXXX ou 07XXXXXXXX'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Le reste du code reste identique...
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format de numéro invalide. Utilisez le format 06XXXXXXXX ou 07XXXXXXXX'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
      
      // Vérifier si le numéro a changé
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && phoneNumber != currentUser.phoneNumber) {
        // Afficher le dialogue de vérification
        // ignore: use_build_context_synchronously
        final verified = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => PhoneVerificationDialog(phoneNumber: phoneNumber),
        );

        if (verified != true) {
          return; // L'utilisateur a annulé ou la vérification a échoué
        }
      }
    }

    // Continuer avec la mise à jour des autres informations...
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Mise à jour du nom...
        List<String> nameParts = _nameController.text.trim().split(' ');
        String firstName = nameParts.first;
        String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'displayName': _nameController.text.trim(),
          'firstName': firstName,
          'lastName': lastName,
          'email': currentUser.email,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await currentUser.updateDisplayName(_nameController.text.trim());

        setState(() {
          _isEditing = false;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour : ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else {
    setState(() {
      _isEditing = true;
    });
  }
}

  
  Future<void> _pickImage() async {
  // ignore: no_leading_underscores_for_local_identifiers
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
     // ignore: avoid_print
    print('Image sélectionnée : ${image.path}');
    File imageFile = File(image.path);
    String? imageUrl = await user.uploadImage(imageFile);

    if (imageUrl != null) {
      await user.updateUserInfo(newPhotoURL: imageUrl);
      setState(() {
        user.photoURL = imageUrl; // Assurez-vous que cette ligne est exécutée
      });
    }
  }
}

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/main',  // Changé de '/main' à '/login'
          (Route<dynamic> route) => false
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _handleDeleteAccount(BuildContext context) async {
    // Première confirmation
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre compte ? '
            'Cette action est irréversible et toutes vos données seront perdues.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Seconde confirmation avec mot de passe
      final passwordController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pour des raisons de sécurité, veuillez entrer votre mot de passe '
                  'pour confirmer la suppression du compte.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Confirmer la suppression'),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        try {
          // Récupérer l'utilisateur actuel
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Réauthentifier l'utilisateur
            final email = user.email;
            if (email != null) {
              final credential = EmailAuthProvider.credential(
                email: email,
                password: passwordController.text,
              );
              
              await user.reauthenticateWithCredential(credential);
              // Supprimer le compte
              await user.delete();
              
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/main',
                (Route<dynamic> route) => false,
              );
              
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Votre compte a été supprimé avec succès.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          String errorMessage = 'Une erreur est survenue.';
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'wrong-password':
                errorMessage = 'Mot de passe incorrect.';
                break;
              case 'too-many-requests':
                errorMessage = 'Trop de tentatives. Veuillez réessayer plus tard.';
                break;
              default:
                errorMessage = e.message ?? 'Une erreur est survenue.';
            }
          }
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStats(),
                _buildMenuSection(),
                _buildPersonalInfoSection(),
                _buildPreferencesSection(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _handleLogout(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                  Colors.green.shade800,
                  Colors.green.shade500,
                  Colors.green.shade300,
                  ],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : const NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcyI9Cvp53aaP9XeRn-ZKbJDH2QaWC72O26A&s'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _pickImage, // Ouvrir la galerie pour choisir une image
                        color: Colors.blue,
                      ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formatName(user.email.split('@').first),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (user.isEmailVerified) // Vérifiez si l'email est vérifié
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Vérifié',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
              icon: Icons.shopping_bag, value: '12', label: 'Commandes'),
          _buildVerticalDivider(),
          _buildStatItem(
              icon: Icons.local_shipping, value: '2', label: 'En cours'),
          _buildVerticalDivider(),
          _buildStatItem(icon: Icons.favorite, value: '5', label: 'Favoris'),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.shopping_bag,
            title: 'Mes commandes',
            subtitle: 'Voir l\'historique des commandes',
            color: Colors.blue,
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.favorite,
            title: 'Liste de souhaits',
            subtitle: 'Articles sauvegardés',
            color: Colors.red,
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.location_on,
            title: 'Adresses',
            subtitle: 'Gérer les adresses de livraison',
            color: Colors.green,
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.payment,
            title: 'Paiement',
            subtitle: 'Cartes et méthodes de paiement',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  String _formatName(String rawName) {
    // Supprimer les chiffres et les points
    String cleanedName = rawName.replaceAll(RegExp(r'[0-9.]'), '');
    
    // Remplacer les underscores ou autres séparateurs par des espaces
    cleanedName = cleanedName.replaceAll(RegExp(r'[_-]'), ' ');
    
    // Découper les mots pour s'assurer que chaque mot commence par une majuscule
    List<String> words = cleanedName.split(' ').where((word) => word.isNotEmpty).toList();
    List<String> capitalizedWords = words.map((word) {
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).toList();

    // Rejoindre les mots avec des espaces
    return capitalizedWords.join(' ');
  }


  Widget _buildPersonalInfoSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informations personnelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: _handleEditProfile,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          _buildEditableInfoItem(
            title: 'Nom complet',
            controller: _nameController,
            icon: Icons.person,
            enabled: _isEditing,
          ),
          _buildMenuDivider(),
          _buildInfoItem(
            title: 'Email',
            value: widget.user.email,
            icon: Icons.email,
          ),
          _buildMenuDivider(),
          _buildEditableInfoItem(
            title: 'Téléphone',
            controller: _phoneController,
            icon: Icons.phone,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Préférences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildPreferenceItem(
            icon: Icons.notifications,
            title: 'Notifications',
            isSwitch: true,
            onTap: () => {},
          ),
          _buildMenuDivider(),
          _buildPreferenceItem(
            icon: Icons.language,
            title: 'Langue',
            value: 'Français',
            onTap: () => {},
          ),
          _buildMenuDivider(),
          _buildPreferenceItem(
            icon: Icons.dark_mode,
            title: 'Thème sombre',
            isSwitch: true,
            onTap: () => {},
          ),
          _buildMenuDivider(),
          _buildPreferenceItem(
            icon: Icons.logout,
            title: 'Déconnexion',
            color: Colors.orange,
            onTap: () => _handleLogout(context),
          ),
          _buildMenuDivider(),
          _buildPreferenceItem(
            icon: Icons.delete_forever,
            title: 'Supprimer le compte',
            color: Colors.red,
            onTap: () => _handleDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

   Widget _buildEditableInfoItem({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
  required IconData icon,
  required String title,
  String? value,
  bool isSwitch = false,
  Color color = Colors.blue,
  required void Function() onTap,  // Le paramètre est bien défini
}) {
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(
      title,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    ),
    trailing: isSwitch
        ? Switch(
            value: true,
            onChanged: (value) {},
            activeColor: Colors.blue,
          )
        : value != null
            ? Text(
                value,
                style: const TextStyle(color: Colors.grey),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
    // Remplacer ceci :
    // onTap: isSwitch ? null : () {},
    // Par ceci :
    onTap: isSwitch ? null : onTap,  // Utiliser la fonction onTap passée en paramètre
  );
}

  Widget _buildMenuDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}
