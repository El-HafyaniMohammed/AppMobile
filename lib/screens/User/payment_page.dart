// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/PaymentMethod.dart';
import '../../services/firebase_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<PaymentMethod> _paymentMethods = [];
  String _selectedPaymentType = 'Carte de crédit'; // Type de paiement par défaut

  final List<String> _paymentTypes = [
    'Carte de crédit',
    'Carte de débit',
  ];

  @override
  void initState() {
    super.initState();
    _checkAndCleanInitialCollection(userId);
    _loadPaymentMethods();
  }

  Future<void> _checkAndCleanInitialCollection(String userId) async {
    try {
      final addressesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('payementCard')
          .get();

      if (addressesSnapshot.docs.isEmpty) {
        return; // La collection est vide, pas besoin de la nettoyer
      }

      // Vérifier chaque document
      for (final doc in addressesSnapshot.docs) {
        final data = doc.data();

        // Si le document est vide ou invalide, le supprimer
        if (data.isEmpty ||
            data['type'] == null ||
            data['cardNumber'] == null ||
            data['holderName'] == null ||
            data['expiryDate'] == null ||
            data['isDefault'] == null) {
          await doc.reference.delete();
          print('Document invalide supprimé : ${doc.id}');
        }
      }
    } catch (e) {
      print('Error cleaning initial collection: $e');
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final paymentMethods = await _firebaseService.fetchPaymentMethods(userId);
      setState(() {
        _paymentMethods = paymentMethods;
      });
    } catch (e) {
      print('Error loading payment methods: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load payment methods')),
      );
    }
  }

  void _addPaymentMethod() {
    _showPaymentMethodDialog();
  }

  String maskCardNumber(String cardNumber) {
    if (cardNumber.length <= 4) {
      return cardNumber; // Si le numéro est trop court, retournez-le tel quel
    }
    // Masque tous les chiffres sauf les 4 derniers
    final maskedPart = '*' * (cardNumber.length - 4);
    final lastFourDigits = cardNumber.substring(cardNumber.length - 4);
    return '$maskedPart$lastFourDigits';
  }

  String maskExpiryDate(String expiryDate) {
    if (expiryDate.length < 5) {
      return expiryDate; // Si la date est trop courte, retournez-la telle quelle
    }
    // Masque les deux premiers chiffres (le mois)
    return '**/${expiryDate.substring(3)}';
  }

  void _editPaymentMethod(PaymentMethod paymentMethod) {
    _showPaymentMethodDialog(paymentMethod: paymentMethod);
  }

  Future<void> _savePaymentMethod(PaymentMethod? paymentMethod) async {
    final newPaymentMethod = PaymentMethod(
      id: paymentMethod?.id ?? const Uuid().v4(),
      type: _selectedPaymentType,
      cardNumber: _cardNumberController.text,
      holderName: _holderNameController.text,
      expiryDate: _expiryDateController.text,
      isDefault: paymentMethod?.isDefault ?? false,
    );

    try {
      if (paymentMethod != null) {
        await _firebaseService.updatePaymentMethod(
          paymentMethod: newPaymentMethod,
          userId: userId,
        );
      } else {
        await _firebaseService.addPaymentMethod(
          paymentMethod: newPaymentMethod,
          userId: userId,
        );
      }

      _loadPaymentMethods(); // Recharger les méthodes de paiement après la mise à jour
    } catch (e) {
      print('Error saving payment method: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save payment method')),
      );
    }
  }

  Future<void> _deletePaymentMethod(String paymentMethodId) async {
    try {
      await _firebaseService.deletePaymentMethod(
        paymentMethodId: paymentMethodId,
        userId: userId,
      );
      _loadPaymentMethods(); // Recharger les méthodes de paiement après la suppression
    } catch (e) {
      print('Error deleting payment method: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete payment method')),
      );
    }
  }

  Future<void> _setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      await _firebaseService.setDefaultPaymentMethod(
        paymentMethodId: paymentMethodId,
        userId: userId,
      );
      _loadPaymentMethods(); // Recharger les méthodes de paiement après la mise à jour
    } catch (e) {
      print('Error setting default payment method: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set default payment method')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Méthodes de Paiement'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPaymentMethod,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paymentMethods.length,
        itemBuilder: (context, index) {
          final paymentMethod = _paymentMethods[index];
          return _buildPaymentMethodCard(paymentMethod);
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod paymentMethod) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: _getPaymentMethodIcon(paymentMethod.type),
            title: Text(paymentMethod.type),
            trailing: paymentMethod.isDefault
                ? Chip(
                    label: const Text('Défaut'),
                    backgroundColor: Colors.green.shade100,
                  )
                : TextButton(
                    onPressed: () => _setDefaultPaymentMethod(paymentMethod.id),
                    child: const Text(
                      'Définir par défaut',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Titulaire: ${paymentMethod.holderName}'),
                const SizedBox(height: 4),
                Text('Numéro: ${maskCardNumber(paymentMethod.cardNumber)}'),
                if (paymentMethod.expiryDate.isNotEmpty)
                  Text('Expire le: ${maskExpiryDate(paymentMethod.expiryDate)}'),
              ],
            ),
          ),
          OverflowBar(
            children: [
              TextButton(
                onPressed: () => _editPaymentMethod(paymentMethod),
                child: const Text('Modifier'),
              ),
              TextButton(
                onPressed: () => _deletePaymentMethod(paymentMethod.id),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getPaymentMethodIcon(String type) {
    switch (type.toLowerCase()) {
      case 'carte de crédit':
        return const Icon(Icons.credit_card, color: Colors.blue);
      case 'carte de débit':
        return const Icon(Icons.account_balance_wallet, color: Colors.green);
      case 'paypal':
        return const Icon(Icons.payment, color: Colors.indigo);
      default:
        return const Icon(Icons.payment);
    }
  }

  void _showPaymentMethodDialog({PaymentMethod? paymentMethod}) {
    final isEditing = paymentMethod != null;

    if (isEditing) {
      _selectedPaymentType = paymentMethod.type;
      _cardNumberController.text = paymentMethod.cardNumber;
      _holderNameController.text = paymentMethod.holderName;
      _expiryDateController.text = paymentMethod.expiryDate;
    } else {
      _selectedPaymentType = 'Carte de crédit'; // Réinitialiser le type par défaut
      _cardNumberController.clear();
      _holderNameController.clear();
      _expiryDateController.clear();
      _emailController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Modifier le moyen de paiement' : 'Ajouter un moyen de paiement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPaymentType,
                decoration: InputDecoration(
                  labelText: 'Type de paiement',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _paymentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedPaymentType == 'Carte de crédit' ||
                  _selectedPaymentType == 'Carte de débit') ...[
                TextField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(labelText: 'Numéro de carte'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _holderNameController,
                  decoration: const InputDecoration(labelText: 'Nom du titulaire'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _expiryDateController,
                        decoration: const InputDecoration(labelText: 'Date d\'expiration (MM/AA)'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ExpiryDateFormatter(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _cvvController,
                        decoration: const InputDecoration(labelText: 'CVV'),
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (_selectedPaymentType == 'PayPal') ...[
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Adresse e-mail'),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              _savePaymentMethod(paymentMethod);
              Navigator.of(context).pop();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\s'), '');
    var formattedText = '';

    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedText += '  ';
      }
      formattedText += text[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    var formattedText = '';

    for (var i = 0; i < text.length; i++) {
      if (i == 2) {
        formattedText += '/';
      }
      formattedText += text[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}