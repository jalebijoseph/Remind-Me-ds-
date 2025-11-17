// lib/models/pharmacy_price.dart
class PharmacyPrice {
  final String pharmacy;
  final String address;
  final double price;
  final String source;

  PharmacyPrice({
    required this.pharmacy,
    required this.address,
    required this.price,
    required this.source,
  });

  factory PharmacyPrice.fromMap(Map<String, dynamic> map) {
    return PharmacyPrice(
      pharmacy: map['pharmacy'] ?? 'Unknown Pharmacy',
      address: map['address'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      source: map['source'] ?? 'API',
    );
  }
}
