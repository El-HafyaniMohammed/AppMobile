import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '1. Acceptance of Terms',
              content: 'By accessing and using 9Game Store, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              title: '2. User Account',
              content: 'To use certain features of the Service, you must register for an account. You agree to provide accurate and complete information and keep your account information updated.',
            ),
            _buildSection(
              title: '3. Purchase and Payment',
              content: 'All purchases through our service are subject to product availability. Prices for products are subject to change without notice. Payment must be received prior to the acceptance of an order.',
            ),
            _buildSection(
              title: '4. Shipping and Delivery',
              content: 'Shipping and delivery times may vary based on product availability and your location. We are not responsible for delays beyond our control.',
            ),
            _buildSection(
              title: '5. Returns and Refunds',
              content: 'Products may be returned within 14 days of receipt. Items must be unused and in their original packaging. Refunds will be processed within 5-7 business days.',
            ),
            _buildSection(
              title: '6. Intellectual Property',
              content: 'All content included on this site is the property of 9Game Store or its content suppliers and protected by international copyright laws.',
            ),
            _buildSection(
              title: '7. User Conduct',
              content: 'You agree not to use the service for any unlawful purpose or prohibited by these terms. You may not use the service in any manner that could damage or impair the service.',
            ),
            _buildSection(
              title: '8. Limitation of Liability',
              content: '9Game Store shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.',
            ),
            _buildSection(
              title: '9. Changes to Terms',
              content: 'We reserve the right to modify these terms at any time. Your continued use of the service following the posting of changes will mean you accept those changes.',
            ),
            _buildSection(
              title: '10. Contact Information',
              content: 'For questions about these Terms, please contact us at support@9gamestore.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: '1. Information We Collect',
              content: 'We collect information that you provide directly to us, including name, email address, shipping address, payment information, and any other information you choose to provide.',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content: 'We use the information we collect to provide, maintain, and improve our services, process your transactions, communicate with you, and send you marketing communications (with your consent).',
            ),
            _buildSection(
              title: '3. Information Sharing',
              content: 'We do not sell or rent your personal information to third parties. We may share your information with service providers who assist in our operations and as required by law.',
            ),
            _buildSection(
              title: '4. Data Security',
              content: 'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
            ),
            _buildSection(
              title: '5. Cookies and Tracking',
              content: 'We use cookies and similar tracking technologies to track activity on our service and hold certain information to improve and analyze our service.',
            ),
            _buildSection(
              title: '6. Your Rights',
              content: 'You have the right to access, update, or delete your personal information. You may also object to or restrict certain data processing activities.',
            ),
            _buildSection(
              title: '7. Children\'s Privacy',
              content: 'Our service is not directed to children under 13. We do not knowingly collect personal information from children under 13.',
            ),
            _buildSection(
              title: '8. Changes to Privacy Policy',
              content: 'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            _buildSection(
              title: '9. Data Retention',
              content: 'We retain your personal information for as long as necessary to fulfill the purposes outlined in this privacy policy, unless a longer retention period is required by law.',
            ),
            _buildSection(
              title: '10. Contact Us',
              content: 'If you have any questions about this Privacy Policy, please contact us at privacy@9gamestore.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}