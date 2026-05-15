import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/constants.dart';
import '../../auth/auth_service.dart';
import '../../auth/login_page.dart';
import 'add_balance_page.dart';
import 'available_flights_page.dart';
import 'frequent_flyer_page.dart';
import 'support_page.dart';
import 'user_settings_page.dart';
import 'user_notifications_page.dart';

class UserDashboard extends StatefulWidget {
  final UserModel user;
  final String? successMessage;

  const UserDashboard({super.key, required this.user, this.successMessage});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _passengerController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadUserData();

    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppConstants.showSnackBar(context, widget.successMessage!);
      });
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _passengerController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await _firestoreService.getUser(widget.user.uid);
    if (user != null && mounted) {
      setState(() => _currentUser = user);
    }
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
    final user = _currentUser;
    if (user == null) {
      AppConstants.showSnackBar(
        context,
        'Profile data is still loading.',
        isError: true,
      );
      return;
    }

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
                      backgroundColor: AppConstants.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppConstants.primaryColor,
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
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'USER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
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
                  icon: Icons.confirmation_number_outlined,
                  title: 'My Bookings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _MyBookingsPage(userId: user.uid),
                      ),
                    );
                  },
                ),
                _buildProfileTile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () async {
                    Navigator.pop(context);
                    if (_currentUser == null) {
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserSettingsPage(user: _currentUser!),
                      ),
                    );
                    _loadUserData();
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

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 1100;
    final Widget content = RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 18),
            _buildSearchCard(context),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool splitView = constraints.maxWidth >= 900;
                final Widget upcomingTrips = _buildUpcomingTripsSection(
                  splitView,
                );
                final Widget quickPanels = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickActionsCard(),
                    const SizedBox(height: 16),
                    _buildPointsCard(),
                  ],
                );

                if (!splitView) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      upcomingTrips,
                      const SizedBox(height: 16),
                      quickPanels,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: upcomingTrips),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: quickPanels),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
              title: const Text('User Dashboard'),
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadUserData,
                ),
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
          Expanded(child: SafeArea(child: content)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String name = _currentUser?.name ?? 'User';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $name!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Airline Reservation System',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadUserData,
          icon: const Icon(Icons.refresh, color: AppConstants.textPrimary),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserNotificationsPage(userId: widget.user.uid),
              ),
            );
          },
          icon: const Icon(
            Icons.notifications_none,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _openProfileSheet,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.secondaryColor.withValues(alpha: 0.95),
            AppConstants.accentColor.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where are you flying to next?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool stacked = constraints.maxWidth < 700;
              final Widget originField = _buildSearchField(
                label: 'Origin',
                hint: 'JFK',
                icon: Icons.flight_takeoff,
                controller: _originController,
              );
              final Widget destinationField = _buildSearchField(
                label: 'Destination',
                hint: 'LHR',
                icon: Icons.flight_land,
                controller: _destinationController,
              );
              final Widget dateField = _buildSearchField(
                label: 'Dates',
                hint: 'Select',
                icon: Icons.date_range,
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
              );
              final Widget passengerField = _buildSearchField(
                label: 'Passenger',
                hint: '1 Adult',
                icon: Icons.person,
                controller: _passengerController,
              );

              if (stacked) {
                return Column(
                  children: [
                    originField,
                    const SizedBox(height: 12),
                    destinationField,
                    const SizedBox(height: 12),
                    dateField,
                    const SizedBox(height: 12),
                    passengerField,
                    const SizedBox(height: 16),
                    _buildSearchButton(context, fullWidth: true),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: originField),
                  const SizedBox(width: 12),
                  Expanded(child: destinationField),
                  const SizedBox(width: 12),
                  Expanded(child: dateField),
                  const SizedBox(width: 12),
                  Expanded(child: passengerField),
                  const SizedBox(width: 12),
                  _buildSearchButton(context),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }
    final String day = picked.day.toString().padLeft(2, '0');
    final String month = picked.month.toString().padLeft(2, '0');
    _dateController.text = '$day/$month/${picked.year}';
  }

  int? _parsePassengerCount(String raw) {
    final match = RegExp(r'\d+').firstMatch(raw);
    if (match == null) {
      return null;
    }
    final value = int.tryParse(match.group(0) ?? '');
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }

  Widget _buildSearchField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppConstants.secondaryColor),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton(BuildContext context, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : 52,
      height: 52,
      child: ElevatedButton(
        onPressed: () async {
          if (_currentUser == null) {
            AppConstants.showSnackBar(
              context,
              'Profile data is still loading.',
              isError: true,
            );
            return;
          }
          final String origin = _originController.text.trim();
          final String destination = _destinationController.text.trim();
          final String date = _dateController.text.trim();
          final int? passengers = _parsePassengerCount(
            _passengerController.text,
          );
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AvailableFlightsPage(
                user: _currentUser!,
                origin: origin,
                destination: destination,
                date: date,
                passengers: passengers,
              ),
            ),
          );
          _loadUserData();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: fullWidth
            ? const Text('Search Flights')
            : const Icon(Icons.search, size: 24),
      ),
    );
  }

  Widget _buildUpcomingTripsSection(bool splitView) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Upcoming Trips',
          actionLabel: 'View all',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _MyBookingsPage(userId: widget.user.uid),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<BookingModel>>(
          stream: _firestoreService.getUserBookings(widget.user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildEmptyStateCard('Unable to load trips right now.');
            }

            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) {
              return _buildEmptyStateCard('No upcoming trips yet.');
            }

            final items = bookings.take(4).toList();
            final int columns = splitView ? 2 : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: splitView ? 2.4 : 2.8,
              ),
              itemBuilder: (context, index) => _buildBookingCard(items[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(message, style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.flightNumber,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${booking.from} → ${booking.to}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.time,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(booking.status),
                  style: TextStyle(
                    color: _statusColor(booking.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'pending':
        return 'Pending';
      case 'cancel_requested':
        return 'Cancel Requested';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Confirmed';
    }
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'pending':
        return AppConstants.warningColor;
      case 'cancel_requested':
        return AppConstants.warningColor;
      case 'cancelled':
        return AppConstants.errorColor;
      default:
        return AppConstants.successColor;
    }
  }

  Widget _buildQuickActionsCard() {
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
          const Text('Quick Actions', style: AppConstants.subHeadingStyle),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildActionCard(
                icon: Icons.account_balance_wallet,
                title: 'Add Balance',
                color: AppConstants.successColor,
                onTap: () async {
                  if (_currentUser == null) {
                    AppConstants.showSnackBar(
                      context,
                      'Profile data is still loading.',
                      isError: true,
                    );
                    return;
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddBalancePage(user: _currentUser!),
                    ),
                  );
                  _loadUserData();
                },
              ),
              _buildActionCard(
                icon: Icons.money,
                title: 'Check Balance',
                color: AppConstants.accentColor,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Current Balance'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 64,
                            color: AppConstants.successColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '৳ ${_currentUser?.balance.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
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
                },
              ),
              _buildActionCard(
                icon: Icons.flight_takeoff,
                title: 'Available Flights',
                color: AppConstants.primaryColor,
                onTap: () async {
                  if (_currentUser == null) {
                    AppConstants.showSnackBar(
                      context,
                      'Profile data is still loading.',
                      isError: true,
                    );
                    return;
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AvailableFlightsPage(user: _currentUser!),
                    ),
                  );
                  _loadUserData();
                },
              ),
              _buildActionCard(
                icon: Icons.confirmation_number_outlined,
                title: 'My Bookings',
                color: AppConstants.warningColor,
                onTap: () {
                  if (_currentUser == null) {
                    AppConstants.showSnackBar(
                      context,
                      'Profile data is still loading.',
                      isError: true,
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _MyBookingsPage(userId: _currentUser!.uid),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    final double balance = _currentUser?.balance ?? 0;
    final int points = (balance * 4).round();

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
            'Frequent Flyer Points',
            style: AppConstants.subHeadingStyle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star, color: AppConstants.primaryColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$points pts',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  Text(
                    points >= 25000 ? 'Gold Status' : 'Silver Status',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppConstants.subHeadingStyle),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
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
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'SkyLine',
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
            icon: Icons.home,
            label: 'Home',
            selected: true,
            onTap: () => _closeDrawerIfOpen(context),
          ),
          _buildSidebarItem(
            icon: Icons.confirmation_number_outlined,
            label: 'My Bookings',
            onTap: () {
              _closeDrawerIfOpen(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _MyBookingsPage(userId: widget.user.uid),
                ),
              );
            },
          ),
          _buildSidebarItem(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () {
              _closeDrawerIfOpen(context);
              _openProfileSheet();
            },
          ),
          _buildSidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () async {
              _closeDrawerIfOpen(context);
              final user = _currentUser;
              if (user == null) {
                AppConstants.showSnackBar(
                  context,
                  'Profile data is still loading.',
                  isError: true,
                );
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserSettingsPage(user: user)),
              );
              _loadUserData();
            },
          ),
          _buildSidebarItem(
            icon: Icons.card_membership_outlined,
            label: 'Frequent Flyer',
            onTap: () {
              _closeDrawerIfOpen(context);
              final user = _currentUser;
              if (user == null) {
                AppConstants.showSnackBar(
                  context,
                  'Profile data is still loading.',
                  isError: true,
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FrequentFlyerPage(user: user),
                ),
              );
            },
          ),
          _buildSidebarItem(
            icon: Icons.support_agent,
            label: 'Support',
            onTap: () {
              _closeDrawerIfOpen(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportPage()),
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
        ? AppConstants.primaryColor
        : AppConstants.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.primaryColor.withValues(alpha: 0.12)
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

  Widget _buildActionCard({
    required IconData icon,
    required String title,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                title,
                style: TextStyle(
                  fontSize: 14,
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

// My Bookings Page
class _MyBookingsPage extends StatelessWidget {
  final String userId;

  const _MyBookingsPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: firestoreService.getUserBookings(userId),
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
                      'Unable to load bookings',
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
                    Icons.airplane_ticket_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppConstants.successColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.flight_takeoff,
                              color: AppConstants.successColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
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
                                Text(
                                  '${booking.from} → ${booking.to}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(booking.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel(booking.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              Icons.calendar_today,
                              'Date',
                              booking.date,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              Icons.access_time,
                              'Time',
                              booking.time,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        Icons.payments,
                        'Price',
                        '৳ ${booking.price.toStringAsFixed(2)}',
                      ),
                      if (booking.status.toLowerCase() == 'confirmed') ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _requestCancellation(context, booking),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Request Cancellation'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppConstants.errorColor,
                              side: const BorderSide(
                                color: AppConstants.errorColor,
                              ),
                            ),
                          ),
                        ),
                      ] else if (booking.status.toLowerCase() ==
                          'cancel_requested') ...[
                        const SizedBox(height: 8),
                        Text(
                          'Cancellation requested. Waiting for admin approval.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'pending':
        return 'Pending';
      case 'cancel_requested':
        return 'Cancel Requested';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Confirmed';
    }
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'pending':
        return AppConstants.warningColor;
      case 'cancel_requested':
        return AppConstants.warningColor;
      case 'cancelled':
        return AppConstants.errorColor;
      default:
        return AppConstants.successColor;
    }
  }

  Future<void> _requestCancellation(
    BuildContext context,
    BookingModel booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Cancellation'),
        content: Text(
          'Send a cancellation request for ${booking.flightNumber}?',
        ),
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

    if (confirm != true) {
      return;
    }

    try {
      await FirestoreService().requestBookingCancellation(booking.id);
      if (context.mounted) {
        AppConstants.showSnackBar(context, 'Cancellation request sent.');
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
}
