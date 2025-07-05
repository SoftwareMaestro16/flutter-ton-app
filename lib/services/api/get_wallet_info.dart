import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testapp/core/constants/app_constants.dart';

Future<Map<String, dynamic>> fetchAccountInfo(String address) async {
  final url = Uri.parse('${AppConstants.tonApiBaseUrl}/accounts/${Uri.encodeComponent(address)}');
  final response = await http.get(url, headers: {'accept': 'application/json'});

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('failed to load account');
  }
}