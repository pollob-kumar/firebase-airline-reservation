import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/constants.dart';

class AddBalancePage extends StatefulWidget {
  final UserModel user;

  const AddBalancePage({super.key, required this.user});

  @override
  State<AddBalancePage> createState() => _AddBalancePageState();
}

class _AddBalancePageState extends State<AddBalancePage> {
  final _amountController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  final List<double> _quickAmounts = [500, 1000, 2000, 5000, 10000];

  Future<void> _addBalance() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      AppConstants.showSnackBar(
        context,
        'Please enter a valid amount',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newBalance = widget.user.balance + amount;
      await _firestoreService.updateBalance(widget.user.uid, newBalance);

      if (mounted) {
        AppConstants.showSnackBar(
          context,
          'Successfully added ৳${amount.toStringAsFixed(2)}!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppConstants.showSnackBar(
          context,
          'Failed to add balance: ${AppConstants.formatError(e)}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Balance'),
        backgroundColor: AppConstants.successColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.successColor,
                      AppConstants.successColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${widget.user.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Quick Amount Buttons
            const Text('Quick Add', style: AppConstants.subHeadingStyle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _quickAmounts.map((amount) {
                return OutlinedButton(
                  onPressed: () {
                    _amountController.text = amount.toStringAsFixed(0);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    side: const BorderSide(
                      color: AppConstants.successColor,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '৳ ${amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.successColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Custom Amount Input
            const Text(
              'Or Enter Custom Amount',
              style: AppConstants.subHeadingStyle,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (৳)',
                prefixIcon: const Icon(Icons.money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppConstants.successColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Add Balance Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addBalance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.successColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Add Balance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
