import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileItem(
            icon: Icons.movie,
            title: 'Watch History',
            onTap: () {
              // Implement watch history functionality
            },
          ),
          _buildProfileItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              // Implement settings functionality
            },
          ),
          _buildProfileItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {
              // Implement help functionality
            },
          ),
          _buildProfileItem(
            icon: Icons.info,
            title: 'About',
            onTap: () {
              // Implement about functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}