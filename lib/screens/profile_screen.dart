import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Design constants
  static const Color _primaryGreen = Color(0xFFB2D732);
  static const Color _darkBg = Color(0xFF0A0A0A);
  static const Color _cardBg = Color(0xFF1A1A1A);
  static const Color _borderColor = Color(0xFF2A2A2A);
  static const Color _textGrey = Color(0xFF888888);
  static const Color _accentGold = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: _textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: _textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          backgroundColor: _darkBg,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Profile Header
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: _darkBg,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor),
                        ),
                        child: const Icon(Icons.logout,
                            color: Colors.red, size: 18),
                      ),
                      onPressed: () => _handleLogout(context),
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _cardBg,
                            _darkBg,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // Profile Avatar with border
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [_primaryGreen, _accentGold],
                                ),
                              ),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _cardBg,
                                  border: Border.all(color: _darkBg, width: 3),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: _primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userProvider.name.isEmpty
                                  ? 'Guest User'
                                  : userProvider.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getMembershipColor(
                                        userProvider.membershipLevel)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getMembershipColor(
                                      userProvider.membershipLevel),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.diamond,
                                    size: 16,
                                    color: _getMembershipColor(
                                        userProvider.membershipLevel),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${userProvider.membershipLevel} Member',
                                    style: TextStyle(
                                      color: _getMembershipColor(
                                          userProvider.membershipLevel),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Actions
                        _buildQuickActionsSection(context),
                        const SizedBox(height: 24),

                        // Personal Information
                        _buildSectionTitle('Personal Information'),
                        const SizedBox(height: 12),
                        _buildPersonalInfoCard(userProvider),
                        const SizedBox(height: 24),

                        // Saved Information
                        _buildSectionTitle('Saved Information'),
                        const SizedBox(height: 12),
                        _buildSavedInfoSection(context),
                        const SizedBox(height: 24),

                        // Statistics
                        _buildSectionTitle('Your Statistics'),
                        const SizedBox(height: 12),
                        _buildStatisticsSection(userProvider),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAction(
            context,
            icon: Icons.calendar_today,
            label: 'Bookings',
            color: _primaryGreen,
            onTap: () => Navigator.pushNamed(context, '/bookings'),
          ),
          Container(width: 1, height: 50, color: _borderColor),
          _buildQuickAction(
            context,
            icon: Icons.credit_card,
            label: 'Payment',
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/payment'),
          ),
          Container(width: 1, height: 50, color: _borderColor),
          _buildQuickAction(
            context,
            icon: Icons.card_membership,
            label: 'Membership',
            color: _accentGold,
            onTap: () => Navigator.pushNamed(context, '/membership'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: _textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Name',
              userProvider.name.isEmpty ? 'Not set' : userProvider.name),
          const Divider(color: _borderColor, height: 24),
          _buildInfoRow(Icons.email_outlined, 'Email',
              userProvider.email.isEmpty ? 'Not set' : userProvider.email),
          const Divider(color: _borderColor, height: 24),
          _buildInfoRow(Icons.phone_outlined, 'Phone',
              userProvider.phone.isEmpty ? 'Not set' : userProvider.phone),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/edit-personal-info'),
              icon: Icon(Icons.edit, color: _primaryGreen, size: 18),
              label: Text(
                'Edit Information',
                style: TextStyle(color: _primaryGreen),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _primaryGreen, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: _textGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavedInfoSection(BuildContext context) {
    return Column(
      children: [
        _buildSavedInfoTile(
          icon: Icons.credit_card,
          title: 'Payment Methods',
          subtitle: 'Manage your saved cards',
          onTap: () => Navigator.pushNamed(context, '/edit-payment-methods'),
        ),
        const SizedBox(height: 12),
        _buildSavedInfoTile(
          icon: Icons.location_on_outlined,
          title: 'Addresses',
          subtitle: 'Manage your saved addresses',
          onTap: () => Navigator.pushNamed(context, '/edit-addresses'),
        ),
        const SizedBox(height: 12),
        _buildSavedInfoTile(
          icon: Icons.badge_outlined,
          title: 'Travel Documents',
          subtitle: 'Passport, ID & more',
          onTap: () => Navigator.pushNamed(context, '/edit-documents'),
        ),
        const SizedBox(height: 12),
        _buildSavedInfoTile(
          icon: Icons.contact_phone_outlined,
          title: 'Emergency Contacts',
          subtitle: 'Manage emergency contacts',
          onTap: () => Navigator.pushNamed(context, '/edit-emergency-contacts'),
        ),
      ],
    );
  }

  Widget _buildSavedInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primaryGreen, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.hotel,
              value: '${userProvider.savedCards.length}',
              label: 'Cards',
            ),
          ),
          Container(width: 1, height: 60, color: _borderColor),
          Expanded(
            child: _buildStatItem(
              icon: Icons.location_on,
              value: '${userProvider.savedAddresses.length}',
              label: 'Addresses',
            ),
          ),
          Container(width: 1, height: 60, color: _borderColor),
          Expanded(
            child: _buildStatItem(
              icon: Icons.stars,
              value: '${userProvider.points}',
              label: 'Points',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: _primaryGreen, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: _textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getMembershipColor(String level) {
    switch (level.toLowerCase()) {
      case 'platinum':
        return Colors.blueGrey[300]!;
      case 'gold':
        return _accentGold;
      case 'silver':
        return Colors.grey[400]!;
      default:
        return Colors.brown[400]!;
    }
  }
}
