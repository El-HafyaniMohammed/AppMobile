
// ignore_for_file: avoid_print, unused_field, depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'phone_verification_dialog.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:device_info_plus/device_info_plus.dart';
import '../../services/firebase_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


File? _selectedImage;

class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final UserModel user = widget.user;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final String cloudName = 'dgdhrhnar'; // Your Cloudinary Cloud Name
  final String uploadPreset = 'image_product'; // Your Upload Preset
  File? _imageFile;
  bool _isUploading = false;
  bool _isEditing = false;
  final FirebaseService _firebaseService = FirebaseService();
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        setState(() {
          _nameController.text = userData['displayName'] ??
              _formatName(widget.user.email.split('@').first);
          _phoneController.text =
              userData['phoneNumber'] ?? currentUser.phoneNumber ?? '';
        });
      } else {
        _nameController.text = _formatName(widget.user.email.split('@').first);
        _phoneController.text = currentUser.phoneNumber ?? '';
      }
    }
  }

  Future<String?> _uploadToCloudinary(dynamic fileData) async {
    try {
      setState(() {
        _isUploading = true;
      });

      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset;

      if (kIsWeb) {
        // Handle web platform
        if (fileData is PlatformFile) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              fileData.bytes!,
              filename: fileData.name,
            ),
          );
        }
      } else {
        // Handle mobile platform
        if (fileData is File) {
          request.files.add(
            await http.MultipartFile.fromPath('file', fileData.path),
          );
        }
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> data = jsonDecode(responseData);

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200) {
        final String imageUrl = data['secure_url'];
        print('Upload successful: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Upload failed: ${data['error']['message']}');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print('Error uploading to Cloudinary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed, please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String formatMoroccanPhoneNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (phone.startsWith('+212')) {
      return phone;
    }
    if (phone.startsWith('212')) {
      return '+$phone';
    }
    if (phone.startsWith('0')) {
      return '+212${phone.substring(1)}';
    }
    if (phone.length >= 9) {
      return '+212$phone';
    }
    throw Exception('Format de numéro invalide');
  }

  Future<void> _handleEditProfile() async {
    if (_isEditing) {
      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.isNotEmpty) {
        try {
          phoneNumber = formatMoroccanPhoneNumber(phoneNumber);
          if (!RegExp(r'^\+212[5-7][0-9]{8}$').hasMatch(phoneNumber)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Format de numéro marocain invalide. Utilisez le format 06XXXXXXXX ou 07XXXXXXXX'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && phoneNumber != currentUser.phoneNumber) {
            final verified = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  PhoneVerificationDialog(phoneNumber: phoneNumber),
            );

            if (verified != true) {
              return;
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Format de numéro invalide. Utilisez le format 06XXXXXXXX ou 07XXXXXXXX'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          List<String> nameParts = _nameController.text.trim().split(' ');
          String firstName = nameParts.first;
          String lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

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

  Future<void> pickImage() async {
    try {
      if (!kIsWeb) {
        // Initialize DeviceInfoPlugin
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        // Define permissions to request
        List<permission_handler.Permission> permissions = [
          permission_handler.Permission.camera,
          permission_handler.Permission.storage,
          if (Platform.isAndroid && androidInfo.version.sdkInt >= 33)
            permission_handler.Permission.photos,
        ];

        // Request permissions
        Map<permission_handler.Permission, permission_handler.PermissionStatus>
            statuses = await permissions.request();

        // Check if all permissions are granted
        if (statuses.values.every((status) => status.isGranted)) {
          // Show source dialog
          await _showImageSourceDialog();
        } else {
          // Display dialog if permissions are denied
          await _showPermissionDialog();
        }
      } else {
        // Handle web-based file picker
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );

        if (result != null && result.files.isNotEmpty) {
          _processWebFile(result.files.first);
        }
      }
    } catch (e) {
      print('Error in image picking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue en sélectionnant l\'image.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showPermissionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions requises'),
          content: const Text(
            'Pour utiliser cette fonctionnalité, vous devez autoriser l\'accès à la caméra ou au stockage dans les paramètres de l\'application.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Ouvrir les paramètres'),
              onPressed: () async {
                Navigator.pop(context);
                await permission_handler.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Caméra'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  _processPickedFile(pickedFile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  _processPickedFile(pickedFile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _processPickedFile(XFile? pickedFile) async {
    if (pickedFile != null) {
      print('Image picked: ${pickedFile.path}');
      
      _imageFile = File(pickedFile.path);
      
      // Upload to Cloudinary
      String? downloadURL = await _uploadToCloudinary(_imageFile);

      if (downloadURL != null) {
        // Update the user's photoURL in Firestore
        await savePhotoURLToFirestore(userId, downloadURL);

        // Update UI
        setState(() {
          user.photoURL = downloadURL;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image mise à jour avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      print('Aucune image sélectionnée.');
    }
  }

  void _processWebFile(PlatformFile platformFile) async {
    print('Image selected: ${platformFile.name}');

    // Upload to Cloudinary
    String? downloadURL = await _uploadToCloudinary(platformFile);

    if (downloadURL != null) {
      await savePhotoURLToFirestore(userId, downloadURL);

      setState(() {
        user.photoURL = downloadURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image mise à jour avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> savePhotoURLToFirestore(String uid, String photoURL) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      await userDoc.set(
        {'photoURL': photoURL},
        SetOptions(merge: true),
      );
      print('Photo URL successfully saved to Firestore.');
    } catch (e) {
      print('Error saving photo URL to Firestore: $e');
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
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/main',
          (Route<dynamic> route) => false,
        );
      } catch (e) {
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
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final email = user.email;
            if (email != null) {
              final credential = EmailAuthProvider.credential(
                email: email,
                password: passwordController.text,
              );

              await user.reauthenticateWithCredential(credential);
              await user.delete();

              Navigator.of(context).pushNamedAndRemoveUntil(
                '/main',
                (Route<dynamic> route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Votre compte a été supprimé avec succès.'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Impossible de récupérer l\'email de l\'utilisateur.'),
                  backgroundColor: Colors.red,
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
                errorMessage =
                    'Trop de tentatives. Veuillez réessayer plus tard.';
                break;
              default:
                errorMessage = e.message ?? 'Une erreur est survenue.';
            }
          }
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

  String _formatName(String rawName) {
    String cleanedName = rawName.replaceAll(RegExp(r'[0-9.]'), '');
    cleanedName = cleanedName.replaceAll(RegExp(r'[_-]'), ' ');
    List<String> words =
        cleanedName.split(' ').where((word) => word.isNotEmpty).toList();
    List<String> capitalizedWords = words.map((word) {
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).toList();
    return capitalizedWords.join(' ');
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
                const SizedBox(height: 16),
                _buildMenuSection(),
                const SizedBox(height: 16),
                _buildPersonalInfoSection(),
                const SizedBox(height: 16),
                _buildPreferencesSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => _handleLogout(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade900,
                    Colors.green.shade700,
                    Colors.green.shade500,
                  ],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Profile content
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'profile_image',
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                        as ImageProvider<Object>
                                    : const NetworkImage(
                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcyI9Cvp53aaP9XeRn-ZKbJDH2QaWC72O26A&s')),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade500,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: pickImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formatName(user.email.split('@').first),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (user.isEmailVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Vérifié',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FutureBuilder<int>(
            future: _firebaseService.getOrdersCount(userId),
            builder: (context, snapshot) {
              return _buildStatItem(
                icon: Icons.shopping_bag,
                value: snapshot.connectionState == ConnectionState.waiting
                    ? '...'
                    : snapshot.data?.toString() ?? '0',
                label: 'commandes',
                color: Colors.blue.shade700,
              );
            },
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            icon: Icons.local_shipping,
            value: '2',
            label: 'En cours',
            color: Colors.orange.shade700,
          ),
          _buildVerticalDivider(),
          FutureBuilder<int>(
            future: _firebaseService.getFavoritesCount(userId),
            builder: (context, snapshot) {
              return _buildStatItem(
                icon: Icons.favorite,
                value: snapshot.connectionState == ConnectionState.waiting
                    ? '...'
                    : snapshot.data?.toString() ?? '0',
                label: 'Favoris',
                color: Colors.red.shade700,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      // ignore: deprecated_member_use
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
            // ignore: deprecated_member_use
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
            onTap: () => Navigator.of(context).pushNamed('/orders'),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.location_on,
            title: 'Adresses',
            subtitle: 'Gérer les adresses de livraison',
            color: Colors.green,
            onTap: () => Navigator.of(context).pushNamed('/addresses'),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.payment,
            title: 'Paiement',
            subtitle: 'Cartes et méthodes de paiement',
            color: Colors.orange,
            onTap: () => Navigator.of(context).pushNamed('/payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
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
      onTap: onTap,
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informations personnelles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.check_rounded : Icons.edit_outlined,
                    size: 22,
                  ),
                  onPressed: _handleEditProfile,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildEditableInfoItem(
                  title: 'Nom complet',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                ),
                _buildInfoDivider(),
                _buildInfoItem(
                  title: 'Email',
                  value: widget.user.email,
                  icon: Icons.email_outlined,
                ),
                _buildInfoDivider(),
                _buildEditableInfoItem(
                  title: 'Téléphone',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  isLastItem: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoItem({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    bool isLastItem = false,
  }) {
    final color = Colors.green.shade600;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller,
                      enabled: enabled,
                      keyboardType: keyboardType,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Entrez votre ${title.toLowerCase()}',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLastItem)
          _buildInfoDivider(),
      ],
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
    bool isLastItem = false,
  }) {
    final color = Colors.green.shade600;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLastItem)
          _buildInfoDivider(),
      ],
    );
  }

  Widget _buildInfoDivider() {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Text(
              'Préférences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPreferenceGroup([
            _buildPreferenceItem(
              icon: Icons.logout_outlined,
              title: 'Déconnexion',
              color: Colors.orange.shade700,
              onTap: () => _handleLogout(context),
            ),
            _buildPreferenceItem(
              icon: Icons.delete_outline,
              title: 'Supprimer le compte',
              color: Colors.red.shade600,
              onTap: () => _handleDeleteAccount(context),
              isLastItem: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPreferenceGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    String? value,
    bool isSwitch = false,
    Color color = Colors.blue,
    required void Function() onTap,
    bool isLastItem = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          trailing: isSwitch
              ? Switch.adaptive(
                  value: true,
                  onChanged: (value) {},
                  activeColor: Colors.blue,
                  activeTrackColor: Colors.blue.withOpacity(0.2),
                )
              : value != null
                  ? Text(
                      value,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
          onTap: isSwitch ? null : onTap,
        ),
        if (!isLastItem)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }

  Widget _buildMenuDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}
