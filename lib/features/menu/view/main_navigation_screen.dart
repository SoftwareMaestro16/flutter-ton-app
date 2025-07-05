import 'package:flutter/material.dart';
import 'package:testapp/features/mint/view/mint_screen.dart';
import 'package:testapp/features/my_nfts/view/my_nfts_screen.dart';
import 'package:testapp/features/profile/view/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MintScreen(),
    NFTScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        iconSize: 32,
        selectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), 
        unselectedLabelStyle: const TextStyle(fontSize: 14), 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Mint',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'My NFT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}