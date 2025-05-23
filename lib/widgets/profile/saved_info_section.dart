import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

class SavedInfoSection extends StatelessWidget {
  const SavedInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.save_outlined, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Saved Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Payment Methods',
              Icons.credit_card,
              [
                _buildPaymentMethod('Visa', '****4582'),
                _buildPaymentMethod('Mastercard', '****7890'),
              ],
            ),
            const Divider(),
            _buildSection(
              context,
              'Addresses',
              Icons.location_on_outlined,
              [
                _buildAddress('Home', '123 Main St, City'),
                _buildAddress('Work', '456 Office Ave, Business District'),
              ],
            ),
            const Divider(),
            _buildSection(
              context,
              'Documents',
              Icons.description_outlined,
              [
                _buildDocument('Passport', 'Expires: Dec 2025'),
                _buildDocument('ID Card', 'Expires: Jan 2024'),
              ],
            ),
            const Divider(),
            _buildSection(
              context,
              'Emergency Contacts',
              Icons.emergency_outlined,
              [
                _buildEmergencyContact('Jane Doe', 'Spouse', '+1 234 567 890'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/edit-${title.toLowerCase().replaceAll(' ', '-')}');
              },
              child: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildPaymentMethod(String type, String number) {
    return ListTile(
      leading: Icon(
        type.toLowerCase() == 'visa' ? Icons.credit_card : Icons.credit_score,
        color: Colors.blue,
      ),
      title: Text(type),
      subtitle: Text(number),
      dense: true,
    );
  }

  Widget _buildAddress(String type, String address) {
    return ListTile(
      leading: Icon(
        type.toLowerCase() == 'home' ? Icons.home : Icons.business,
        color: Colors.green,
      ),
      title: Text(type),
      subtitle: Text(address),
      dense: true,
    );
  }

  Widget _buildDocument(String type, String expiry) {
    return ListTile(
      leading: const Icon(Icons.file_present, color: Colors.orange),
      title: Text(type),
      subtitle: Text(expiry),
      dense: true,
    );
  }

  Widget _buildEmergencyContact(String name, String relation, String phone) {
    return ListTile(
      leading: const Icon(Icons.person_outline, color: Colors.red),
      title: Text(name),
      subtitle: Text('$relation • $phone'),
      dense: true,
    );
  }
} 