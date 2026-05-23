import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/constants.dart';

class FrequentFlyerPage extends StatelessWidget {
  final UserModel user;

  const FrequentFlyerPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final int points = (user.balance * 4).round();
    final _Tier tier = _Tier.fromPoints(points);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequent Flyer'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tier: ${tier.label}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$points pts',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: tier.progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tier.message,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Benefits', style: AppConstants.subHeadingStyle),
            const SizedBox(height: 12),
            _buildBenefitCard(
              icon: Icons.luggage,
              title: 'Extra baggage',
              description: tier.benefits[0],
            ),
            const SizedBox(height: 12),
            _buildBenefitCard(
              icon: Icons.event_seat,
              title: 'Priority seating',
              description: tier.benefits[1],
            ),
            const SizedBox(height: 12),
            _buildBenefitCard(
              icon: Icons.local_airport,
              title: 'Lounge access',
              description: tier.benefits[2],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
      ),
    );
  }
}

class _Tier {
  final String label;
  final double progress;
  final String message;
  final List<String> benefits;

  const _Tier({
    required this.label,
    required this.progress,
    required this.message,
    required this.benefits,
  });

  factory _Tier.fromPoints(int points) {
    if (points >= 50000) {
      return const _Tier(
        label: 'Platinum',
        progress: 1,
        message: 'You have unlocked the highest tier.',
        benefits: [
          'Extra 30kg baggage allowance',
          'Priority seating on every flight',
          'Unlimited lounge access worldwide',
        ],
      );
    }
    if (points >= 25000) {
      final double progress = (points - 25000) / 25000;
      return _Tier(
        label: 'Gold',
        progress: progress.clamp(0.0, 1.0),
        message: '${50000 - points} pts to reach Platinum.',
        benefits: const [
          'Extra 20kg baggage allowance',
          'Priority seat selection',
          'Lounge access on international flights',
        ],
      );
    }
    final double progress = points / 25000;
    return _Tier(
      label: 'Silver',
      progress: progress.clamp(0.0, 1.0),
      message: '${25000 - points} pts to reach Gold.',
      benefits: const [
        'Extra 10kg baggage allowance',
        'Seat preference support',
        'Discounted lounge day pass',
      ],
    );
  }
}
