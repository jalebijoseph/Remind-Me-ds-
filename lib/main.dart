import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'secrets.dart';
import 'app_colors.dart';
import 'features/auth/auth_page.dart';
import 'features/meds/home_page.dart';
import 'services/notifier.dart';
import 'services/reminder_watcher.dart';
import 'globals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sanity check your dart-defines arrived
  // ignore: avoid_print
  print('URL = ${Secrets.supabaseUrl}');
  // ignore: avoid_print
  print('ANON length = ${Secrets.supabaseAnonKey.length}');

  await Supabase.initialize(url: Secrets.supabaseUrl, anonKey: Secrets.supabaseAnonKey);
  await Notifier.init();
  await ReminderWatcher().start(); // live scheduling + in-app alerts while open

  runApp(const MedsApp());
}

class MedsApp extends StatelessWidget {
  const MedsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = Supabase.instance.client.auth.currentUser != null;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Meds Companion',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.danger,
          surface: AppColors.background,
          onSurface: AppColors.textDeep,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textDeep),
          titleLarge: TextStyle(color: AppColors.textDeep, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: loggedIn ? '/home' : '/auth',
      routes: {
        '/auth': (_) => const AuthPage(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}
