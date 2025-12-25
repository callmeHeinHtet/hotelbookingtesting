import 'package:flutter/material.dart';
import 'checkin_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/room.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomTitle;
  final double roomPrice;
  final String imagePath;

  const RoomDetailScreen({
    Key? key,
    required this.roomTitle,
    required this.roomPrice,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isFavorite = false;

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

  Room _createRoom() {
    return Room(
      id: '1',
      name: widget.roomTitle,
      description: 'A luxurious room with modern amenities',
      price: widget.roomPrice,
      capacity: 2,
      amenities: [
        'WiFi',
        'TV',
        'AC',
        'Breakfast',
        'King Bed',
        'Non-smoking',
      ],
      images: [widget.imagePath],
    );
  }

  void _handleBookNow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckInScreen(
          room: _createRoom(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Image Header
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: _darkBg,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cardBg.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _cardBg.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                      size: 18,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                  },
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _cardBg,
                          child: Icon(
                            Icons.hotel,
                            size: 80,
                            color: _textGrey,
                          ),
                        );
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            _darkBg.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    // Price badge
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '฿${widget.roomPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '/night',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Room Details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room Title
                    Text(
                      widget.roomTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_half,
                            color: _accentGold,
                            size: 18,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '4.5 (128 reviews)',
                          style: TextStyle(
                            color: _textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Info
                    _buildQuickInfoRow(),
                    const SizedBox(height: 24),

                    // Amenities
                    _buildSectionTitle('Amenities'),
                    const SizedBox(height: 12),
                    _buildAmenitiesGrid(),
                    const SizedBox(height: 24),

                    // Room Features
                    _buildSectionTitle('Room Features'),
                    const SizedBox(height: 12),
                    _buildFeaturesCard(),
                    const SizedBox(height: 24),

                    // Rewards
                    _buildRewardsCard(),
                    const SizedBox(height: 24),

                    // Policies
                    _buildSectionTitle('Policies'),
                    const SizedBox(height: 12),
                    _buildPoliciesCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          border: Border(top: BorderSide(color: _borderColor)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(
                        color: _textGrey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '฿${widget.roomPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleBookNow(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildQuickInfoRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickInfoItem(Icons.bed, '1 King Bed'),
          Container(width: 1, height: 40, color: _borderColor),
          _buildQuickInfoItem(Icons.aspect_ratio, '30 sqm'),
          Container(width: 1, height: 40, color: _borderColor),
          _buildQuickInfoItem(Icons.people, '2 Guests'),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: _primaryGreen, size: 24),
        const SizedBox(height: 6),
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

  Widget _buildAmenitiesGrid() {
    final amenities = [
      {'icon': Icons.wifi, 'label': 'Free WiFi'},
      {'icon': Icons.tv, 'label': 'Smart TV'},
      {'icon': Icons.ac_unit, 'label': 'Air Conditioning'},
      {'icon': Icons.coffee, 'label': 'Coffee Maker'},
      {'icon': Icons.bathtub, 'label': 'Bathtub'},
      {'icon': Icons.local_bar, 'label': 'Mini Bar'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                amenities[index]['icon'] as IconData,
                color: _primaryGreen,
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                amenities[index]['label'] as String,
                style: TextStyle(
                  color: _textGrey,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _buildFeatureRow(Icons.check_circle, 'Breakfast Included'),
          const Divider(color: _borderColor, height: 24),
          _buildFeatureRow(Icons.check_circle, 'Free Cancellation'),
          const Divider(color: _borderColor, height: 24),
          _buildFeatureRow(Icons.check_circle, 'Pay at Hotel'),
          const Divider(color: _borderColor, height: 24),
          _buildFeatureRow(Icons.smoke_free, 'Non-smoking'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _primaryGreen, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentGold.withOpacity(0.2),
            _primaryGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _accentGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.stars, color: _accentGold, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Earn 100 Points',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Members earn points on every booking',
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliciesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _buildPolicyRow('Check-in', '2:00 PM'),
          const Divider(color: _borderColor, height: 20),
          _buildPolicyRow('Check-out', '12:00 PM'),
          const Divider(color: _borderColor, height: 20),
          _buildPolicyRow('Cancellation', 'Free up to 24 hours'),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _textGrey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
