import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/flight_model.dart';
import '../../services/firestore_service.dart';
import '../../services/constants.dart';

class BookingConfirmationPage extends StatefulWidget {
  final UserModel user;
  final FlightModel flight;

  const BookingConfirmationPage({
    super.key,
    required this.user,
    required this.flight,
  });

  @override
  State<BookingConfirmationPage> createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    try {
      await _firestoreService.bookFlight(
        userId: widget.user.uid,
        flightId: widget.flight.id,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppConstants.showSnackBar(
          context,
          'Booking failed: ${AppConstants.formatError(e)}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canBook = widget.user.balance >= widget.flight.price;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flight Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Flight Details',
                      style: AppConstants.headingStyle,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Flight Number', widget.flight.flightNumber),
                    const SizedBox(height: 12),
                    _buildInfoRow('From', widget.flight.from),
                    const SizedBox(height: 12),
                    _buildInfoRow('To', widget.flight.to),
                    const SizedBox(height: 12),
                    _buildInfoRow('Date', widget.flight.date),
                    const SizedBox(height: 12),
                    _buildInfoRow('Time', widget.flight.time),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Available Seats',
                      '${widget.flight.availableSeats}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Passenger Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Passenger Details',
                      style: AppConstants.headingStyle,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Name', widget.user.name),
                    const SizedBox(height: 12),
                    _buildInfoRow('Email', widget.user.email),
                    const SizedBox(height: 12),
                    _buildInfoRow('Phone', widget.user.phone),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor.withValues(alpha: 0.1),
                      AppConstants.accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: AppConstants.headingStyle,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Current Balance:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '৳ ${widget.user.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ticket Price:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '৳ ${widget.flight.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.errorColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Balance After Booking:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '৳ ${(widget.user.balance - widget.flight.price).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: (widget.user.balance - widget.flight.price) >= 0
                                ? AppConstants.successColor
                                : AppConstants.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Warning if insufficient balance
            if (!canBook)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConstants.errorColor,
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: AppConstants.errorColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Insufficient balance! Please add money to your wallet.',
                        style: TextStyle(
                          color: AppConstants.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading || !canBook ? null : _confirmBooking,
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
                        'Confirm Booking',
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
