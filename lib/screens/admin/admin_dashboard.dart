import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/flight_model.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';
import '../../services/constants.dart';
import '../../auth/auth_service.dart';
import '../../auth/login_page.dart';
import 'add_flight_page.dart';
import 'admin_settings_page.dart';
import 'booking_overview_page.dart';
import 'income_report_page.dart';
import 'user_accounts_page.dart';
import 'admin_notifications_page.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel user;
  final String? successMessage;

  const AdminDashboard({super.key, required this.user, this.successMessage});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _flightManagementKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppConstants.showSnackBar(context, widget.successMessage!);
      });
    }

    _searchController.addListener(() {
      final query = _searchController.text.trim().toLowerCase();
      if (query == _searchQuery) {
        return;
      }
      setState(() => _searchQuery = query);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginPage(successMessage: 'Logged out successfully.'),
        ),
      );
    }
  }

  void _showProfileDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileDetailRow('Name', user.name),
            _buildProfileDetailRow('Email', user.email),
            _buildProfileDetailRow('Phone', user.phone),
            _buildProfileDetailRow('Role', user.role.toUpperCase()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
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

  void _openProfileSheet() {
    final user = widget.user;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppConstants.warningColor.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: AppConstants.warningColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProfileTile(
                  icon: Icons.person_outline,
                  title: 'Profile Details',
                  onTap: () {
                    Navigator.pop(context);
                    _showProfileDetails(user);
                  },
                ),
                _buildProfileTile(
                  icon: Icons.bar_chart,
                  title: 'Income Report',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncomeReportPage(),
                      ),
                    );
                  },
                ),
                _buildProfileTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.04,
    );
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToFlightManagement(BuildContext context) {
    _closeDrawerIfOpen(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _scrollToSection(_flightManagementKey);
    });
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color color = isDestructive
        ? AppConstants.errorColor
        : AppConstants.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _deleteFlight(String flightId, String flightNumber) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flight'),
        content: Text('Are you sure you want to delete flight $flightNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteFlight(flightId);
        if (mounted) {
          AppConstants.showSnackBar(context, 'Flight deleted successfully!');
        }
      } catch (e) {
        if (mounted) {
          AppConstants.showSnackBar(
            context,
            'Failed to delete: ${AppConstants.formatError(e)}',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 1200;
    final Widget mainContent = SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildQuickActionsRow(),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool split = constraints.maxWidth >= 950;
              final Widget leftColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFlightStatusMonitor(),
                  const SizedBox(height: 16),
                  _buildRecentActivityFeed(),
                ],
              );
              final Widget rightColumn = _buildBookingTrendsPanel();

              if (!split) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftColumn,
                    const SizedBox(height: 16),
                    rightColumn,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: leftColumn),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: rightColumn),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            key: _flightManagementKey,
            child: _buildFlightManagementSection(),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
              title: const Text('Admin Dashboard'),
              backgroundColor: AppConstants.warningColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: _openProfileSheet,
                ),
              ],
            ),
      drawer: isWide ? null : Drawer(child: _buildSidebar(context)),
      body: Row(
        children: [
          if (isWide) _buildSidebar(context),
          Expanded(child: SafeArea(child: mainContent)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stacked = constraints.maxWidth < 760;
        final Widget title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Admin control center',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        );

        final Widget search = Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search flights, routes, dates',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _searchController.clear(),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        );

        final Widget actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminNotificationsPage(),
                  ),
                );
              },
            ),
            GestureDetector(
              onTap: _openProfileSheet,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppConstants.warningColor.withValues(
                  alpha: 0.2,
                ),
                child: Text(
                  widget.user.name.isNotEmpty
                      ? widget.user.name[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.warningColor,
                  ),
                ),
              ),
            ),
          ],
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 12),
              Row(children: [search, const SizedBox(width: 12), actions]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: title),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: search),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle,
            label: 'Add Flight',
            color: AppConstants.successColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddFlightPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.bar_chart,
            label: 'Income Report',
            color: AppConstants.primaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IncomeReportPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildBookingsTodayCard(),
        _buildActiveFlightsCard(),
        _buildRevenueCard(),
        _buildNewUsersCard(),
      ],
    );
  }

  Widget _buildBookingsTodayCard() {
    return StreamBuilder<List<BookingModel>>(
      stream: _firestoreService.getAllBookings(),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final DateTime today = DateTime.now();
        final int count = bookings.where((booking) {
          final DateTime date = booking.bookingDate;
          return date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
        }).length;
        return _buildStatCard(
          title: 'Total Bookings Today',
          value: count.toString(),
          subtitle: '+ Bookings',
          color: AppConstants.primaryColor,
          icon: Icons.event_available,
        );
      },
    );
  }

  Widget _buildActiveFlightsCard() {
    return StreamBuilder<List<FlightModel>>(
      stream: _firestoreService.getFlights(),
      builder: (context, snapshot) {
        final flights = snapshot.data ?? [];
        final activeFlights = flights
            .where((flight) => flight.availableSeats > 0)
            .length;
        return _buildStatCard(
          title: 'Active Flights',
          value: activeFlights.toString(),
          subtitle: '+ Flights',
          color: AppConstants.successColor,
          icon: Icons.flight_takeoff,
        );
      },
    );
  }

  Widget _buildRevenueCard() {
    return StreamBuilder<List<BookingModel>>(
      stream: _firestoreService.getAllBookings(),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final DateTime now = DateTime.now();
        final double revenue = bookings
            .where((booking) {
              return booking.bookingDate.year == now.year &&
                  booking.bookingDate.month == now.month;
            })
            .fold(0.0, (sum, booking) => sum + booking.price);
        return _buildStatCard(
          title: 'Revenue This Month',
          value: '৳${revenue.toStringAsFixed(0)}',
          subtitle: '+ Income',
          color: AppConstants.warningColor,
          icon: Icons.attach_money,
        );
      },
    );
  }

  Widget _buildNewUsersCard() {
    return StreamBuilder<List<UserModel>>(
      stream: _firestoreService.getUsers(),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];
        final DateTime now = DateTime.now();
        final DateTime cutoff = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 30));
        final int count = users
            .where((user) => user.createdAt.isAfter(cutoff))
            .length;
        return _buildStatCard(
          title: 'New User Registrations',
          value: count.toString(),
          subtitle: '+ Joined',
          color: AppConstants.secondaryColor,
          icon: Icons.person_add,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightStatusMonitor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flight Status Monitor',
            style: AppConstants.subHeadingStyle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Flight #',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Route',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Departure',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Status',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Load Factor',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<FlightModel>>(
            stream: _firestoreService.getFlights(),
            builder: (context, snapshot) {
              final flights = (snapshot.data ?? [])
                  .where(_matchesSearchQuery)
                  .take(4)
                  .toList();
              if (flights.isEmpty) {
                return Text(
                  _searchQuery.isEmpty
                      ? 'No flights available.'
                      : 'No flights match your search.',
                  style: TextStyle(color: Colors.grey[600]),
                );
              }

              return Column(
                children: flights.map((flight) {
                  final status = _deriveStatus(flight);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            flight.flightNumber,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('${flight.from} → ${flight.to}'),
                        ),
                        Expanded(flex: 2, child: Text(flight.time)),
                        Expanded(
                          flex: 2,
                          child: _buildStatusChip(status.label, status.color),
                        ),
                        Expanded(flex: 3, child: _buildLoadFactorBar(flight)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  ({String label, Color color}) _deriveStatus(FlightModel flight) {
    if (flight.availableSeats <= 0) {
      return (label: 'Full', color: AppConstants.errorColor);
    }
    if (flight.availableSeats < (flight.totalSeats * 0.2)) {
      return (label: 'Limited', color: AppConstants.warningColor);
    }
    return (label: 'On Time', color: AppConstants.successColor);
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadFactorBar(FlightModel flight) {
    final double ratio = flight.totalSeats == 0
        ? 0
        : (flight.totalSeats - flight.availableSeats) / flight.totalSeats;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio > 0.8
                    ? AppConstants.errorColor
                    : AppConstants.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('${(ratio * 100).round()}%'),
      ],
    );
  }

  Widget _buildRecentActivityFeed() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity Feed',
                style: AppConstants.subHeadingStyle,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BookingOverviewPage()),
                  );
                },
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<BookingModel>>(
            stream: _firestoreService.getAllBookings(),
            builder: (context, snapshot) {
              final bookings = (snapshot.data ?? []).take(3).toList();
              if (bookings.isEmpty) {
                return Text(
                  'No recent activity.',
                  style: TextStyle(color: Colors.grey[600]),
                );
              }
              return Column(
                children: bookings
                    .map(
                      (booking) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.flight_takeoff,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        title: Text(
                          '${booking.userName} booked ${booking.flightNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${booking.from} → ${booking.to} • ${_formatDate(booking.bookingDate)}',
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTrendsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking Trends', style: AppConstants.subHeadingStyle),
          const SizedBox(height: 12),
          StreamBuilder<List<BookingModel>>(
            stream: _firestoreService.getAllBookings(),
            builder: (context, snapshot) {
              final bookings = snapshot.data ?? [];
              final DateTime today = DateTime.now();
              final List<int> counts = List.generate(7, (index) {
                final DateTime day = DateTime(
                  today.year,
                  today.month,
                  today.day,
                ).subtract(Duration(days: 6 - index));
                return bookings.where((booking) {
                  final date = booking.bookingDate;
                  return date.year == day.year &&
                      date.month == day.month &&
                      date.day == day.day;
                }).length;
              });

              final int maxCount = counts.fold(1, max);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: counts.map((count) {
                  final double height = 80 * (count / maxCount);
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: max(12.0, height),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlightManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Flight Management', style: AppConstants.headingStyle),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddFlightPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<FlightModel>>(
          stream: _firestoreService.getFlights(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
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
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.flight_takeoff_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No flights added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final flights = snapshot.data!;
            final filteredFlights = flights.where(_matchesSearchQuery).toList();

            if (filteredFlights.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No flights added yet'
                              : 'No flights match your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredFlights.length,
              itemBuilder: (context, index) {
                final flight = filteredFlights[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flight,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    title: Text(
                      flight.flightNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${flight.from} → ${flight.to}'),
                        const SizedBox(height: 4),
                        Text(
                          '${flight.date} • ${flight.time} • ৳${flight.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Seats: ${flight.availableSeats}/${flight.totalSeats}',
                          style: TextStyle(
                            fontSize: 12,
                            color: flight.availableSeats > 0
                                ? AppConstants.successColor
                                : AppConstants.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: AppConstants.errorColor,
                      ),
                      onPressed: () =>
                          _deleteFlight(flight.id, flight.flightNumber),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flight_takeoff,
                color: AppConstants.warningColor,
              ),
              const SizedBox(width: 8),
              Text(
                'AdminHub',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSidebarItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: true,
            onTap: () {
              _closeDrawerIfOpen(context);
              _scrollToTop();
            },
          ),
          _buildSidebarItem(
            icon: Icons.flight,
            label: 'Flight Management',
            onTap: () {
              _scrollToFlightManagement(context);
            },
          ),
          _buildSidebarItem(
            icon: Icons.receipt_long,
            label: 'Booking Overview',
            onTap: () {
              _closeDrawerIfOpen(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingOverviewPage()),
              );
            },
          ),
          _buildSidebarItem(
            icon: Icons.notifications_none,
            label: 'Notifications',
            onTap: () {
              _closeDrawerIfOpen(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminNotificationsPage(),
                ),
              );
            },
          ),
          _buildSidebarItem(
            icon: Icons.group,
            label: 'User Accounts',
            onTap: () {
              _closeDrawerIfOpen(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserAccountsPage()),
              );
            },
          ),
          _buildSidebarItem(
            icon: Icons.analytics_outlined,
            label: 'Reports & Analytics',
            onTap: () {
              _closeDrawerIfOpen(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IncomeReportPage()),
              );
            },
          ),
          _buildSidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {
              _closeDrawerIfOpen(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminSettingsPage(user: widget.user),
                ),
              );
            },
          ),
          const Spacer(),
          _buildSidebarItem(
            icon: Icons.logout,
            label: 'Sign Out',
            isDestructive: true,
            onTap: () {
              _closeDrawerIfOpen(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    bool isDestructive = false,
  }) {
    final Color baseColor = isDestructive
        ? AppConstants.errorColor
        : selected
        ? AppConstants.warningColor
        : AppConstants.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.warningColor.withValues(alpha: 0.12)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: baseColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: baseColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeDrawerIfOpen(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      Navigator.pop(context);
    }
  }

  bool _matchesSearchQuery(FlightModel flight) {
    if (_searchQuery.isEmpty) {
      return true;
    }
    final query = _searchQuery;
    return flight.flightNumber.toLowerCase().contains(query) ||
        flight.from.toLowerCase().contains(query) ||
        flight.to.toLowerCase().contains(query) ||
        flight.date.toLowerCase().contains(query) ||
        flight.time.toLowerCase().contains(query);
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
