import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testapp/core/constants/app_constants.dart';

Future<List<Map<String, dynamic>>> fetchUserNfts(String address) async {
  final url = Uri.parse('${AppConstants.tonApiBaseUrl}/accounts/${Uri.encodeComponent(address)}/nfts?collection=${AppConstants.collectionAddress}');
  final response = await http.get(url, headers: {"accept": "application/json"});

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final items = body['nft_items'] as List<dynamic>? ?? [];
    return items.map((item) => item as Map<String, dynamic>).toList();
  } else {
    throw Exception('failed to fetch nfts');
  }
}