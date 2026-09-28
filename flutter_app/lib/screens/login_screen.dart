import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../navigation/app_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController(text: 'INS-MH-042');
  final _nameController = TextEditingController(text: 'Rajesh Patil');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspector Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.badge_outlined, size: 64, color: OnionSureColors.primaryGreen),
            const SizedBox(height: 16),
            const Text(
              'APMC Mandi Authorized Inspector',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Inspector Badge ID'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Inspector Name'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().login(
                      _idController.text.trim(),
                      _nameController.text.trim(),
                    );
                context.go(AppRoutes.dashboard);
              },
              child: const Text('Authenticate & Enter'),
            ),
          ],
        ),
      ),
    );
  }
}
