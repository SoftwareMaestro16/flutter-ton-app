import 'package:flutter/material.dart';
import 'package:testapp/services/api/get_wallet_info.dart';
import 'package:testapp/services/local_storage_service.dart';
import 'package:testapp/utils/format_date.dart';
import 'package:testapp/utils/format_nano.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? walletInfo;
  String? address;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final savedAddress = await LocalStorageService.loadAddress();
    if (savedAddress == null) {
      setState(() => address = null);
      return;
    }

    try {
      final data = await fetchAccountInfo(savedAddress);
      setState(() {
        address = savedAddress;
        walletInfo = data;
      });
    } catch (e) {
      debugPrint('Error fetching wallet info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('lib/assets/ton.png', width: 120),
                const SizedBox(height: 20),
                const Text(
                  'Your wallet is not connected',
                  style: TextStyle(fontSize: 21),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                    ),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    final balance = walletInfo?['balance'] ?? 0;
    final status = walletInfo?['status'] ?? '—';
    final lastActivity = walletInfo?['last_activity'];
    final interfaces = walletInfo?['interfaces']?.join(', ') ?? '—';

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Information',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold
      )), 
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/assets/ton.png', width: 66),
                  const SizedBox(width: 8),
                  Text(
                    '${formatTonBalance(balance)} TON',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 62),
              _buildInfoCard('Status', status),
              _buildInfoCard('Interfaces', interfaces),
              if (lastActivity != null)
                _buildInfoCard('Last Active', formatTimestamp(lastActivity)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(150, 155, 217, 248),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}