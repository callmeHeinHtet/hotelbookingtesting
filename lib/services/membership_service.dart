import 'package:flutter/material.dart';

enum MembershipTier {
  Bronze,
  Silver,
  Gold,
  Platinum
}

class TierRequirement {
  final int pointsRequired;
  final int staysRequired;

  const TierRequirement({
    required this.pointsRequired,
    required this.staysRequired,
  });
}

class MembershipBenefit {
  final String title;
  final String description;
  final IconData icon;
  final List<MembershipTier> availableFor;

  const MembershipBenefit({
    required this.title,
    required this.description,
    required this.icon,
    required this.availableFor,
  });
}

class PointsTransaction {
  final DateTime date;
  final String description;
  final int points;
  final DateTime expiryDate;

  const PointsTransaction({
    required this.date,
    required this.description,
    required this.points,
    required this.expiryDate,
  });
}

class MembershipService {
  static final Map<MembershipTier, Color> tierColors = {
    MembershipTier.Bronze: const Color(0xFFCD7F32),
    MembershipTier.Silver: const Color(0xFFC0C0C0),
    MembershipTier.Gold: const Color(0xFFFFD700),
    MembershipTier.Platinum: const Color(0xFFE5E4E2),
  };

  static final Map<MembershipTier, TierRequirement> tierRequirements = {
    MembershipTier.Bronze: const TierRequirement(pointsRequired: 0, staysRequired: 0),
    MembershipTier.Silver: const TierRequirement(pointsRequired: 1000, staysRequired: 3),
    MembershipTier.Gold: const TierRequirement(pointsRequired: 5000, staysRequired: 10),
    MembershipTier.Platinum: const TierRequirement(pointsRequired: 20000, staysRequired: 25),
  };

  static final List<MembershipBenefit> benefits = [
    const MembershipBenefit(
      title: 'Room Upgrades',
      description: 'Free room upgrade when available',
      icon: Icons.upgrade,
      availableFor: [MembershipTier.Gold, MembershipTier.Platinum],
    ),
    const MembershipBenefit(
      title: 'Early Check-in',
      description: 'Check in up to 2 hours early',
      icon: Icons.access_time,
      availableFor: [MembershipTier.Silver, MembershipTier.Gold, MembershipTier.Platinum],
    ),
    const MembershipBenefit(
      title: 'Late Check-out',
      description: 'Check out up to 2 hours late',
      icon: Icons.time_to_leave,
      availableFor: [MembershipTier.Silver, MembershipTier.Gold, MembershipTier.Platinum],
    ),
    const MembershipBenefit(
      title: 'Welcome Drink',
      description: 'Free welcome drink at check-in',
      icon: Icons.local_bar,
      availableFor: [MembershipTier.Bronze, MembershipTier.Silver, MembershipTier.Gold, MembershipTier.Platinum],
    ),
    const MembershipBenefit(
      title: 'Lounge Access',
      description: 'Access to exclusive member lounge',
      icon: Icons.weekend,
      availableFor: [MembershipTier.Gold, MembershipTier.Platinum],
    ),
    const MembershipBenefit(
      title: 'Priority Service',
      description: 'Priority check-in and check-out',
      icon: Icons.star,
      availableFor: [MembershipTier.Platinum],
    ),
    const MembershipBenefit(
      title: 'Spa Discount',
      description: '20% off spa services',
      icon: Icons.spa,
      availableFor: [MembershipTier.Gold, MembershipTier.Platinum],
    ),
    const MembershipBenefit(
      title: 'Restaurant Discount',
      description: '15% off at hotel restaurants',
      icon: Icons.restaurant,
      availableFor: [MembershipTier.Silver, MembershipTier.Gold, MembershipTier.Platinum],
    ),
    const MembershipBenefit(
      title: 'Free Breakfast',
      description: 'Complimentary breakfast during stay',
      icon: Icons.free_breakfast,
      availableFor: [MembershipTier.Gold, MembershipTier.Platinum],
    ),
    const MembershipBenefit(
      title: 'Room Discount',
      description: 'Up to 20% off room rates',
      icon: Icons.hotel,
      availableFor: [MembershipTier.Silver, MembershipTier.Gold, MembershipTier.Platinum],
    ),
  ];

  static int calculatePointsForBooking(double amount) {
    // Base rate: 1 point per 10 baht spent
    return (amount / 10).round();
  }

  static MembershipTier getTierFromPoints(int points, int stays) {
    if (points >= tierRequirements[MembershipTier.Platinum]!.pointsRequired && 
        stays >= tierRequirements[MembershipTier.Platinum]!.staysRequired) {
      return MembershipTier.Platinum;
    } else if (points >= tierRequirements[MembershipTier.Gold]!.pointsRequired && 
               stays >= tierRequirements[MembershipTier.Gold]!.staysRequired) {
      return MembershipTier.Gold;
    } else if (points >= tierRequirements[MembershipTier.Silver]!.pointsRequired && 
               stays >= tierRequirements[MembershipTier.Silver]!.staysRequired) {
      return MembershipTier.Silver;
    }
    return MembershipTier.Bronze;
  }

  static int getPointsToNextTier(int currentPoints, MembershipTier currentTier) {
    switch (currentTier) {
      case MembershipTier.Bronze:
        return tierRequirements[MembershipTier.Silver]!.pointsRequired - currentPoints;
      case MembershipTier.Silver:
        return tierRequirements[MembershipTier.Gold]!.pointsRequired - currentPoints;
      case MembershipTier.Gold:
        return tierRequirements[MembershipTier.Platinum]!.pointsRequired - currentPoints;
      case MembershipTier.Platinum:
        return 0;
    }
  }

  static List<MembershipBenefit> getBenefitsForTier(MembershipTier tier) {
    return benefits.where((benefit) => benefit.availableFor.contains(tier)).toList();
  }

  static Color getTierColor(MembershipTier tier) {
    return tierColors[tier] ?? const Color(0xFFCD7F32); // Default to Bronze color
  }

  static String getTierName(MembershipTier tier) {
    return tier.toString().split('.').last;
  }

  static DateTime calculatePointsExpiry(DateTime earnedDate) {
    // Points expire after 2 years
    return earnedDate.add(const Duration(days: 730));
  }
} 