import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Services'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildServiceCategory(
            context,
            'Room Services',
            [
              _buildServiceItem(
                Icons.room_service,
                'In-Room Dining',
                'Available 24/7',
                'Order delicious meals directly to your room',
              ),
              _buildServiceItem(
                Icons.cleaning_services,
                'Housekeeping',
                'Daily Service',
                'Keep your room clean and comfortable',
              ),
              _buildServiceItem(
                Icons.local_laundry_service,
                'Laundry',
                'Same-day service available',
                'Professional cleaning for your clothes',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildServiceCategory(
            context,
            'Wellness & Recreation',
            [
              _buildServiceItem(
                Icons.spa,
                'Spa Services',
                'Open 9 AM - 9 PM',
                'Relax with our premium spa treatments',
              ),
              _buildServiceItem(
                Icons.fitness_center,
                'Fitness Center',
                '24/7 Access',
                'Stay fit with our modern equipment',
              ),
              _buildServiceItem(
                Icons.pool,
                'Swimming Pool',
                'Open 6 AM - 10 PM',
                'Indoor and outdoor pools available',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildServiceCategory(
            context,
            'Business Services',
            [
              _buildServiceItem(
                Icons.business_center,
                'Business Center',
                'Open 24/7',
                'Work space and office services',
              ),
              _buildServiceItem(
                Icons.meeting_room,
                'Meeting Rooms',
                'Reservation required',
                'Professional meeting spaces',
              ),
              _buildServiceItem(
                Icons.wifi,
                'High-Speed Internet',
                'Complimentary',
                'Stay connected throughout the hotel',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildServiceCategory(
            context,
            'Transportation',
            [
              _buildServiceItem(
                Icons.airport_shuttle,
                'Airport Shuttle',
                'Reservation required',
                'Comfortable transfer to/from airport',
              ),
              _buildServiceItem(
                Icons.local_parking,
                'Valet Parking',
                'Available 24/7',
                'Safe and convenient parking service',
              ),
              _buildServiceItem(
                Icons.directions_car,
                'Car Rental',
                'Front desk service',
                'Explore the city at your convenience',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategory(
    BuildContext context,
    String title,
    List<Widget> services,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        ...services,
      ],
    );
  }

  Widget _buildServiceItem(
    IconData icon,
    String title,
    String availability,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              availability,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(description),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          // TODO: Implement service booking functionality
        },
      ),
    );
  }
}
