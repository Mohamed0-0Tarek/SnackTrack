import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().profile;
    final auth    = context.read<AuthController>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              if (profile != null) ...[
                Text(profile.name,  style: Theme.of(context).textTheme.headlineMedium),
                Text(profile.email, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const Spacer(),
              CustomButton(label: 'Logout', onPressed: auth.logout, outlined: true),
            ],
          ),
        ),
      ),
    );
  }
}
