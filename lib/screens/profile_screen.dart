import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/profile/personal_info_section.dart';
import '../widgets/profile/saved_info_section.dart';
import '../widgets/profile/statistics_section.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Clear user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      if (context.mounted) {
        // Navigate to login and clear the stack
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
    final bool isFromBottomNav = !Navigator.of(context).canPop();

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            if (!isFromBottomNav) {
              Navigator.pop(context);
              return false;
            }
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black),
                  onPressed: () => _handleLogout(context),
                ),
              ],
            ),
            body: CustomScrollView(
              slivers: [
                // Custom App Bar with Profile Summary
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: Colors.black,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person,
                                  size: 40, color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userProvider.name.isEmpty
                                  ? 'Guest User'
                                  : userProvider.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${userProvider.membershipLevel} Member',
                              style: TextStyle(
                                color: _getMembershipColor(
                                    userProvider.membershipLevel),
                                fontSize: 16,
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Quick Actions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuickAction(
                                    context,
                                    icon: Icons.hotel,
                                    label: 'My Bookings',
                                    onTap: () => Navigator.pushNamed(
                                        context, '/bookings'),
                                  ),
                                  _buildQuickAction(
                                    context,
                                    icon: Icons.credit_card,
                                    label: 'Payment',
                                    onTap: () => Navigator.pushNamed(
                                        context, '/payment'),
                                  ),
                                  _buildQuickAction(
                                    context,
                                    icon: Icons.card_membership,
                                    label: 'Membership',
                                    onTap: () => Navigator.pushNamed(
                                        context, '/membership'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Personal Information Section
                        const PersonalInfoSection(),
                        const SizedBox(height: 16),

                        // Saved Information Section
                        const SavedInfoSection(),
                        const SizedBox(height: 16),

                        // Statistics Section
                        const StatisticsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
          ),
        );
      },
    );
  }

  Color _getMembershipColor(String level) {
    switch (level.toLowerCase()) {
      case 'platinum':
        return Colors.blueGrey;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      default:
        return Colors.brown;
    }
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
