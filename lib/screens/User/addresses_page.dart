import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../services/firebase_service.dart';
import '../../models/Address_User.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  _AddressesPageState createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<AddressUser> _addresses = [];
  final Uuid uuid = Uuid();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndCleanInitialCollection(userId);
    _loadAddresses();
  }

  Future<void> _checkAndCleanInitialCollection(String userId) async {
    try {
      final addressesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();

      if (addressesSnapshot.docs.isEmpty) {
        return; // La collection est vide, pas besoin de la nettoyer
      }

      // Vérifier chaque document
      for (final doc in addressesSnapshot.docs) {
        final data = doc.data();

        // Si le document est vide ou invalide, le supprimer
        if (data.isEmpty ||
            data['title'] == null ||
            data['name'] == null ||
            data['street'] == null ||
            data['city'] == null ||
            data['postalCode'] == null) {
          await doc.reference.delete();
          print('Document invalide supprimé : ${doc.id}');
        }
      }
    } catch (e) {
      print('Error cleaning initial collection: $e');
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _firebaseService.fetchAddresses(userId);
      setState(() {
        _addresses = addresses;
      });
    } catch (e) {
      print('Error loading addresses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load addresses')),
      );
    }
  }

  void _addNewAddress() {
    _showAddressBottomSheet();
  }

  void _editAddress(AddressUser address)async {
    _showAddressBottomSheet(existingAddress: address);
     try {
      await _firebaseService.updateAddress(
        address: address,
        userId: userId,
      );
      _loadAddresses(); // Recharger les adresses après la suppression
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting address: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update address')),
      );
    }
    
  }

  Future<void> _saveAddress(AddressUser? existingAddress) async {
    final address = AddressUser(
      addressId: existingAddress?.addressId ?? uuid.v4(),
      title: titleController.text,
      name: nameController.text,
      street: streetController.text,
      city: cityController.text,
      postalCode: postalCodeController.text,
      isDefault: existingAddress?.isDefault ?? false,
    );

    try {
      if (existingAddress != null) {
        await _firebaseService.updateAddress(
          address: address,
          userId: userId,
        );
      } else {
        await _firebaseService.addAddress(
          address: address,
          userId: userId,
        );
      }

      _loadAddresses(); // Recharger les adresses après la mise à jour
    } catch (e) {
      print('Error saving address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save address')),
      );
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      await _firebaseService.deleteAddress(
        addressId: addressId,
        userId: userId,
      );
      _loadAddresses(); // Recharger les adresses après la suppression
    } catch (e) {
      print('Error deleting address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete address')),
      );
    }
  }

  Future<void> _setDefaultAddress(String addressId) async {
    try {
      await _firebaseService.setDefaultAddress(
        addressId: addressId,
        userId: userId,
      );
      _loadAddresses(); // Recharger les adresses après la mise à jour
    } catch (e) {
      // ignore: avoid_print
      print('Error setting default address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set default address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Adresses', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addNewAddress,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return Slidable(
            key: Key(address.addressId),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _editAddress(address),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Modifier',
                ),
                SlidableAction(
                  onPressed: (_) => _deleteAddress(address.addressId),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Supprimer',
                ),
              ],
            ),
            child: _buildAddressCard(address),
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(AddressUser address) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: address.isDefault
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (!address.isDefault)
                  TextButton(
                    onPressed: () => _setDefaultAddress(address.addressId),
                    child: const Text(
                      'Définir par défaut',
                      style: TextStyle(color: Colors.green),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Adresse principale',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  address.street,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${address.city}, ${address.postalCode}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressBottomSheet({AddressUser? existingAddress}) {
    final isEditing = existingAddress != null;

    if (isEditing) {
      titleController.text = existingAddress.title;
      nameController.text = existingAddress.name;
      streetController.text = existingAddress.street;
      cityController.text = existingAddress.city;
      postalCodeController.text = existingAddress.postalCode;
    } else {
      titleController.clear();
      nameController.clear();
      streetController.clear();
      cityController.clear();
      postalCodeController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Modifier l\'adresse' : 'Nouvelle adresse',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: titleController,
                label: 'Titre de l\'adresse',
                icon: Icons.label,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: nameController,
                label: 'Nom complet',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: streetController,
                label: 'Rue',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: cityController,
                label: 'Ville',
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: postalCodeController,
                label: 'Code postal',
                icon: Icons.pin_drop,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _saveAddress(existingAddress);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  isEditing ? 'Mettre à jour' : 'Ajouter',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}