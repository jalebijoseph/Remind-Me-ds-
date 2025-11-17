// lib/models/medication.dart
class Medication {
  final int id;
  final String name;
  final String purpose;
  final String illness;
  final int dosageMg;
  final int pillsTotal;
  final int pillsRemaining;
  final int refillThreshold;
  final String scheduleTime;
  final String startDate;

  Medication({
    required this.id,
    required this.name,
    required this.purpose,
    required this.illness,
    required this.dosageMg,
    required this.pillsTotal,
    required this.pillsRemaining,
    required this.refillThreshold,
    required this.scheduleTime,
    required this.startDate,
  });

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as int,
      name: map['name'] as String,
      purpose: map['purpose'] as String,
      illness: map['illness'] as String,
      // 👇 use the REAL column name from Supabase (likely 'dosage')
      dosageMg: map['dosage'] as int,
      pillsTotal: map['pills_total'] as int,
      pillsRemaining: map['pills_remaining'] as int,
      refillThreshold: map['refill_threshold'] as int,
      scheduleTime: map['schedule_time'] as String,
      startDate: map['start_date'] as String,
    );
  }
}
