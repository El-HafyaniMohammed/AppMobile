import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;
  final List<OrderStatus> statuses;

  const OrderTrackingPage({
    Key? key, 
    required this.orderId, 
    required this.statuses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi de commande #$orderId'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          _buildOrderSummary(),
          Expanded(
            child: ListView.builder(
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                final isFirst = index == 0;
                final isLast = index == statuses.length - 1;

                return TimelineTile(
                  alignment: TimelineAlign.start,
                  isFirst: isFirst,
                  isLast: isLast,
                  indicatorStyle: IndicatorStyle(
                    width: 30,
                    color: status.isCompleted ? Colors.green : Colors.grey,
                    iconStyle: IconStyle(
                      color: Colors.white,
                      iconData: status.icon,
                    ),
                  ),
                  beforeLineStyle: LineStyle(
                    color: status.isCompleted ? Colors.green : Colors.grey,
                  ),
                  afterLineStyle: LineStyle(
                    color: index < statuses.length - 1 && statuses[index + 1].isCompleted 
                      ? Colors.green 
                      : Colors.grey,
                  ),
                  endChild: _buildStatusCard(status),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande #$orderId',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: 250 MAD',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {}, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Détails'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(OrderStatus status) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.isCompleted 
          ? Colors.green.shade50 
          : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: status.isCompleted 
            ? Colors.green.shade200 
            : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: status.isCompleted 
                ? Colors.green.shade800 
                : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status.description,
            style: TextStyle(
              color: status.isCompleted 
                ? Colors.green.shade600 
                : Colors.grey.shade600,
            ),
          ),
          if (status.timestamp != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                status.timestamp!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OrderStatus {
  final String title;
  final String description;
  final bool isCompleted;
  final IconData icon;
  final String? timestamp;

  const OrderStatus({
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.icon,
    this.timestamp,
  });
}

// Example usage
final List<OrderStatus> sampleStatuses = [
  OrderStatus(
    title: 'Commande confirmée',
    description: 'Votre commande a été reçue et validée',
    isCompleted: true,
    icon: Icons.check_circle,
    timestamp: '12 jan. 2024 à 10:30',
  ),
  OrderStatus(
    title: 'Préparation en cours',
    description: 'Nos équipes préparent votre commande',
    isCompleted: true,
    icon: Icons.build,
    timestamp: '12 jan. 2024 à 11:15',
  ),
  OrderStatus(
    title: 'En cours de livraison',
    description: 'Votre colis est en route',
    isCompleted: false,
    icon: Icons.local_shipping,
    timestamp: '12 jan. 2024 à 14:45',
  ),
  OrderStatus(
    title: 'Livraison',
    description: 'Commande livrée',
    isCompleted: false,
    icon: Icons.home,
  ),
];