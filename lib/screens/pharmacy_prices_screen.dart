// lib/screens/pharmacy_prices_screen.dart
import 'package:flutter/material.dart';

import '../services/pharmacy_price_service.dart';
import '../models/phamacy_price.dart';
import '../widgets/pastel_button.dart';
import '../widgets/pastel_text_field.dart';

class PharmacyPricesScreen extends StatefulWidget {
  const PharmacyPricesScreen({super.key});

  @override
  State<PharmacyPricesScreen> createState() => _PharmacyPricesScreenState();
}

class _PharmacyPricesScreenState extends State<PharmacyPricesScreen> {
  final drugC = TextEditingController();
  final zipC = TextEditingController();

  final PharmacyPriceService service = PharmacyPriceService();

  bool loading = false;
  String? error;
  List<PharmacyPrice> prices = [];

  Future<void> _search() async {
    setState(() {
      loading = true;
      error = null;
      prices = [];
    });

    try {
      final result = await service.fetchPrices(
        drugName: drugC.text.trim(),
        zipCode: zipC.text.trim(),
      );
      setState(() => prices = result);
    } catch (e) {
      setState(() => error = "Failed to load prices. Configure a real API.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    drugC.dispose();
    zipC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacy Prices"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              PastelTextField(controller: drugC, label: "Medication name"),
              const SizedBox(height: 12),
              PastelTextField(
                controller: zipC,
                label: "ZIP code",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              PastelButton(label: "Search", onPressed: _search),
              const SizedBox(height: 16),
              if (loading) const LinearProgressIndicator(),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
              Expanded(
                child: prices.isEmpty && !loading && error == null
                    ? const Center(
                        child: Text(
                          "Enter a medication + ZIP code to see estimated prices.\n"
                          "(Configure a real API in pharmacy_price_service.dart)",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: prices.length,
                        itemBuilder: (context, i) {
                          final p = prices[i];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              title: Text(p.pharmacy),
                              subtitle: Text(p.address),
                              trailing: Text(
                                "\$${p.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
