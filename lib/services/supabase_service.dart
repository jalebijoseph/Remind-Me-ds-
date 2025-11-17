// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medication.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Get meds for the **currently logged in user**
  Future<List<Medication>> getMedications() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      // not logged in → nothing to show
      return [];
    }

    final data = await supabase
        .from('medications')
        .select()
        .eq('user_id', userId)
        .order('name', ascending: true);

    return data.map<Medication>((e) => Medication.fromMap(e)).toList();
  }

  /// Insert a new medication row and return its id
  Future<int> addMedication(Map<String, dynamic> med) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not logged in – cannot save medication.');
    }

    med['user_id'] = userId;

    final inserted = await supabase
        .from('medications')
        .insert(med)
        .select()
        .single();

    return inserted['id'] as int;
  }

  Future<void> updateMedication(int id, Map<String, dynamic> med) async {
    await supabase.from('medications').update(med).eq('id', id);
  }

  Future<void> deleteMedication(int id) async {
    await supabase.from('medications').delete().eq('id', id);
  }
}
