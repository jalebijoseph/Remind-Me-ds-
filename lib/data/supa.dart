import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supa = Supabase.instance.client;

Future<List<Map<String, dynamic>>> getAllMeds() async {
  final res = await supa.from('medications').select().order('created_at');
  return List<Map<String, dynamic>>.from(res);
}

Future<void> updateMed(String id, Map<String, dynamic> values) async {
  await supa.from('medications').update(values).eq('id', id);
}

Future<void> deleteMed(String id) async {
  await supa.from('medications').delete().eq('id', id);
}
