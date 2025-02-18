// ignore_for_file: unnecessary_null_comparison, unused_local_variable, avoid_types_as_parameter_names, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project/services/firebase_service.dart';// Add this import
import '../../models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/screens/Cart/cart_page.dart';

class CheckoutPage extends StatefulWidget {
  final String userId;
  final List<CartItem> cartItems;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.userId,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedAddress;
  String? _selectedPaymentMethod;
  List<Map<String, dynamic>> savedAddresses = [];
  List<Map<String, dynamic>> savedPayments = [];
  User? user = FirebaseAuth.instance.currentUser;
  
  // Controllers for new address form
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Price calculations
  double get subtotal =>
      widget.cartItems.fold(0, (sum, item) => sum + (item.displayPrice * item.quantity));
  double deliveryFee = 50.0;
  double discountPercentage = 10;
  double get discount => subtotal * (discountPercentage / 100);
  double get total => subtotal + deliveryFee - discount;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final addressSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('addresses')
          .get();

      final paymentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('paymentMethods')
          .get();

      setState(() {
        savedAddresses = addressSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        savedPayments = paymentSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        if (savedAddresses.isNotEmpty) {
          _selectedAddress = savedAddresses.first['id'];
        }
        if (savedPayments.isNotEmpty) {
          _selectedPaymentMethod = savedPayments.first['id'];
        }
      });
    } catch (e) {
      _showErrorDialog('Failed to load user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewAddress() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Address'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Street Address'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter street address' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter city' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Postal Code'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter postal code' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter phone number' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final newAddress = {
                    'street': _streetController.text,
                    'city': _cityController.text,
                    'postalCode': _postalCodeController.text,
                    'phoneNumber': _phoneController.text,
                  };

                  final docRef = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .collection('addresses')
                      .add(newAddress);

                  setState(() {
                    savedAddresses.add({
                      'id': docRef.id,
                      ...newAddress,
                    });
                    _selectedAddress = docRef.id;
                  });

                  Navigator.pop(context);
                } catch (e) {
                  _showErrorDialog('Failed to add address: $e');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (savedAddresses.isEmpty)
          const Text(
            'No saved addresses found. Please add a new address.',
            style: TextStyle(color: Colors.grey),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedAddress,
            items: savedAddresses.map<DropdownMenuItem<String>>((address) {
              return DropdownMenuItem<String>(
                value: address['id'],
                child: Text(
                  "${address['street']}, ${address['city']} ${address['postalCode']}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedAddress = value),
            decoration: InputDecoration(
              labelText: 'Select Delivery Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addNewAddress,
          icon: const Icon(Icons.add),
          label: const Text("Add New Address"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (savedPayments.isEmpty)
          const Text(
            'No saved payment methods found. Please add a new payment method.',
            style: TextStyle(color: Colors.grey),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            items: savedPayments.map<DropdownMenuItem<String>>((payment) {
              final last4 = payment['cardNumber'].toString().substring(
                    payment['cardNumber'].toString().length - 4,
                  );
              return DropdownMenuItem<String>(
                value: payment['id'],
                child: Row(
                  children: [
                    Icon(
                      payment['type'] == 'visa' ? Icons.credit_card : Icons.payment,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text("•••• •••• •••• $last4"),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedPaymentMethod = value),
            decoration: InputDecoration(
              labelText: 'Select Payment Method',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            // Implement payment method addition
          },
          icon: const Icon(Icons.add),
          label: const Text("Add New Payment Method"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.cartItems.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = widget.cartItems[index];
              return ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    item.product.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                ),
                title: Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: ${item.quantity}'),
                    if (item.selectedColor != null)
                      Text('Color: ${item.selectedColor}'),
                    if (item.selectedSize != null)
                      Text('Size: ${item.selectedSize}'),
                  ],
                ),
                trailing: Text(
                  '${(item.displayPrice * item.quantity).toStringAsFixed(2)} Dh',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
          const Divider(thickness: 2),
          _buildSummaryRow('Subtotal', subtotal),
          _buildSummaryRow('Delivery Fee', deliveryFee),
          _buildSummaryRow(
            'Discount',
            -discount,
            detailText: '$discountPercentage% OFF',
          ),
          const Divider(thickness: 2),
          _buildSummaryRow(
            'Total',
            total,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    String? detailText,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Row(
            children: [
              if (detailText != null) ...[
                Text(
                  detailText,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '${amount.abs().toStringAsFixed(2)} Dh',
                style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  color: isTotal ? Colors.green : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout() async {
    if (_selectedAddress == null) {
      _showErrorDialog('Please select a delivery address');
      return;
    }

    if (_selectedPaymentMethod == null) {
      _showErrorDialog('Please select a payment method');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final selectedAddress = savedAddresses.firstWhere(
        (address) => address['id'] == _selectedAddress,
      );
      
      final order = {
        'userId': widget.userId,
        'address': selectedAddress,
        'paymentMethod': _selectedPaymentMethod,
        'items': widget.cartItems.map((item) => {
          'productId': item.product.id,
          'productName': item.product.name,
          'quantity': item.quantity,
          'price': item.displayPrice,
          'color': item.selectedColor,
          'size': item.selectedSize,
        }).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'total': total,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(order);

      // Vider le panier
      FirebaseService firebaseService = FirebaseService();
      await firebaseService.clearCart(widget.userId);

      // Afficher brièvement le message de succès
      if (!mounted) return;
      
      await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Empêcher le retour en arrière
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animation/success.json',
                width: 150,
                height: 150,
                repeat: false,
              ),
              const SizedBox(height: 16),
              const Text(
                'Commande passée avec succès !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vous pouvez suivre votre commande dans "Mes commandes".',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
    // Attendre 2 secondes pour que l'animation soit visible
    await Future.delayed(const Duration(seconds: 2));

    // Rediriger vers la page du panier
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => CartPage(),
      ),
      (route) => false, // Supprime toutes les routes précédentes
    );

    } catch (e) {
      _showErrorDialog('Failed to place order: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      // Empêcher le retour en arrière après une commande réussie
      onWillPop: () async {
        if (_isLoading) {
          return false;
        }
        return true;
      },
      child: Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              controlsBuilder: (context, controls) => const SizedBox.shrink(),
              steps: [
                Step(
                  title: const Text('Delivery'),
                  content: _buildDeliverySection(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Payment'),
                  content: _buildPaymentSection(),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text('Review'),
                  content: _buildOrderSummary(),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                ),
              ],
            ),
      bottomNavigationBar: _isLoading
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _processCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentStep == 2 ? 'Place Order' : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}
