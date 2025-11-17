import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/pastel_button.dart';
import '../widgets/pastel_text_field.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final auth = AuthService();

  bool loading = false;
  String? error;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await auth.signIn(emailC.text.trim(), passC.text.trim());
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => error = "Login failed. Check your details.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text("Remind Me(ds)", style: textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text(
                  "Caring for your health, one reminder at a time💊⏰.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PastelTextField(controller: emailC, label: "Email"),
                const SizedBox(height: 16),
                PastelTextField(
                  controller: passC,
                  label: "Password",
                  obscureText: true,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                loading
                    ? const CircularProgressIndicator()
                    : PastelButton(label: "Log In", onPressed: login),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text("New here? Create an account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
