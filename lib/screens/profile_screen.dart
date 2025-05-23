import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(userProvider.profilePhotoPath),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userProvider.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userProvider.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Statistics Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Bookings', '12'),
                      _buildStatItem('Points', '2,500'),
                      _buildStatItem('Reviews', '8'),
                    ],
                  ),
                ),

                // Personal Information Section
                _buildSection(
                  context,
                  'Personal Information',
                  [
                    _buildInfoItem(Icons.person, 'Name', userProvider.name),
                    _buildInfoItem(Icons.email, 'Email', userProvider.email),
                    _buildInfoItem(Icons.phone, 'Phone', userProvider.phone),
                    _buildInfoItem(Icons.location_on, 'Address', userProvider.address),
                  ],
                  onEdit: () => Navigator.pushNamed(context, '/edit-personal-info'),
                ),

                // Payment Methods Section
                _buildSection(
                  context,
                  'Payment Methods',
                  userProvider.paymentMethods.map((method) {
                    return _buildInfoItem(
                      Icons.credit_card,
                      method['type'] ?? '',
                      method['number'] ?? '',
                    );
                  }).toList(),
                  onEdit: () => Navigator.pushNamed(context, '/edit-payment-methods'),
                ),

                // Addresses Section
                _buildSection(
                  context,
                  'Addresses',
                  userProvider.addresses.map((address) {
                    return _buildInfoItem(
                      Icons.location_on,
                      address['type'] ?? '',
                      address['address'] ?? '',
                    );
                  }).toList(),
                  onEdit: () => Navigator.pushNamed(context, '/edit-addresses'),
                ),

                // Documents Section
                _buildSection(
                  context,
                  'Documents',
                  userProvider.documents.map((doc) {
                    return _buildInfoItem(
                      Icons.description,
                      doc['type'] ?? '',
                      'Expires: ${doc['expiry']}',
                    );
                  }).toList(),
                  onEdit: () => Navigator.pushNamed(context, '/edit-documents'),
                ),

                // Emergency Contacts Section
                _buildSection(
                  context,
                  'Emergency Contacts',
                  userProvider.emergencyContacts.map((contact) {
                    return _buildInfoItem(
                      Icons.contact_phone,
                      contact['name'] ?? '',
                      '${contact['relation']} - ${contact['phone']}',
                    );
                  }).toList(),
                  onEdit: () => Navigator.pushNamed(context, '/edit-emergency-contacts'),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> items, {
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    child: const Text('Edit'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
