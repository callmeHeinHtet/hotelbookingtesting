import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'room_details_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/tab_provider.dart';

/// Luxury-styled home screen with dark theme and refined aesthetics
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Design constants - Luxury Dark Theme
  static const Color _primaryGreen = Color(0xFFB2D732);
  static const Color _darkBg = Color(0xFF0A0A0A);
  static const Color _cardBg = Color(0xFF1A1A1A);
  static const Color _cardBgLight = Color(0xFF242424);
  static const Color _borderColor = Color(0xFF2A2A2A);
  static const Color _textGrey = Color(0xFF888888);
  static const Color _accentGold = Color(0xFFD4AF37);

  final ValueNotifier<String> _username = ValueNotifier<String>('Guest');

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _featuredRooms = [
    {
      'title': 'Single Room',
      'type': 'Standard',
      'price': 1000.00,
      'rating': 4.5,
      'image': 'assets/images/single_room.jpg',
      'amenities': ['WiFi', 'AC', 'TV'],
    },
    {
      'title': 'Deluxe Room',
      'type': 'Premium',
      'price': 2500.00,
      'rating': 4.8,
      'image': 'assets/images/deluxe_room.jpg',
      'amenities': ['WiFi', 'AC', 'TV', 'Minibar'],
    },
    {
      'title': 'Superior Room',
      'type': 'Luxury',
      'price': 4000.00,
      'rating': 4.9,
      'image': 'assets/images/superior_room.jpg',
      'amenities': ['WiFi', 'AC', 'TV', 'Minibar', 'Jacuzzi'],
    },
    {
      'title': 'Suite Room',
      'type': 'Presidential',
      'price': 5000.00,
      'rating': 5.0,
      'image': 'assets/images/suite_room.jpg',
      'amenities': ['WiFi', 'AC', 'TV', 'Minibar', 'Jacuzzi', 'Butler'],
    },
  ];

  final List<Map<String, dynamic>> _quickServices = [
    {'icon': Icons.spa, 'title': 'Spa', 'color': Color(0xFF6B4E71)},
    {'icon': Icons.restaurant, 'title': 'Dining', 'color': Color(0xFFE07A5F)},
    {'icon': Icons.pool, 'title': 'Pool', 'color': Color(0xFF3D8B9C)},
    {'icon': Icons.fitness_center, 'title': 'Gym', 'color': Color(0xFF81B29A)},
    {'icon': Icons.local_laundry_service, 'title': 'Laundry', 'color': Color(0xFF5C6BC0)},
    {'icon': Icons.room_service, 'title': 'Room Service', 'color': Color(0xFFFFB74D)},
  ];

  final List<Map<String, dynamic>> _specialOffers = [
    {
      'title': 'Weekend Escape',
      'discount': '25% OFF',
      'description': 'Book 2 nights, get breakfast free',
      'gradient': [Color(0xFF1A1A2E), Color(0xFF16213E)],
      'accent': Color(0xFFE94560),
    },
    {
      'title': 'Spa Package',
      'discount': '30% OFF',
      'description': 'Room + Spa treatment combo',
      'gradient': [Color(0xFF2D132C), Color(0xFF801336)],
      'accent': Color(0xFFEE4540),
    },
    {
      'title': 'Long Stay Deal',
      'discount': '40% OFF',
      'description': 'Stay 7+ nights special rate',
      'gradient': [Color(0xFF1B262C), Color(0xFF0F4C75)],
      'accent': _primaryGreen,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _username.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('username');
      if (storedName != null && storedName.isNotEmpty) {
        _username.value = storedName;
      }
    } catch (e) {
      debugPrint('Error loading username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: _darkBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(isDesktop),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(isDesktop),
                    const SizedBox(height: 24),
                    _buildTabSection(),
                    const SizedBox(height: 24),
                    Consumer<TabProvider>(
                      builder: (context, tabProvider, _) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildTabContent(tabProvider.currentTab, isDesktop),
                        );
                      },
                    ),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildSupportFAB(),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildAppBar(bool isDesktop) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 80 : 70,
      floating: true,
      pinned: true,
      backgroundColor: _darkBg,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: _darkBg,
            border: Border(
              bottom: BorderSide(color: _borderColor, width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo & Welcome
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryGreen, _primaryGreen.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.hotel, color: Colors.black, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              color: _textGrey,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          ValueListenableBuilder<String>(
                            valueListenable: _username,
                            builder: (context, value, _) {
                              return Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Actions
                  Row(
                    children: [
                      _buildIconButton(Icons.search, () {}),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.notifications_none_rounded, () {}),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _primaryGreen.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.person_outline, color: _primaryGreen, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Card with gradient background
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 32 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _cardBg,
                  Color(0xFF1F1F1F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _primaryGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: _primaryGreen, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Premium Member',
                            style: TextStyle(
                              color: _primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Find Your Perfect\nGetaway',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 36 : 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Discover luxury rooms and exclusive member benefits',
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Quick booking row
                isDesktop ? _buildDesktopBookingBar() : _buildMobileBookingButton(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick stats row
          _buildQuickStats(isDesktop),
        ],
      ),
    );
  }

  Widget _buildDesktopBookingBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Expanded(child: _buildBookingField(Icons.calendar_today, 'Check-in', 'Select date')),
          Container(width: 1, height: 40, color: _borderColor),
          Expanded(child: _buildBookingField(Icons.calendar_today, 'Check-out', 'Select date')),
          Container(width: 1, height: 40, color: _borderColor),
          Expanded(child: _buildBookingField(Icons.person_outline, 'Guests', '2 Adults')),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Search',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingField(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: _textGrey, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(color: _textGrey, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBookingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.search, size: 20),
        label: const Text('Search Available Rooms'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildQuickStats(bool isDesktop) {
    final stats = [
      {'value': '500+', 'label': 'Rooms', 'icon': Icons.bed},
      {'value': '4.9', 'label': 'Rating', 'icon': Icons.star},
      {'value': '24/7', 'label': 'Service', 'icon': Icons.support_agent},
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: stat != stats.last ? 12 : 0),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(stat['icon'] as IconData, color: _primaryGreen, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat['value'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      stat['label'] as String,
                      style: TextStyle(color: _textGrey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<TabProvider>(
        builder: (context, tabProvider, _) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                _buildTab('Rooms', TabType.rooms, tabProvider),
                _buildTab('Services', TabType.services, tabProvider),
                _buildTab('Coupons', TabType.coupons, tabProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, TabType type, TabProvider provider) {
    final isSelected = provider.currentTab == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setTab(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : _textGrey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(TabType tab, bool isDesktop) {
    switch (tab) {
      case TabType.rooms:
        return _buildRoomsContent(isDesktop);
      case TabType.services:
        return _buildServicesContent(isDesktop);
      case TabType.coupons:
        return _buildCouponsContent(isDesktop);
    }
  }

  Widget _buildRoomsContent(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Rooms
        _buildSectionHeader('Featured Rooms', 'View All', () {}),
        const SizedBox(height: 16),
        SizedBox(
          height: isDesktop ? 320 : 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: _featuredRooms.length,
            itemBuilder: (context, index) {
              return _buildRoomCard(_featuredRooms[index], isDesktop, index);
            },
          ),
        ),
        const SizedBox(height: 32),
        // Special Offers
        _buildSectionHeader('Special Offers', 'See All', () {}),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: _specialOffers.length,
            itemBuilder: (context, index) {
              return _buildOfferCard(_specialOffers[index], index);
            },
          ),
        ),
        const SizedBox(height: 32),
        // Quick Services
        _buildSectionHeader('Hotel Services', '', () {}),
        const SizedBox(height: 16),
        _buildServicesGrid(isDesktop),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          if (action.isNotEmpty)
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    action,
                    style: TextStyle(
                      color: _primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: _primaryGreen, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room, bool isDesktop, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailScreen(
              roomTitle: room['title'],
              roomPrice: room['price'],
              imagePath: room['image'],
            ),
          ),
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400 + (index * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          width: isDesktop ? 280 : 220,
          margin: const EdgeInsets.only(right: 16),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with gradient overlay - takes all available space
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.asset(
                        room['image'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_cardBgLight, _cardBg],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(Icons.bed, color: _textGrey, size: 50),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Type badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          room['type'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.favorite_border, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              // Details - Compact layout to prevent overflow
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      room['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: _accentGold, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          room['rating'].toString(),
                          style: TextStyle(
                            color: _accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (128)',
                          style: TextStyle(color: _textGrey, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '฿${room['price'].toStringAsFixed(0)}',
                              style: TextStyle(
                                color: _primaryGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '/night',
                              style: TextStyle(color: _textGrey, fontSize: 11),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: offer['gradient'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (offer['accent'] as Color).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: offer['accent'],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          offer['discount'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        offer['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    offer['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 6 : 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _quickServices.length,
        itemBuilder: (context, index) {
          final service = _quickServices[index];
          return _buildServiceItem(service, index);
        },
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/services'),
        child: Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (service['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  service['icon'] as IconData,
                  color: service['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service['title'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesContent(bool isDesktop) {
    final services = [
      {'icon': Icons.spa, 'title': 'Spa & Wellness', 'desc': 'Relaxation treatments', 'color': Color(0xFF6B4E71)},
      {'icon': Icons.restaurant, 'title': 'Fine Dining', 'desc': 'World-class cuisine', 'color': Color(0xFFE07A5F)},
      {'icon': Icons.pool, 'title': 'Swimming Pool', 'desc': 'Infinity pool & jacuzzi', 'color': Color(0xFF3D8B9C)},
      {'icon': Icons.fitness_center, 'title': 'Fitness Center', 'desc': '24/7 gym access', 'color': Color(0xFF81B29A)},
      {'icon': Icons.local_laundry_service, 'title': 'Laundry', 'desc': 'Same day service', 'color': Color(0xFF5C6BC0)},
      {'icon': Icons.room_service, 'title': 'Room Service', 'desc': '24/7 available', 'color': Color(0xFFFFB74D)},
      {'icon': Icons.local_parking, 'title': 'Parking', 'desc': 'Valet & self-park', 'color': Color(0xFF78909C)},
      {'icon': Icons.wifi, 'title': 'High-Speed WiFi', 'desc': 'Free for all guests', 'color': Color(0xFF26A69A)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.3 : 1.1,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(service, index);
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (service['color'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service['icon'] as IconData,
                color: service['color'] as Color,
                size: 26,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service['desc'] as String,
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponsContent(bool isDesktop) {
    final coupons = [
      {'code': 'WELCOME10', 'discount': '10%', 'desc': 'First booking discount', 'color': Colors.blue},
      {'code': 'SUMMER25', 'discount': '25%', 'desc': 'Summer special offer', 'color': Colors.orange},
      {'code': 'VIP15', 'discount': '15%', 'desc': 'VIP member exclusive', 'color': Colors.purple},
      {'code': 'SPA20', 'discount': '20%', 'desc': 'Spa service discount', 'color': Colors.green},
      {'code': 'DINE15', 'discount': '15%', 'desc': 'Restaurant discount', 'color': Colors.red},
      {'code': 'LONGSTAY', 'discount': '30%', 'desc': '7+ nights stay', 'color': Colors.teal},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active coupons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryGreen.withOpacity(0.15), _primaryGreen.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_offer, color: _primaryGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You have 3 active coupons',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use them before they expire!',
                        style: TextStyle(color: _textGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Available Coupon Codes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return _buildCouponItem(coupon, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCouponItem(Map<String, dynamic> coupon, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (coupon['color'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  coupon['discount'] as String,
                  style: TextStyle(
                    color: coupon['color'] as Color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon['code'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon['desc'] as String,
                    style: TextStyle(color: _textGrey, fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied: ${coupon['code']}'),
                    backgroundColor: coupon['color'] as Color,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: (coupon['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: (coupon['color'] as Color).withOpacity(0.3)),
                ),
                child: Text(
                  'Copy',
                  style: TextStyle(
                    color: coupon['color'] as Color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportFAB() {
    return FloatingActionButton(
      backgroundColor: _primaryGreen,
      onPressed: () {},
      elevation: 4,
      child: const Icon(Icons.support_agent, color: Colors.black, size: 26),
    );
  }
}
