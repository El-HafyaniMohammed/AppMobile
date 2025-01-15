import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const primary = Colors.green;
  static const secondary = Colors.white;
  static const background = Colors.white;
  static const cardBackground = Color(0xFFF5F5F5);
}


// Models
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;
  bool isRead;  // Made mutable
  final String? actionUrl;  // Added for deep linking
  final Map<String, dynamic>? additionalData;  // For flexible data storage

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.isRead = false,
    this.actionUrl,
    this.additionalData,
  });
}

enum NotificationType {
  order,
  promotion,
  system,
  payment,  // Added new types
  delivery,
  account,
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  final List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'Flash Sale Alert! 🔥',
      message: 'Don\'t miss out on our biggest sale of the year! Up to 70% off on premium electronics.',
      dateTime: DateTime.now().subtract(const Duration(minutes: 30)),
      type: NotificationType.promotion,
      actionUrl: '/sales/flash',
    ),
    NotificationItem(
      id: '2',
      title: 'Order #12345 Shipped 📦',
      message: 'Your order has been shipped via Express Delivery. Track your package in real-time.',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.delivery,
      isRead: true,
      actionUrl: '/orders/12345/track',
      additionalData: {
        'trackingNumber': 'TR123456789',
        'carrier': 'Express Delivery',
      },
    ),
    NotificationItem(
      id: '3',
      title: 'Security Update 🔒',
      message: 'We\'ve enhanced our security measures. Please verify your account details.',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.account,
      actionUrl: '/account/security',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      case NotificationType.system:
        return Icons.system_update_outlined;
      case NotificationType.payment:
        return Icons.payment_outlined;
      case NotificationType.delivery:
        return Icons.local_shipping_outlined;
      case NotificationType.account:
        return Icons.account_circle_outlined;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.promotion:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.delivery:
        return Colors.orange;
      case NotificationType.account:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            switch (value) {
              case 'mark_all':
                _markAllAsRead();
                break;
              case 'settings':
                _openNotificationSettings();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_all',
              child: Text('Mark all as read'),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Text('Notification settings'),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Unread'),
          Tab(text: 'Read'),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(notifications),
          _buildNotificationsList(notifications.where((n) => !n.isRead).toList()),
          _buildNotificationsList(notifications.where((n) => n.isRead).toList()),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh to check for new notifications',
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final notification = items[index];
        
        if (index == 0 || _shouldShowDateHeader(items, index)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const Divider(),
              _buildDateHeader(notification.dateTime),
              _buildNotificationItem(notification),
            ],
          );
        }
        
        return Column(
          children: [
            const Divider(),
            _buildNotificationItem(notification),
          ],
        );
      },
    );
  }

  bool _shouldShowDateHeader(List<NotificationItem> items, int index) {
    if (index == 0) return true;
    final DateTime currentDate = items[index].dateTime;
    final DateTime previousDate = items[index - 1].dateTime;
    return !DateUtils.isSameDay(currentDate, previousDate);
  }

  Widget _buildDateHeader(DateTime dateTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        DateFormat('MMMM d, y').format(dateTime),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      background: _buildDismissibleBackground(),
      secondaryBackground: _buildDismissibleBackground(isSecondary: true),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as read/unread
          setState(() {
            notification.isRead = !notification.isRead;
          });
          return false;
        } else {
          // Delete confirmation
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Notification'),
                content: const Text('Are you sure you want to delete this notification?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('DELETE'),
                  ),
                ],
              );
            },
          );
        }
      },
      onDismissed: (direction) {
        setState(() {
          notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  notifications.add(notification);
                  notifications.sort((a, b) => b.dateTime.compareTo(a.dateTime));
                });
              },
            ),
          ),
        );
      },
      child: Material(
        color: notification.isRead ? Colors.transparent : AppColors.cardBackground.withOpacity(0.1),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTimeAgo(notification.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      if (notification.additionalData != null) ...[
                        const SizedBox(height: 8),
                        _buildAdditionalData(notification.additionalData!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationItem notification) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _getNotificationColor(notification.type).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getNotificationIcon(notification.type),
        color: _getNotificationColor(notification.type),
        size: 24,
      ),
    );
  }

  Widget _buildDismissibleBackground({bool isSecondary = false}) {
    return Container(
      color: isSecondary ? Colors.red : Colors.blue,
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isSecondary ? Icons.delete : Icons.mark_email_read,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAdditionalData(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Text(
            '${entry.key}: ${entry.value}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read
    if (!notification.isRead) {
      setState(() {
        notification.isRead = true;
      });
    }

    // Handle deep linking
    if (notification.actionUrl != null) {
      // Navigate to the specific screen based on actionUrl
      print('Navigate to: ${notification.actionUrl}');
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _openNotificationSettings() {
    // Navigate to notification settings page
    print('Open notification settings');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}