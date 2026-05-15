import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/flight_model.dart';
import '../../services/firestore_service.dart';
import '../../services/constants.dart';
import 'booking_confirmation_page.dart';

class AvailableFlightsPage extends StatefulWidget {
  final UserModel user;
  final String? origin;
  final String? destination;
  final String? date;
  final int? passengers;

  const AvailableFlightsPage({
    super.key,
    required this.user,
    this.origin,
    this.destination,
    this.date,
    this.passengers,
  });

  @override
  State<AvailableFlightsPage> createState() => _AvailableFlightsPageState();
}

class _AvailableFlightsPageState extends State<AvailableFlightsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _refreshUser() async {
    final updated = await _firestoreService.getUser(_currentUser.uid);
    if (updated != null && mounted) {
      setState(() => _currentUser = updated);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Flights'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<FlightModel>>(
        stream: _firestoreService.getAvailableFlights(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load flights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.formatError(snapshot.error!),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flight_takeoff_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No flights available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final flights = _applyFilters(snapshot.data!);
          if (flights.isEmpty) {
            return _buildEmptyState('No flights match your search.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final flight = flights[index];
              final isAvailable = flight.availableSeats > 0;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: isAvailable
                      ? () async {
                          final bool? booked = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingConfirmationPage(
                                user: _currentUser,
                                flight: flight,
                              ),
                            ),
                          );
                          if (booked == true && mounted) {
                            AppConstants.showSnackBar(
                              context,
                              'Booking request submitted successfully.',
                            );
                            await _refreshUser();
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Flight Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.flight,
                                color: AppConstants.primaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flight.flightNumber,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? AppConstants.successColor
                                          : AppConstants.errorColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isAvailable
                                          ? '${flight.availableSeats} seats available'
                                          : 'Sold Out',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Route
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'FROM',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    flight.from,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppConstants.primaryColor,
                              size: 32,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'TO',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    flight.to,
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
                        const Divider(height: 24),

                        // Flight Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailItem(
                              Icons.calendar_today,
                              'Date',
                              flight.date,
                            ),
                            _buildDetailItem(
                              Icons.access_time,
                              'Time',
                              flight.time,
                            ),
                            _buildDetailItem(
                              Icons.payments,
                              'Price',
                              '৳${flight.price.toStringAsFixed(0)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Book Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isAvailable
                                ? () async {
                                    final bool? booked = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingConfirmationPage(
                                          user: _currentUser,
                                          flight: flight,
                                        ),
                                      ),
                                    );
                                    if (booked == true && mounted) {
                                      AppConstants.showSnackBar(
                                        context,
                                        'Booking request submitted successfully.',
                                      );
                                      await _refreshUser();
                                    }
                                  }
                                : null,
                            icon: const Icon(Icons.shopping_cart),
                            label: Text(
                              isAvailable ? 'Book Now' : 'Sold Out',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAvailable
                                  ? AppConstants.primaryColor
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
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

  List<FlightModel> _applyFilters(List<FlightModel> flights) {
    final origin = widget.origin?.trim().toLowerCase() ?? '';
    final destination = widget.destination?.trim().toLowerCase() ?? '';
    final date = widget.date?.trim().toLowerCase() ?? '';
    final int? passengers = widget.passengers;

    return flights.where((flight) {
      if (origin.isNotEmpty &&
          !flight.from.toLowerCase().contains(origin)) {
        return false;
      }
      if (destination.isNotEmpty &&
          !flight.to.toLowerCase().contains(destination)) {
        return false;
      }
      if (date.isNotEmpty && !flight.date.toLowerCase().contains(date)) {
        return false;
      }
      if (passengers != null && flight.availableSeats < passengers) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
