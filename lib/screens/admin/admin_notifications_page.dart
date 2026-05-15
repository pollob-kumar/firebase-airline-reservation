import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../models/booking_model.dart';
import '../../services/constants.dart';
import '../../services/firestore_service.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppConstants.warningColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getAdminNotifications(),
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

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return _buildEmptyState('No notifications yet.');
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationTile(
                context,
                notification,
                firestoreService,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notification,
    FirestoreService firestoreService,
  ) {
    final iconData = _iconForType(notification.type);
    final tileColor = notification.read
        ? Colors.white
        : AppConstants.warningColor.withValues(alpha: 0.08);

    return Card(
      elevation: 2,
      color: tileColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppConstants.warningColor.withValues(alpha: 0.12),
          child: Icon(iconData, color: AppConstants.warningColor),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 6),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await firestoreService.markNotificationRead(notification.id);
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AdminNotificationDetailsPage(notification: notification),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} • $hour:$minute';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'booking_request':
        return Icons.event_available;
      case 'cancel_request':
        return Icons.report_gmailerrorred_outlined;
      case 'new_user':
        return Icons.person_add;
      default:
        return Icons.notifications_none;
    }
  }
}

class AdminNotificationDetailsPage extends StatelessWidget {
  final NotificationModel notification;

  const AdminNotificationDetailsPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        backgroundColor: AppConstants.warningColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.title, style: AppConstants.headingStyle),
            const SizedBox(height: 8),
            Text(
              notification.message,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            if (notification.bookingId != null)
              Expanded(
                child: StreamBuilder<BookingModel?>(
                  stream: firestoreService.getBookingById(
                    notification.bookingId!,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final booking = snapshot.data;
                    if (booking == null) {
                      return _buildEmptyInfo('Booking details not available.');
                    }
                    return _buildBookingDetails(context, booking);
                  },
                ),
              )
            else
              _buildEmptyInfo('No booking details available.'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails(BuildContext context, BookingModel booking) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.flightNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${booking.from} → ${booking.to}'),
                const SizedBox(height: 8),
                _buildDetailRow('Passenger', booking.userName),
                _buildDetailRow('Email', booking.userEmail),
                _buildDetailRow('Date', booking.date),
                _buildDetailRow('Time', booking.time),
                _buildDetailRow(
                  'Price',
                  '৳ ${booking.price.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                _buildStatusChip(booking.status),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(context, booking),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, BookingModel booking) {
    final FirestoreService firestoreService = FirestoreService();
    final status = booking.status.toLowerCase();

    if (status == 'cancelled') {
      return _buildInfoBanner('This booking is already cancelled.');
    }

    final bool showConfirm =
        status == 'pending' || status == 'cancel_requested';
    return Row(
      children: [
        if (showConfirm) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _confirmBooking(context, firestoreService, booking),
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
            onPressed: () => _cancelBooking(context, firestoreService, booking),
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

  Future<void> _confirmBooking(
    BuildContext context,
    FirestoreService firestoreService,
    BookingModel booking,
  ) async {
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
      await firestoreService.confirmBooking(booking.id);
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

  Future<void> _cancelBooking(
    BuildContext context,
    FirestoreService firestoreService,
    BookingModel booking,
  ) async {
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
      await firestoreService.cancelBookingByAdmin(bookingId: booking.id);
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final normalized = status.toLowerCase();
    final Color color = switch (normalized) {
      'confirmed' => AppConstants.successColor,
      'pending' => AppConstants.warningColor,
      'cancel_requested' => AppConstants.warningColor,
      'cancelled' => AppConstants.errorColor,
      _ => AppConstants.primaryColor,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyInfo(String message) {
    return Center(
      child: Text(message, style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget _buildInfoBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[700]),
      ),
    );
  }
}
