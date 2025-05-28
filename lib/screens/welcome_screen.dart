import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'room_details_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../constants/app_constants.dart';
import '../constants/data_constants.dart';
import '../providers/tab_provider.dart';

/// The main welcome screen of the application.
///
/// Displays:
/// - User welcome header
/// - Popular room listings
/// - Membership offers
/// - Support chat button
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ValueNotifier<String> _username = ValueNotifier<String>('Guest');
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  @override
  void dispose() {
    _username.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    try {
      _isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('username');
      if (storedName != null) {
        _username.value = storedName;
      }
    } catch (e) {
      debugPrint('Error loading username: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.whiteColor,
      body: Stack(
        children: [
          Column(
            children: [
              _WelcomeHeader(username: _username),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Discover',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.blackColor,
                  ),
                ),
              ),
              _TabBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadUsername();
                  },
                  child: Consumer<TabProvider>(
                    builder: (context, tabProvider, _) {
                      switch (tabProvider.currentTab) {
                        case TabType.rooms:
                          return const _RoomsContent();
                        case TabType.services:
                          return const _ServicesContent();
                        case TabType.coupons:
                          return const _CouponsContent();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, _) {
              if (!isLoading) return const SizedBox.shrink();
              return Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Contact support',
        child: FloatingActionButton(
          backgroundColor: AppConstants.primaryColor,
          onPressed: () {},
          child:
              const Icon(Icons.support_agent, color: AppConstants.blackColor),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }
}

/// Header section displaying welcome message and user info
class _WelcomeHeader extends StatelessWidget {
  final ValueNotifier<String> username;

  const _WelcomeHeader({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppConstants.blackColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.home,
                  color: AppConstants.whiteColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: AppConstants.whiteColor,
                        fontSize: 14,
                      ),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: username,
                      builder: (context, value, _) {
                        return Text(
                          value,
                          style: const TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: AppConstants.whiteColor,
                    size: 24,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppConstants.whiteColor,
                  child: Icon(
                    Icons.person,
                    color: AppConstants.blackColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TabButton(
              title: AppStrings.rooms,
              isSelected: tabProvider.currentTab == TabType.rooms,
              onTap: () => tabProvider.setTab(TabType.rooms),
            ),
            _TabButton(
              title: AppStrings.services,
              isSelected: tabProvider.currentTab == TabType.services,
              onTap: () => tabProvider.setTab(TabType.services),
            ),
            _TabButton(
              title: AppStrings.coupons,
              isSelected: tabProvider.currentTab == TabType.coupons,
              onTap: () => tabProvider.setTab(TabType.coupons),
            ),
          ],
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color:
                isSelected ? AppConstants.blackColor : AppConstants.greyColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _RoomsContent extends StatelessWidget {
  const _RoomsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.defaultPadding),
            child: Text(
              AppStrings.popularRooms,
              style: AppStyles.headerStyle,
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.defaultPadding),
              children: const [
                _RoomCard(
                  title: 'Single Room',
                  price: 1000.00,
                  imagePath: 'assets/images/single_room.jpg',
                ),
                _RoomCard(
                  title: 'Deluxe Room',
                  price: 2500.00,
                  imagePath: 'assets/images/deluxe_room.jpg',
                ),
                _RoomCard(
                  title: 'Superior Room',
                  price: 4000.00,
                  imagePath: 'assets/images/superior_room.jpg',
                ),
                _RoomCard(
                  title: 'Suite Room',
                  price: 5000.00,
                  imagePath: 'assets/images/suite_room.jpg',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.defaultPadding),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.exclusivelyForMembers,
                  style: AppStyles.headerStyle,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _MembershipOffer(
                        imagePath: 'assets/images/discount1.jpg',
                      ),
                      _MembershipOffer(
                        imagePath: 'assets/images/discount2.jpg',
                      ),
                      _MembershipOffer(
                        imagePath: 'assets/images/discount3.jpg',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesContent extends StatelessWidget {
  const _ServicesContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1,
      ),
      itemCount: ServiceData.services.length,
      itemBuilder: (context, index) {
        final service = ServiceData.services[index];
        return _ServiceCard(
          title: service['title']!,
          imagePath: service['image']!,
        );
      },
    );
  }
}

class _CouponsContent extends StatelessWidget {
  const _CouponsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> couponCodes = [
      {
        'code': 'WELCOME10',
        'description': '10% off your first booking',
        'color': Colors.blue,
      },
      {
        'code': 'SUMMER25',
        'description': '25% off on summer bookings',
        'color': Colors.orange,
      },
      {
        'code': 'VIP15',
        'description': '15% off for VIP members',
        'color': Colors.purple,
      },
      {
        'code': 'SPA20',
        'description': '20% off on spa services',
        'color': Colors.green,
      },
      {
        'code': 'DINE15',
        'description': '15% off on dining',
        'color': Colors.red,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Coupons
          ...CouponData.coupons.map((category) {
            return _CouponCategory(
              title: category['category'],
              coupons: category['items'],
            );
          }).toList(),

          // Coupon Codes Section
          const SizedBox(height: 20),
          Text(
            'Available Coupon Codes',
            style: AppStyles.headerStyle,
          ),
          const SizedBox(height: 10),
          Text(
            'Use these codes during checkout to get discounts',
            style: TextStyle(
              color: AppConstants.greyColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: couponCodes.map((coupon) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: coupon['color'].withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coupon['code'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: coupon['color'],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              coupon['description'],
                              style: TextStyle(
                                color: AppConstants.greyColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Coupon code ${coupon['code']} copied!'),
                              backgroundColor: coupon['color'],
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon:
                            Icon(Icons.copy, size: 16, color: coupon['color']),
                        label: Text(
                          'Copy',
                          style: TextStyle(color: coupon['color']),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final String title;
  final double price;
  final String imagePath;

  const _RoomCard({
    Key? key,
    required this.title,
    required this.price,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailScreen(
              roomTitle: title,
              roomPrice: price,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppConstants.whiteColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imagePath,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.bodyStyle),
                  Text(
                    '${AppStrings.currencySymbol}${price.toStringAsFixed(2)}',
                    style: AppStyles.priceStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const _ServiceCard({
    Key? key,
    required this.title,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppConstants.whiteColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: AppStyles.bodyStyle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponCategory extends StatelessWidget {
  final String title;
  final List<dynamic> coupons;

  const _CouponCategory({
    Key? key,
    required this.title,
    required this.coupons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(title, style: AppStyles.headerStyle),
        ),
        SizedBox(
          height: 180, // Increased height for better visibility
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              if (coupon['isUsed']) return const SizedBox.shrink();
              return _CouponCard(
                title: coupon['title'],
                imagePath: coupon['image'],
                expiry: coupon['expiry'],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String expiry;

  const _CouponCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.expiry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Increased width for better visibility
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppConstants.whiteColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires: $expiry',
                  style: AppStyles.bodyStyle.copyWith(
                    color: AppConstants.greyColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipOffer extends StatelessWidget {
  final String imagePath;

  const _MembershipOffer({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading offer image: $error');
            return Container(
              width: 180,
              height: 120,
              color: Colors.grey[300],
              child: const Icon(Icons.error_outline, size: 50),
            );
          },
        ),
      ),
    );
  }
}
