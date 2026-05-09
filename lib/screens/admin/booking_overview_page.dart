import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/constants.dart';
import '../../services/firestore_service.dart';

class BookingOverviewPage extends StatelessWidget {
  BookingOverviewPage({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Overview'),
        backgroundColor: AppConstants.warningColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: _firestoreService.getAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  AppConstants.formatError(snapshot.error!),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final bookings = snapshot.data ?? [];
          final double totalRevenue = bookings.fold(
            0.0,
            (sum, booking) => sum + booking.price,
          );
          final DateTime today = DateTime.now();
          final int todayCount = bookings.where((booking) {
            return booking.bookingDate.year == today.year &&
                booking.bookingDate.month == today.month &&
                booking.bookingDate.day == today.day;
          }).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSummaryCard(
                      title: 'Total Bookings',
                      value: bookings.length.toString(),
                      icon: Icons.confirmation_number_outlined,
                      color: AppConstants.primaryColor,
                    ),
                    _buildSummaryCard(
                      title: 'Bookings Today',
                      value: todayCount.toString(),
                      icon: Icons.event_available,
                      color: AppConstants.successColor,
                    ),
                    _buildSummaryCard(
                      title: 'Total Revenue',
                      value: '৳${totalRevenue.toStringAsFixed(0)}',
                      icon: Icons.attach_money,
                      color: AppConstants.warningColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recent Bookings',
                  style: AppConstants.subHeadingStyle,
                ),
                const SizedBox(height: 12),
                if (bookings.isEmpty)
                  _buildEmptyState('No bookings available yet.')
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _buildBookingCard(context, booking);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flight_takeoff,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.flightNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${booking.from} -> ${booking.to}'),
                      const SizedBox(height: 4),
                      Text('${booking.userName} • ${booking.userEmail}'),
                      const SizedBox(height: 4),
                      Text(_formatDate(booking.bookingDate)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${booking.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusChip(booking.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBookingActions(context, booking),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingActions(BuildContext context, BookingModel booking) {
    final status = booking.status.toLowerCase();
    if (status == 'cancelled') {
      return Text(
        'This booking is cancelled.',
        style: TextStyle(color: Colors.grey[600]),
      );
    }

    final bool showConfirm =
        status == 'pending' || status == 'cancel_requested';
    return Row(
      children: [
        if (showConfirm) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _confirmBooking(context, booking),
              icon: const Icon(Icons.check),
              label: const Text('Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.successColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _cancelBooking(context, booking),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
              side: const BorderSide(color: AppConstants.errorColor),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmBooking(BuildContext context, BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text('Confirm booking ${booking.flightNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _firestoreService.confirmBooking(booking.id);
      if (context.mounted) {
        AppConstants.showSnackBar(context, 'Booking confirmed.');
      }
    } catch (e) {
      if (context.mounted) {
        AppConstants.showSnackBar(
          context,
          AppConstants.formatError(e),
          isError: true,
        );
      }
    }
  }

  Future<void> _cancelBooking(BuildContext context, BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Cancel booking ${booking.flightNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _firestoreService.cancelBookingByAdmin(bookingId: booking.id);
      if (context.mounted) {
        AppConstants.showSnackBar(context, 'Booking cancelled.');
      }
    } catch (e) {
      if (context.mounted) {
        AppConstants.showSnackBar(
          context,
          AppConstants.formatError(e),
          isError: true,
        );
      }
    }
  }

  Widget _buildStatusChip(String status) {
    final String label = status.isEmpty ? 'confirmed' : status;
    final String normalized = label.toLowerCase();
    final Color color = switch (normalized) {
      'confirmed' => AppConstants.successColor,
      'pending' => AppConstants.warningColor,
      'cancel_requested' => AppConstants.warningColor,
      'cancelled' => AppConstants.errorColor,
      _ => AppConstants.primaryColor,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
