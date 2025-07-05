import 'package:flutter/material.dart';
import 'package:darttonconnect/models/wallet_app.dart';
import 'package:darttonconnect/ton_connect.dart';
import 'package:darttonconnect/exceptions.dart';
import 'package:testapp/core/constants/app_constants.dart';
import 'package:testapp/features/mint/widgets/ton_connect_modal.dart';
import 'package:testapp/services/local_storage_service.dart';
import 'package:testapp/utils/short_address.dart';

class MintScreen extends StatefulWidget {
  const MintScreen({super.key});

  @override
  State<MintScreen> createState() => _MintScreenState();
}

class _MintScreenState extends State<MintScreen> {
  final TonConnect connector = TonConnect(AppConstants.manifestUrl);
  WalletApp? selectedWallet;
  String? qrData;
  String? address;

  @override
  void initState() {
    super.initState();
    _initWallet();

    connector.onStatusChange((info) {
      setState(() {
        address = info.account?.address;
        if (info.account == null) {
          qrData = null;
          selectedWallet = null;
          LocalStorageService.removeAddress();
        } else {
          LocalStorageService.saveAddress(info.account!.address);
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        }
      });
    });
  }

  Future<void> _initWallet() async {
    final savedAddress = await LocalStorageService.loadAddress();
    if (savedAddress != null) {
      setState(() => address = savedAddress);
    }

    try {
      await connector.restoreConnection();
      if (connector.connected) {
        setState(() => qrData = null);
      }
    } catch (e) {
      debugPrint('Restore connection error: $e');
    }
  }

  Future<void> _connect() async {
    try {
      final wallets = await connector.getWallets();
      if (wallets.isEmpty) return;
      selectedWallet = wallets.first;
      final link = await connector.connect(selectedWallet!);
      setState(() => qrData = link);
    } catch (e) {
      debugPrint('Connect error: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await connector.disconnect();
    } catch (_) {}

    setState(() {
      address = null;
      qrData = null;
      selectedWallet = null;
    });

    await LocalStorageService.removeAddress();
    await _connect(); 
  }

  Future<void> _sendTon() async {
    if (address == null) return;
    final messages = [
      {
        "address": AppConstants.collectionAddress, 
        "amount": (0.05 * 1e9).toInt().toString(),
        "payload": AppConstants.messagePayload,
      },
    ];

    final transaction = {
      "validUntil": (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 600,
      "messages": messages,
    };

    try {
      final res = await connector.sendTransaction(transaction);
      debugPrint('Transaction BOC: ${res['boc']}');
    } catch (e) {
      if (e is UserRejectsError) {
        debugPrint('User rejected');
      } else {
        debugPrint('Send error: $e');
      }
    }
  }

  void _showConnectModal() async {
    if (qrData == null && address == null) {
      await _connect();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => TonConnectModal(
        address: address,
        qrData: qrData,
        onConnect: () async {
          await _connect();
          if (mounted) Navigator.of(context).pop();
        },
        onDisconnect: () async {
          await _disconnect();
          if (mounted) Navigator.of(context).pop();
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    appBar: AppBar(
        backgroundColor: Colors.blue,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
            height: 43,
            child: TextButton(
              onPressed: _showConnectModal,
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(222, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                address == null ? 'Connect Wallet' : shortAddress(address!, 5),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'lib/assets/banner.jpg',
                width: screenWidth * 0.92,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Mintory Collection',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'A symbolic NFT collection featuring randomly minting crystals. '
            'Each token is a unique crystal that captures a fragment of history, '
            'immortalized on the blockchain through chance and symbolism.',
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),

          SizedBox(height: screenHeight * 0.18), 

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE), 
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'NFT Mint Price: 0.05 TON',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 10), 

          Center(
            child: SizedBox(
              width: screenWidth * 0.92,
              height: 50,
              child: ElevatedButton(
                onPressed: address == null ? null : _sendTon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  address == null ? 'Connect Wallet' : 'Mint NFT',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: address == null ? Colors.black54 : Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30), 
        ],
      ),
    ),
      );
    }
}