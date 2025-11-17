import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vslhzmmianlxfktytcxu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzbGh6bW1pYW5seGZrdHl0Y3h1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MTU4MzIsImV4cCI6MjA3ODM5MTgzMn0.PGciYkpPNUoblYsU9aDiHKnQd7AsKdFLxnJXoxLH6Ag',
  );

  await reminderService.init();

  runApp(const RemindMedsApp());
}

class RemindMedsApp extends StatelessWidget {
  const RemindMedsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      title: 'Remind Me(ds)',
      debugShowCheckedModeBanner: false,
      theme: lightPastelTheme,
      darkTheme: darkPastelTheme,
      themeMode: ThemeMode.system,
      home: user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
