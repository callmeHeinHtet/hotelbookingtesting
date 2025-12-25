import 'package:flutter/material.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text(
          'Hotel Services',
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
            // Featured Service Banner
            _buildFeaturedBanner(),
            const SizedBox(height: 24),

            // Room Services
            _buildServiceCategory(
              title: 'Room Services',
              icon: Icons.room_service,
              services: [
                _ServiceItem(
                  icon: Icons.restaurant,
                  title: 'In-Room Dining',
                  availability: 'Available 24/7',
                  description: 'Order delicious meals directly to your room',
                  color: Colors.orange,
                ),
                _ServiceItem(
                  icon: Icons.cleaning_services,
                  title: 'Housekeeping',
                  availability: 'Daily Service',
                  description: 'Keep your room clean and comfortable',
                  color: Colors.blue,
                ),
                _ServiceItem(
                  icon: Icons.local_laundry_service,
                  title: 'Laundry',
                  availability: 'Same-day available',
                  description: 'Professional cleaning for your clothes',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Wellness & Recreation
            _buildServiceCategory(
              title: 'Wellness & Recreation',
              icon: Icons.spa,
              services: [
                _ServiceItem(
                  icon: Icons.spa,
                  title: 'Spa Services',
                  availability: 'Open 9 AM - 9 PM',
                  description: 'Relax with our premium spa treatments',
                  color: Colors.pink,
                ),
                _ServiceItem(
                  icon: Icons.fitness_center,
                  title: 'Fitness Center',
                  availability: '24/7 Access',
                  description: 'Stay fit with our modern equipment',
                  color: Colors.red,
                ),
                _ServiceItem(
                  icon: Icons.pool,
                  title: 'Swimming Pool',
                  availability: 'Open 6 AM - 10 PM',
                  description: 'Indoor and outdoor pools available',
                  color: Colors.cyan,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Business Services
            _buildServiceCategory(
              title: 'Business Services',
              icon: Icons.business_center,
              services: [
                _ServiceItem(
                  icon: Icons.business_center,
                  title: 'Business Center',
                  availability: 'Open 24/7',
                  description: 'Work space and office services',
                  color: Colors.indigo,
                ),
                _ServiceItem(
                  icon: Icons.meeting_room,
                  title: 'Meeting Rooms',
                  availability: 'Reservation required',
                  description: 'Professional meeting spaces',
                  color: Colors.teal,
                ),
                _ServiceItem(
                  icon: Icons.wifi,
                  title: 'High-Speed WiFi',
                  availability: 'Complimentary',
                  description: 'Stay connected throughout the hotel',
                  color: _primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transportation
            _buildServiceCategory(
              title: 'Transportation',
              icon: Icons.directions_car,
              services: [
                _ServiceItem(
                  icon: Icons.airport_shuttle,
                  title: 'Airport Shuttle',
                  availability: 'Reservation required',
                  description: 'Comfortable transfer to/from airport',
                  color: Colors.amber,
                ),
                _ServiceItem(
                  icon: Icons.local_parking,
                  title: 'Valet Parking',
                  availability: 'Available 24/7',
                  description: 'Safe and convenient parking service',
                  color: Colors.grey,
                ),
                _ServiceItem(
                  icon: Icons.directions_car,
                  title: 'Car Rental',
                  availability: 'Front desk service',
                  description: 'Explore the city at your convenience',
                  color: Colors.deepOrange,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryGreen.withOpacity(0.8),
            _accentGold.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'EXCLUSIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Spa & Wellness',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '20% off for members',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.spa,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategory({
    required String title,
    required IconData icon,
    required List<_ServiceItem> services,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: _primaryGreen, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Services List
        ...services.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildServiceCard(service),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildServiceCard(_ServiceItem service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showServiceDetails(service),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: service.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    service.icon,
                    color: service.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            service.availability,
                            style: TextStyle(
                              color: _primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: TextStyle(
                          color: _textGrey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: _textGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(_ServiceItem service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: service.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            service.icon,
                            color: service.color,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  service.availability,
                                  style: TextStyle(
                                    color: _primaryGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'About this service',
                      style: TextStyle(
                        color: _textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Features
                    Text(
                      'Features',
                      style: TextStyle(
                        color: _textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow('Premium quality service'),
                    _buildFeatureRow('Professional staff'),
                    _buildFeatureRow('Flexible scheduling'),

                    const Spacer(),

                    // Book Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${service.title} booking coming soon'),
                              backgroundColor: _cardBg,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: _primaryGreen, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String title;
  final String availability;
  final String description;
  final Color color;

  _ServiceItem({
    required this.icon,
    required this.title,
    required this.availability,
    required this.description,
    required this.color,
  });
}
