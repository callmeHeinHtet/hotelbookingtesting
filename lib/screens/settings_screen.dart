import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Design constants
  static const Color _primaryGreen = Color(0xFFB2D732);
  static const Color _darkBg = Color(0xFF0A0A0A);
  static const Color _cardBg = Color(0xFF1A1A1A);
  static const Color _borderColor = Color(0xFF2A2A2A);
  static const Color _textGrey = Color(0xFF888888);

  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _darkMode = true;
  bool _biometricLogin = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'THB (฿)';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Account Section
            _buildSectionTitle('Account'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildNavigationTile(
                icon: Icons.person_outline,
                title: 'Personal Information',
                subtitle: 'Update your profile details',
                onTap: () => Navigator.pushNamed(context, '/edit-personal-info'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.lock_outline,
                title: 'Password & Security',
                subtitle: 'Change password, 2FA settings',
                onTap: () => _showComingSoon('Password & Security'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.credit_card,
                title: 'Payment Methods',
                subtitle: 'Manage saved cards',
                onTap: () => Navigator.pushNamed(context, '/edit-payment-methods'),
              ),
            ]),
            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionTitle('Preferences'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildDropdownTile(
                icon: Icons.language,
                title: 'Language',
                value: _selectedLanguage,
                options: ['English', 'Thai', '日本語', '中文'],
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                },
              ),
              _buildDivider(),
              _buildDropdownTile(
                icon: Icons.attach_money,
                title: 'Currency',
                value: _selectedCurrency,
                options: ['THB (฿)', 'USD (\$)', 'EUR (€)', 'JPY (¥)'],
                onChanged: (value) {
                  setState(() => _selectedCurrency = value!);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: _darkMode,
                onChanged: (value) {
                  setState(() => _darkMode = value);
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive booking updates',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Receive offers and updates',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Security Section
            _buildSectionTitle('Security'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID',
                value: _biometricLogin,
                onChanged: (value) {
                  setState(() => _biometricLogin = value);
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionTitle('Support'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildNavigationTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'FAQs and support',
                onTap: () => _showComingSoon('Help Center'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.chat_bubble_outline,
                title: 'Contact Us',
                subtitle: 'Get in touch with support',
                onTap: () => _showComingSoon('Contact Us'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'Legal information',
                onTap: () => _showComingSoon('Terms & Conditions'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () => _showComingSoon('Privacy Policy'),
              ),
            ]),
            const SizedBox(height: 24),

            // App Info
            _buildSettingsCard([
              _buildInfoTile(
                icon: Icons.info_outline,
                title: 'App Version',
                value: '1.0.0',
              ),
            ]),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(),
                icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
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

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: _borderColor, indent: 60);
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _primaryGreen, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: _textGrey,
          fontSize: 13,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: _textGrey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _primaryGreen, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: _textGrey,
          fontSize: 13,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _primaryGreen,
        activeTrackColor: _primaryGreen.withOpacity(0.3),
        inactiveThumbColor: _textGrey,
        inactiveTrackColor: _borderColor,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _primaryGreen, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _darkBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: _cardBg,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            icon: Icon(Icons.keyboard_arrow_down, color: _textGrey, size: 20),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _primaryGreen, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          color: _textGrey,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: _primaryGreen, size: 20),
            const SizedBox(width: 12),
            Text('$feature coming soon'),
          ],
        ),
        backgroundColor: _cardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _primaryGreen.withOpacity(0.3)),
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
