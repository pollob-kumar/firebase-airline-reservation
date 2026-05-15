import 'package:flutter/material.dart';
import '../../services/constants.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help?', style: AppConstants.subHeadingStyle),
            const SizedBox(height: 12),
            _buildContactCard(
              title: 'Call us',
              subtitle: '+880 1777-000-123',
              icon: Icons.call,
              onTap: () {
                AppConstants.showSnackBar(
                  context,
                  'Support will call you shortly.',
                );
              },
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              title: 'Email support',
              subtitle: 'support@skylineair.com',
              icon: Icons.email_outlined,
              onTap: () {
                AppConstants.showSnackBar(context, 'Support email sent.');
              },
            ),
            const SizedBox(height: 20),
            const Text('FAQs', style: AppConstants.subHeadingStyle),
            const SizedBox(height: 12),
            _buildFaqTile(
              question: 'How do I change my booking?',
              answer:
                  'Open My Bookings and contact support to adjust your ticket.',
            ),
            _buildFaqTile(
              question: 'Can I request a refund?',
              answer:
                  'Refunds depend on fare rules. Contact support with your booking ID.',
            ),
            _buildFaqTile(
              question: 'How are points calculated?',
              answer:
                  'Points are earned from your balance and booking activity.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  AppConstants.showSnackBar(
                    context,
                    'Chat support is coming soon.',
                  );
                },
                label: const Text('Start Live Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
