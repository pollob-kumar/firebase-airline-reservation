import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../models/booking_model.dart';
import '../../services/constants.dart';
import '../../services/firestore_service.dart';

class UserNotificationsPage extends StatelessWidget {
  final String userId;

  const UserNotificationsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getUserNotifications(userId),
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
        : AppConstants.primaryColor.withValues(alpha: 0.08);

    return Card(
      elevation: 2,
      color: tileColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.12),
          child: Icon(iconData, color: AppConstants.primaryColor),
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
                  UserNotificationDetailsPage(notification: notification),
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
          Icon(
            Icons.notifications_none,
            size: 72,
            color: Colors.grey[400],
          ),
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
      case 'booking_confirmed':
        return Icons.check_circle_outline;
      case 'booking_cancelled':
      case 'cancel_approved':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_none;
    }
  }
}

class UserNotificationDetailsPage extends StatelessWidget {
  final NotificationModel notification;

  const UserNotificationDetailsPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        backgroundColor: AppConstants.primaryColor,
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
                  stream:
                      firestoreService.getBookingById(notification.bookingId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final booking = snapshot.data;
                    if (booking == null) {
                      return _buildEmptyInfo('Booking details not available.');
                    }
                    return _buildBookingDetails(booking);
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

  Widget _buildBookingDetails(BookingModel booking) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.flightNumber,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${booking.from} → ${booking.to}'),
            const SizedBox(height: 8),
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
    );
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
      child: Text(
        message,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}
