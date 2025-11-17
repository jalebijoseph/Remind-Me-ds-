// lib/services/pharmacy_price_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/phamacy_price.dart';

class PharmacyPriceService {
  /// TODO: Replace with a real external pharmacy price API.
  static const String _baseUrl = 'https://api.your-pharmacy-prices.com/search';
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  Future<List<PharmacyPrice>> fetchPrices({
    required String drugName,
    required String zipCode,
  }) async {
    if (drugName.isEmpty || zipCode.isEmpty) {
      throw Exception('Drug name and ZIP code are required.');
    }

    final uri = Uri.parse(
      '$_baseUrl?drug=${Uri.encodeQueryComponent(drugName)}&zip=$zipCode',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load prices (status ${response.statusCode}).',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid JSON from pharmacy price API.');
    }

    final List<dynamic> items;
    if (decoded is Map<String, dynamic>) {
      if (decoded['results'] is List) {
        items = decoded['results'] as List;
      } else if (decoded['data'] is List) {
        items = decoded['data'] as List;
      } else if (decoded.values.isNotEmpty && decoded.values.first is List) {
        items = decoded.values.first as List;
      } else {
        items = const [];
      }
    } else if (decoded is List) {
      items = decoded;
    } else {
      items = const [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map((e) => PharmacyPrice.fromMap(e))
        .toList();
  }
}
