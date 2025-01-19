import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinput/pinput.dart';

class PhoneVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  
  // ignore: use_super_parameters
  const PhoneVerificationDialog({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<PhoneVerificationDialog> createState() => _PhoneVerificationDialogState();
}

class _PhoneVerificationDialogState extends State<PhoneVerificationDialog> {
  final TextEditingController _codeController = TextEditingController();
  String _verificationId = '';
  bool _isLoading = false;
  String _errorMessage = '';
  int? _resendToken;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _startPhoneVerification();
  }

  Future<void> _startPhoneVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _updatePhoneNumber(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.message ?? 'Une erreur est survenue';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isLoading = false;
            _codeSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _updatePhoneNumber(PhoneAuthCredential credential) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhoneNumber(credential);
        
        // Mettre à jour Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'phoneNumber': widget.phoneNumber,
          'pendingPhoneNumber': FieldValue.delete(),
        });

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      setState(() {
        _errorMessage = 'Veuillez entrer un code à 6 chiffres';
      });
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text,
      );

      await _updatePhoneNumber(credential);
    } catch (e) {
      setState(() {
        _errorMessage = 'Code invalide';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vérification du numéro'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_codeSent) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Envoi du code de vérification...'),
            ] else ...[
              Text('Un code de vérification a été envoyé au ${widget.phoneNumber}'),
              const SizedBox(height: 16),
              Pinput(
                controller: _codeController,
                length: 6,
                onCompleted: (pin) => _verifyCode(),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 16),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                TextButton(
                  onPressed: _startPhoneVerification,
                  child: const Text('Renvoyer le code'),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        if (_codeSent && !_isLoading)
          ElevatedButton(
            onPressed: _verifyCode,
            child: const Text('Vérifier'),
          ),
      ],
    );
  }
}