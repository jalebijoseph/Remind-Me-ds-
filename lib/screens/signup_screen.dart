import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/pastel_button.dart';
import '../widgets/pastel_text_field.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final auth = AuthService();

  bool loading = false;
  String? error;

  Future<void> signup() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await auth.signUp(emailC.text.trim(), passC.text.trim());
      await auth.signIn(emailC.text.trim(), passC.text.trim());

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => error = "Sign up failed. Try a different email.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create account")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            children: [
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
                  : PastelButton(label: "Sign Up", onPressed: signup),
            ],
          ),
        ),
      ),
    );
  }
}
