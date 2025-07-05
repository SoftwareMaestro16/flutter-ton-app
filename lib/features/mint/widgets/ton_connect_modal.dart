import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:testapp/utils/short_address.dart';

class TonConnectModal extends StatelessWidget {
  final String? address;
  final String? qrData;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onClose;

  const TonConnectModal({
    super.key,
    required this.address,
    required this.qrData,
    required this.onConnect,
    required this.onDisconnect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = address != null;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isConnected ? 'Connected Wallet' : 'Connect Your Wallet',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                if (!isConnected && qrData != null)
                  QrImageView(
                    data: qrData!,
                    size: 230,
                    backgroundColor: Colors.white,
                  ),

                if (isConnected)
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: address!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Address copied to clipboard"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              shortAddress(address.toString(), 12),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap to Copy',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 28),

                SizedBox(
                  width: screenWidth * 0.92,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isConnected ? onDisconnect : onConnect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isConnected ? 'Disconnect' : 'Connect',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Кнопка закрытия
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}