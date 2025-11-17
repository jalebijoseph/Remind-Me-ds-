import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/medication.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'add_edit_med_screen.dart';
import 'login_screen.dart';
import 'med_detail_screen.dart';
import 'pharmacy_prices_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = SupabaseService();
  final auth = AuthService();
  List<Medication> meds = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMeds();
  }

  Future<void> loadMeds() async {
    setState(() => loading = true);
    meds = await db.getMedications();
    if (mounted) setState(() => loading = false);
  }

  Future<void> logout() async {
    await auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Medications"),
        actions: [
          IconButton(
            tooltip: "Check pharmacy prices",
            icon: const Icon(Icons.local_pharmacy_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PharmacyPricesScreen(),
                ),
              );
            },
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadMeds,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : meds.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              email,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "No meds yet — tap + to add your first one 💊",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: meds.length,
                    itemBuilder: (context, index) {
                      final m = meds[index];
                      final needsRefill =
                          m.pillsRemaining <= m.refillThreshold;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          title: Text(
                            m.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          subtitle: Text(
                            "${m.dosageMg} mg • ${m.scheduleTime} • ${m.pillsRemaining}/${m.pillsTotal} pills",
                          ),
                          trailing: needsRefill
                              ? const Icon(Icons.warning, color: Colors.red)
                              : const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MedDetailScreen(
                                  med: m,
                                  onChanged: loadMeds,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditMedScreen(onSaved: loadMeds),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
