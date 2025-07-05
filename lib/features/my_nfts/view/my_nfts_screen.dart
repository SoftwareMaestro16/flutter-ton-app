import 'package:flutter/material.dart';
import 'package:testapp/core/constants/app_constants.dart';
import 'package:testapp/services/api/get_nft_info.dart';
import 'package:testapp/services/local_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NFTScreen extends StatefulWidget {
  const NFTScreen({super.key});

  @override
  State<NFTScreen> createState() => _NFTScreenState();
}

class _NFTScreenState extends State<NFTScreen> {
  List<Map<String, dynamic>> nftItems = [];
  String? address;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNfts();
  }

  Future<void> _loadNfts() async {
    final savedAddress = await LocalStorageService.loadAddress();
    if (savedAddress == null) {
      setState(() {
        address = null;
        isLoading = false;
      });
      return;
    }

    try {
      final fetched = await fetchUserNfts(savedAddress);
      setState(() {
        address = savedAddress;
        nftItems = fetched;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('NFT fetch error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (address == null || nftItems.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 200,
                  child: Image.asset(
                    'lib/assets/nft.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('No NFTs found', style: TextStyle(fontSize: 21)),
              const SizedBox(height: 20),
              SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet NFT', style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold
      )),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(11.0),
        child: GridView.builder(
          
          itemCount: nftItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 0,
            crossAxisSpacing: 14,
            childAspectRatio: 0.57,
          ),
          itemBuilder: (context, index) {
            final nft = nftItems[index];
            final name = nft['metadata']?['name'] ?? 'Unnamed';
            final image = nft['metadata']?['image'];
            final nftAddress = nft['address'];

            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                
                children: [
                      const SizedBox(height: 10),
                    SizedBox(
                    height: 120, 
                    child: image != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
                    child: Text(
                      name.toString().length > 18
                          ? '${name.toString().substring(0, 16)}...'
                          : name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: double.infinity * 0.95,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final url = 'https://testnet.tonviewer.com/$nftAddress';
                          launchUrl(Uri.parse(url));
                        },
                        child: const Text('View', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}