import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_booking/providers/user_provider.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_outlined, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Membership Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      context,
                      'Points',
                      userProvider.points.toString(),
                      Icons.star_outline,
                      Colors.amber,
                    ),
                    _buildStatCard(
                      context,
                      'Level',
                      userProvider.membershipLevel,
                      Icons.workspace_premium,
                      _getMembershipColor(userProvider.membershipLevel),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Points System',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildPointsInfo('Bronze', '0 - 1,999 points'),
                _buildPointsInfo('Silver', '2,000 - 4,999 points'),
                _buildPointsInfo('Gold', '5,000 - 9,999 points'),
                _buildPointsInfo('Platinum', '10,000+ points'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'How to Earn Points',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildEarningInfo('Room Booking', '100 points per night'),
                _buildEarningInfo('Restaurant', '10 points per ฿100 spent'),
                _buildEarningInfo('Spa Services', '20 points per ฿100 spent'),
                _buildEarningInfo('Special Events', '500 bonus points'),
              ],
            ),
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

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsInfo(String level, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 12,
            color: _getMembershipColor(level),
          ),
          const SizedBox(width: 8),
          Text(
            level,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            points,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningInfo(String activity, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.add_circle_outline,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            activity,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            points,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 