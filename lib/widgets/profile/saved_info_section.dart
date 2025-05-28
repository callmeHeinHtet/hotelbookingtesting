import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_booking/providers/user_provider.dart';

class SavedInfoSection extends StatelessWidget {
  const SavedInfoSection({super.key});

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
                    const Icon(Icons.credit_card_outlined, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Payment Methods',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add New'),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/add-payment-method');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (userProvider.savedCards.isEmpty)
                  const Center(
                    child: Text(
                      'No saved payment methods',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userProvider.savedCards.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final card = userProvider.savedCards[index];
                      return ListTile(
                        leading: Icon(
                          card.type.toLowerCase() == 'visa' 
                              ? Icons.credit_card 
                              : Icons.credit_score,
                          color: Colors.blue,
                        ),
                        title: Text(card.type),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(card.maskedNumber),
                            Text(
                              'Expires: ${card.expiryDate}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Use this card for payment
                                Navigator.pop(context, card);
                              },
                              child: const Text('Use'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove Card'),
                                    content: Text(
                                      'Are you sure you want to remove ${card.type} ending in ${card.number.substring(card.number.length - 4)}?'
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          userProvider.removeCard(card.number);
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
} 