import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStats(),
                _buildMenuSection(),
                _buildPersonalInfoSection(),
                _buildPreferencesSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade800,
                    Colors.blue.shade500,
                    Colors.blue.shade300,
                  ],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage('https://via.placeholder.com/100'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jean Dupont',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'jean.dupont@email.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Vérifié',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
              icon: Icons.shopping_bag, value: '12', label: 'Commandes'),
          _buildVerticalDivider(),
          _buildStatItem(
              icon: Icons.local_shipping, value: '2', label: 'En cours'),
          _buildVerticalDivider(),
          _buildStatItem(icon: Icons.favorite, value: '5', label: 'Favoris'),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          _buildMenuItem(
            icon: Icons.shopping_bag,
            title: 'Mes commandes',
            subtitle: 'Voir l\'historique des commandes',
            color: Colors.blue,
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.favorite,
            title: 'Liste de souhaits',
            subtitle: 'Articles sauvegardés',
            color: Colors.red,
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.location_on,
            title: 'Adresses',
            subtitle: 'Gérer les adresses de livraison',
            color: Colors.green,
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.payment,
            title: 'Paiement',
            subtitle: 'Cartes et méthodes de paiement',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Informations personnelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildInfoItem(
            title: 'Nom complet',
            value: 'Jean Dupont',
            icon: Icons.person,
          ),
          _buildMenuDivider(),
          _buildInfoItem(
            title: 'Email',
            value: 'jean.dupont@email.com',
            icon: Icons.email,
          ),
          _buildMenuDivider(),
          _buildInfoItem(
            title: 'Téléphone',
            value: '+33 6 12 34 56 78',
            icon: Icons.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Préférences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildPreferenceItem(
            icon: Icons.notifications,
            title: 'Notifications',
            isSwitch: true,
          ),
          _buildMenuDivider(),
          _buildPreferenceItem(
            icon: Icons.language,
            title: 'Langue',
            value: 'Français',
          ),
          _buildMenuDivider(),
          _buildPreferenceItem(
            icon: Icons.dark_mode,
            title: 'Thème sombre',
            isSwitch: true,
          ),
          _buildMenuDivider(),
          _buildPreferenceItem(
            icon: Icons.logout,
            title: 'Déconnexion',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    String? value,
    bool isSwitch = false,
    Color color = Colors.blue,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isSwitch
          ? Switch(
              value: true,
              onChanged: (value) {},
              activeColor: Colors.blue,
            )
          : value != null
              ? Text(
                  value,
                  style: const TextStyle(color: Colors.grey),
                )
              : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: isSwitch ? null : () {},
    );
  }

  Widget _buildMenuDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade400, Colors.blue.shade800],
                ),
              ),
            ),
            title: const Text('Mon Profil'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: _buildProfileContent(),
        ),
      ],
    ),
  );
}

Widget _buildProfileContent() {
  return Column(
    children: [
      _buildProfileHeader(),
      _buildStats(),
      _buildMenuItems(),
    ],
  );
}

Widget _buildProfileHeader() {
  return Container(
    transform: Matrix4.translationValues(0, -40, 0),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTIvg6aihgIzUeCsIP06_RpEY75MaD7dQex_w&s'),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Jean Dupont',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Text(
          'jean.dupont@email.com',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}

Widget _buildStats() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('12', 'Commandes'),
        _buildStatDivider(),
        _buildStatItem('3', 'En cours'),
        _buildStatDivider(),
        _buildStatItem('5', 'Favoris'),
      ],
    ),
  );
}

Widget _buildStatItem(String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    ],
  );
}

Widget _buildStatDivider() {
  return Container(
    height: 30,
    width: 1,
    color: Colors.grey.withOpacity(0.3),
  );
}

Widget _buildMenuItems() {
  return Container(
    margin: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
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
        _buildMenuItem(
          icon: Icons.shopping_bag,
          title: 'Mes commandes',
          color: Colors.blue,
        ),
        _buildMenuDivider(),
        _buildMenuItem(
          icon: Icons.location_on,
          title: 'Adresses',
          color: Colors.green,
        ),
        _buildMenuDivider(),
        _buildMenuItem(
          icon: Icons.credit_card,
          title: 'Paiement',
          color: Colors.orange,
        ),
        _buildMenuDivider(),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Paramètres',
          color: Colors.purple,
        ),
        _buildMenuDivider(),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Déconnexion',
          color: Colors.red,
          isLast: true,
        ),
      ],
    ),
  );
}

Widget _buildMenuItem({
  required IconData icon,
  required String title,
  required Color color,
  bool isLast = false,
}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    ),
    trailing: isLast
        ? null
        : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    onTap: () {},
  );
}

Widget _buildMenuDivider() {
  return const Divider(height: 1, indent: 70);
}
