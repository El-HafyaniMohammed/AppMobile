import 'user.dart';
final userExample = User(
  id: '123',
  firstName: 'Jean',
  lastName: 'Dupont',
  email: 'jean.dupont@email.com',
  phone: '+33612345678',
  profileImage: 'https://example.com/profile.jpg',
  isVerified: true,
  addresses: [
    Address(
      id: 'addr1',
      street: '123 Rue du Commerce',
      city: 'Paris',
      postalCode: '75001',
      country: 'France',
      isDefault: true,
    )
  ],
  paymentMethods: [
    PaymentMethod(
      id: 'pm1',
      type: 'Visa',
      lastFourDigits: '4242',
      expiryDate: '12/24',
      isDefault: true,
    )
  ],
  preferences: UserPreferences(
    notificationsEnabled: true,
    language: 'fr',
    darkModeEnabled: false,
    interests: ['Electronics', 'Fashion'],
  ),
  stats: UserStats(
    totalOrders: 12,
    pendingOrders: 2,
    wishlistItems: 5,
    reviews: 8,
  ),
);